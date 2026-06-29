import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  double fontSize;
  FontWeight fontWeight;
  Label({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF8B8BB5),
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
