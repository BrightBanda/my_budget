import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_budget/src/utils/currency_formatter.dart';
import 'package:my_budget/src/utils/currency_input_formatter.dart';

class AddFundsResult {
  final double amount;
  final bool deductFromBalance;

  const AddFundsResult({required this.amount, required this.deductFromBalance});
}

class AddFundsDialog extends StatefulWidget {
  const AddFundsDialog({super.key});

  @override
  State<AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<AddFundsDialog> {
  final _amountController = TextEditingController();

  bool deductFromBalance = true;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF17173B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Funds', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Amount',
              hintStyle: const TextStyle(color: Color(0xFF7070A0)),
              filled: true,
              fillColor: const Color(0xFF252555),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SwitchListTile(
            value: deductFromBalance,
            activeThumbColor: Colors.green,
            title: const Text(
              'Deduct from balance',
              style: TextStyle(color: Colors.white),
            ),
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                deductFromBalance = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = parseCurrency(_amountController.text);

            if (amount == null || amount <= 0) {
              return;
            }

            Navigator.pop(
              context,
              AddFundsResult(
                amount: amount,
                deductFromBalance: deductFromBalance,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

Future<AddFundsResult?> showAddFundsDialog(BuildContext context) {
  return showDialog<AddFundsResult>(
    context: context,
    builder: (_) => const AddFundsDialog(),
  );
}

double parseCurrency(String value) {
  return double.tryParse(value.replaceAll(',', '')) ?? 0;
}
