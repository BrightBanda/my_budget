import 'package:my_budget/src/data/models/transaction.dart';

/// A transaction parsed out of a mobile-money notification by the Android listener.
///
/// This is the raw native payload. Turning it into one or more [BudgetTransaction]s
/// is the mapper's job — see [DetectedTransactionMapper].
class DetectedTransaction {
  final String provider;
  final String type;
  final double amount;
  final double? fee;
  final String? reference;
  final String rawMessage;
  final String? counterparty;
  final DateTime detectedAt;

  const DetectedTransaction({
    required this.provider,
    required this.type,
    required this.amount,
    required this.fee,
    required this.reference,
    required this.rawMessage,
    required this.counterparty,
    required this.detectedAt,
  });

  factory DetectedTransaction.fromMap(Map<String, dynamic> map) {
    return DetectedTransaction(
      provider: map['provider'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      fee: (map['fee'] as num?)?.toDouble(),
      reference: map['reference'] as String?,
      rawMessage: map['rawMessage'] as String,
      counterparty: map['counterparty'] as String?,
      detectedAt: DateTime.fromMillisecondsSinceEpoch(map['detectedAt'] as int),
    );
  }
}

/// Maps a native detection onto the app's own transaction model.
extension DetectedTransactionMapper on DetectedTransaction {
  bool get isIncome => type == 'income';

  /// Stable across re-imports, so replaying the same detection overwrites its row
  /// instead of duplicating it. The provider's own reference is used whenever the
  /// message carries one; otherwise the timestamp and amount stand in.
  String get stableId {
    final slug = provider.toLowerCase().replaceAll(' ', '_');

    if (reference != null) return 'auto_${slug}_$reference';

    return 'auto_${slug}_${detectedAt.millisecondsSinceEpoch}_${amount.toStringAsFixed(2)}';
  }

  String get _title {
    if (counterparty != null && counterparty!.isNotEmpty) {
      return isIncome ? 'From $counterparty' : 'To $counterparty';
    }

    return isIncome ? '$provider deposit' : '$provider payment';
  }

  /// Best-effort category guess. Anything unrecognised falls back to the catch-all
  /// so the user can correct it, rather than being silently mis-filed.
  String get _category {
    if (isIncome) return 'other';

    final message = rawMessage.toLowerCase();

    const keywords = <String, List<String>>{
      'Internet': ['airtime', 'data', 'bundle', 'internet'],
      'Transport': ['fuel', 'transport', 'bus', 'taxi'],
      'Food': ['food', 'restaurant', 'grocery', 'shoprite'],
      'Rent': ['rent', 'landlord'],
      'Fees': ['fees', 'tuition', 'school'],
      'Medics': ['pharmacy', 'clinic', 'hospital', 'medical'],
    };

    for (final entry in keywords.entries) {
      if (entry.value.any(message.contains)) return entry.key;
    }

    return 'Other';
  }

  /// The value transaction, plus a separate expense for the provider's fee when the
  /// message reported one — a fee leaves the balance regardless of transaction type.
  List<BudgetTransaction> toBudgetTransactions() {
    final transactions = <BudgetTransaction>[
      BudgetTransaction(
        id: stableId,
        amount: amount,
        title: _title,
        date: detectedAt,
        type: type,
        category: _category,
        provider: provider,
      ),
    ];

    if (fee != null && fee! > 0) {
      transactions.add(
        BudgetTransaction(
          id: '${stableId}_fee',
          amount: fee!,
          title: '$provider fee',
          date: detectedAt,
          type: 'expense',
          category: 'Other',
          provider: provider,
        ),
      );
    }

    return transactions;
  }
}
