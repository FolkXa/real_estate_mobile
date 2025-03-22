import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PropertyFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const PropertyFeature({
    Key? key,
    required this.icon,
    required this.text,
    this.color = AppColors.primary,
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
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}