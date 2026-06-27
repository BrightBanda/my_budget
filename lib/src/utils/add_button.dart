import 'package:flutter/material.dart';
import 'package:my_budget/src/utils/app_colors.dart';

class AddButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  const AddButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 80,
      margin: EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadiusDirectional.circular(40),
      ),
      child: MaterialButton(onPressed: onPressed, child: Text(title)),
    );
  }
}
