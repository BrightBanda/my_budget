import 'package:intl/intl.dart';

extension NumberFormatting on num {
  static final NumberFormat _formatter = NumberFormat('#,##0');

  /// 250000 -> 250,000
  String get formatted => _formatter.format(this);

  /// 250000 -> MWK 250,000
  String get mwk => 'MWK ${_formatter.format(this)}';

  /// 250000 -> K250,000
  String get kwacha => 'K${_formatter.format(this)}';

  /// 250000.50 -> 250,000.50
  String get formattedDecimal => NumberFormat('#,##0.00').format(this);

  /// 250000.50 -> MWK 250,000.50
  String get mwkDecimal => 'MWK ${NumberFormat('#,##0.00').format(this)}';
}
