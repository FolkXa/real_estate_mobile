import 'package:flutter/material.dart';
import '../core/app_export.dart';

class AppDecoration {
  // Fill decorations
  static BoxDecoration get fillLightGreen => BoxDecoration(
        color: appTheme.lightGreen500.withOpacity(0.1),
      );

  static BoxDecoration get fillLightGreen500 => BoxDecoration(
        color: appTheme.lightGreen500,
      );

  static BoxDecoration get fillOnError => BoxDecoration(
        color: theme.colorScheme.onError.withOpacity(0.3),
      );

  static BoxDecoration get fillPrimaryContainer => BoxDecoration(
        color: theme.colorScheme.primaryContainer,
      );

  static BoxDecoration get fillPurple => BoxDecoration(
        color: appTheme.purple50,
      );

  // Gradient decorations
  static BoxDecoration get gradientOnPrimaryContainerToOnPrimaryContainer =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            theme.colorScheme.onPrimaryContainer,
            theme.colorScheme.onPrimaryContainer.withOpacity(0),
          ],
        ),
      );

  // Grey decorations
  static BoxDecoration get greySoft1 => BoxDecoration(
        color: appTheme.gray100,
      );

  // Outline decorations
  static BoxDecoration get outline => BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.69),
      );

  static BoxDecoration get outlineGray => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        border: Border.all(
          color: appTheme.gray300,
          width: 1.2.h,
        ),
      );
      static BoxDecoration get outlinel => BoxDecoration(
        color: appTheme.blueGray700Af,
      );
      // Soft decorations
      static BoxDecoration get soft2 => BoxDecoration(
        border: Border.all(
          color: appTheme.blueGray5001,
          width: 1.h,
        ),
      );

      // White decorations
      static BoxDecoration get white => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
      );

      // Column decorations
      static BoxDecoration get column9 => BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            ImageConstant.img0x0,
          ),
          fit: BoxFit.fill,
        ),
      );
    }

    class BorderRadiusStyle {
      // Circle borders
      static BorderRadius get circleBorder28 => BorderRadius.circular(
        28.h,
      );

      // Custom borders
      static BorderRadius get customBorderLR24 => BorderRadius.only(
        topRight: Radius.circular(24.h),
      );

      // Rounded borders
      static BorderRadius get roundedBorder14 => BorderRadius.circular(
        14.h,
      );
      static BorderRadius get roundedBorder18 => BorderRadius.circular(
        18.h,
      );
      static BorderRadius get roundedBorder2 => BorderRadius.circular(
        2.h,
      );
      static BorderRadius get roundedBorder24 => BorderRadius.circular(
        24.h,
      );
      static BorderRadius get roundedBorder34 => BorderRadius.circular(
        34.h,
      );
      static BorderRadius get roundedBorder50 => BorderRadius.circular(
        50.h,
      );
      static BorderRadius get roundedBorder8 => BorderRadius.circular(
        8.h,
      );
}
