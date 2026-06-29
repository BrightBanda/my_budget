import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:my_budget/src/providers/balance_provider.dart';
import 'package:my_budget/src/providers/total_expense_provider.dart';
import 'package:my_budget/src/providers/total_income_provider.dart';
import 'package:my_budget/src/providers/transaction_provider.dart';
import 'package:my_budget/src/utils/label.dart';
import 'package:my_budget/src/utils/transaction_sheet/category_selector.dart';
import 'package:my_budget/src/utils/transaction_sheet/date_picker.dart';
import 'package:my_budget/src/utils/transaction_sheet/transaction_type_toggle.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  bool isExpense = true;

  String selectedCategory = 'Food';
  String selectedProvider = 'Airtel Money';

  final expenseCategories = ['Food', 'Transport', 'Rent', 'Data', 'Other'];
  final incomeCategories = ["Salary", "Pocket Money", "Business", "other"];

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF17173B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Transaction',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF8B8BB5)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              //expense and incom toggles
              TransactionTypeToggle(
                isExpense: isExpense,
                onChanged: (value) => setState(() {
                  isExpense = value;
                }),
              ),

              const SizedBox(height: 20),

              Label(text: 'AMOUNT (MWK)'),

              const SizedBox(height: 8),

              _textField(
                controller: amountController,
                hint: '0',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 16),

              Label(text: 'DESCRIPTION'),

              const SizedBox(height: 8),

              _textField(
                controller: descriptionController,
                hint: 'What was this for?',
              ),

              const SizedBox(height: 16),

              Label(text: 'CATEGORY'),

              const SizedBox(height: 12),

              //category selector
              CategorySelector(
                categories: isExpense ? expenseCategories : incomeCategories,
                selectedCategory: selectedCategory,
                onSelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 16),

              Label(text: 'PROVIDER'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedProvider,
                dropdownColor: const Color(0xFF252555),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
                items: const [
                  DropdownMenuItem(
                    value: 'Airtel Money',
                    child: Text('Airtel Money'),
                  ),
                  DropdownMenuItem(
                    value: 'TNM Mpamba',
                    child: Text('TNM Mpamba'),
                  ),
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedProvider = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              Label(text: 'DATE'),

              const SizedBox(height: 8),

              //Date picker
              DatePicker(
                date: selectedDate,
                onChanged: (date) => setState(() {
                  selectedDate = date;
                }),
              ),

              const SizedBox(height: 24),

              //save TRansaction button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.parse(amountController.text);
                    final transaction = BudgetTransaction(
                      amount: amount,
                      date: selectedDate,
                      title: descriptionController.text,
                      type: isExpense ? "expense" : "income",
                      category: selectedCategory,
                      id: DateTime.now().toIso8601String(),
                    );
                    await ref
                        .read(transactionsProvider.notifier)
                        .addTransaction(transaction);
                    print(selectedCategory);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D084),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _label(String text) {
  //   return Text(
  //     text,
  //     style: const TextStyle(
  //       color: Color(0xFF8B8BB5),
  //       fontSize: 12,
  //       fontWeight: FontWeight.w600,
  //     ),
  //   );
  // }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration().copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF252555),
      hintStyle: const TextStyle(color: Color(0xFF7070A0)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
