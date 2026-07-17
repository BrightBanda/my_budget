import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/currency.dart';
import 'package:my_budget/src/presentation/viewmodel/currency_notifier.dart';

final currencyProvider = NotifierProvider<CurrencyNotifier, Currency>(
  CurrencyNotifier.new,
);
