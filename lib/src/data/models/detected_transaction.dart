/// A transaction parsed out of a mobile-money notification by the Android listener.
///
/// This is the raw native payload. It is never written to the database directly — it
/// pre-fills the add-transaction sheet, and the user confirms the final values.
class DetectedTransaction {
  final String provider;
  final String type; // 'income' | 'expense'
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

  bool get isIncome => type == 'income';

  /// A human title for the add-transaction sheet, e.g. "To ESTHER NGANGURA".
  String get suggestedTitle {
    final party = counterparty;

    if (party != null && party.isNotEmpty) {
      return isIncome ? 'From $party' : 'To $party';
    }

    return isIncome ? '$provider deposit' : '$provider payment';
  }

  /// Best-effort category guess for the sheet. Unrecognised spending falls back to the
  /// catch-all so the user corrects it, rather than being silently mis-filed.
  String get suggestedCategory {
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
}
