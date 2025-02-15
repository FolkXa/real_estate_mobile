import 'package:flutter/material.dart';

import '../core/app_export.dart';

class MainLogo extends StatelessWidget {
  const MainLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.h,
      height: 140.h,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImageConstant.imgMainLogo),
        ),
      ),
    );
  }
}
