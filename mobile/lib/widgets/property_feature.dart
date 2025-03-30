import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PropertyFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  // ✅ เพิ่มพารามิเตอร์ใหม่
  final double fontSize;
  final double iconSize;

  const PropertyFeature({
    Key? key,
    required this.icon,
    required this.text,
    this.color = AppColors.primary,
    this.fontSize = 12,
    this.iconSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: iconSize), // ✅ ใช้ iconSize
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: fontSize), // ✅ ใช้ fontSize
        ),
      ],
    );
  }
}
