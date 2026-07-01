import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/providers/goals_provider.dart';
import 'package:my_budget/src/utils/label.dart';
import 'package:my_budget/src/utils/transaction_sheet/date_picker.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final titleController = TextEditingController();
  final targetAmountController = TextEditingController();
  final currentAmountController = TextEditingController();

  DateTime dueDate = DateTime.now().add(const Duration(days: 30));

  String selectedCategory = 'Electronics';

  final categories = [
    'Electronics',
    'Travel',
    'Car',
    'House',
    'Education',
    'Emergency',
    'Other',
  ];

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
              /// HEADER
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Create Goal',
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

              const SizedBox(height: 20),

              Label(text: 'GOAL TITLE'),

              const SizedBox(height: 8),

              _textField(controller: titleController, hint: 'New Laptop'),

              const SizedBox(height: 16),

              Label(text: 'TARGET AMOUNT'),

              const SizedBox(height: 8),

              _textField(
                controller: targetAmountController,
                hint: '350000',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              Label(text: 'CURRENT AMOUNT'),

              const SizedBox(height: 8),

              _textField(
                controller: currentAmountController,
                hint: '0',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              Label(text: 'CATEGORY'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                dropdownColor: const Color(0xFF252555),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              Label(text: 'TARGET DATE'),

              const SizedBox(height: 8),

              DatePicker(
                date: dueDate,
                onChanged: (date) {
                  setState(() {
                    dueDate = date;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final goal = SavingGoal(
                      id: DateTime.now().toIso8601String(),
                      title: titleController.text,
                      category: selectedCategory,
                      currentAmount:
                          double.tryParse(currentAmountController.text) ?? 0,
                      targetAmount: double.parse(targetAmountController.text),
                      dueDate: dueDate,
                      createdAt: DateTime.now(),
                    );

                    await ref.read(goalsProvider.notifier).addGoal(goal);

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D084),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Create Goal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
