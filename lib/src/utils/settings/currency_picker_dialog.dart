import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/models/currency.dart';
import 'package:my_budget/src/providers/currency_provider.dart';
import 'package:my_budget/src/utils/app_colors.dart';

/// A large modal currency picker. Selecting an entry updates [currencyProvider]
/// and closes the sheet — no logic beyond that lives here.
class CurrencyPickerDialog extends ConsumerWidget {
  const CurrencyPickerDialog({super.key});

  /// Opens the picker as a scaled-up fade-in dialog.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Currency',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const CurrencyPickerDialog(),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(currencyProvider);

    return Dialog(
      backgroundColor: const Color(0xFF17173B),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Choose currency",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(color: Color(0xFF2A2A5A), height: 1),

            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: Currency.all.length,
                itemBuilder: (context, index) {
                  final currency = Currency.all[index];
                  final isSelected = currency.code == selected.code;

                  return _CurrencyRow(
                    currency: currency,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(currencyProvider.notifier).select(currency);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  final Currency currency;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyRow({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(currency.flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        currency.name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${currency.country} · ${currency.code} (${currency.symbol})",
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.white24),
    );
  }
}
