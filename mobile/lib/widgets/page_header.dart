import 'package:flutter/material.dart';
import '../core/app_export.dart';
import 'package:real_estate_project/localization/app_localization.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const PageHeader({
    Key? key,
    required this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          if (trailing != null) trailing!,
        ],
      );
  }
}

