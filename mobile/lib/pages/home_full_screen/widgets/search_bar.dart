import 'package:flutter/material.dart';
import 'package:real_estate_project/core/app_export.dart';

class FormSearchEmpty extends StatelessWidget {
  const FormSearchEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 327),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 51, 16),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/71707db63d204801a6fee5d394e58f46/412bad315a0f578265d10857e44c531efacbdd950f16c2dc98fe451c572c15b0',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  'Search House, Apartment, etc',
                  // style: AppTextStyles.searchText,
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 20.h,
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }
}