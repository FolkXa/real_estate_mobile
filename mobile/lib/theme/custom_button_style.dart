import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import '../core/app_export.dart';

/// A class that offers pre-defined button styles for customizing button appearance.
class CustomButtonStyles {
  // Filled button style
  static ButtonStyle get fillGray => ElevatedButton.styleFrom(
        backgroundColor: appTheme.gray100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.h),
        ),
        elevation: 0,
        padding: EdgeInsets.zero,
      );

  static ButtonStyle get fillLightGreen => ElevatedButton.styleFrom(
        backgroundColor: appTheme.lightGreen500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.h),
        ),
        elevation: 0,
        padding: EdgeInsets.zero,
      );

  static ButtonStyle get fillPrimaryContainer => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.h),
        ),
        elevation: 0,
        padding: EdgeInsets.zero,
      );

  // Gradient button style
  static BoxDecoration get gradientOnPrimaryContainerToOnPrimaryContainerDecoration =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            theme.colorScheme.onPrimaryContainer,
            theme.colorScheme.onPrimaryContainer.withAlpha(0),
          ],
        ),
      );

  // Outline button style
  static BoxDecoration get outlineDecoration => BoxDecoration(
        color: appTheme.blueA700,
        borderRadius: BorderRadius.circular(10.h),
        border: GradientBoxBorder(
          width: 1.h,
          gradient: LinearGradient(
            begin: Alignment(0.5, 0),
            end: Alignment(0.5, 1),
            colors: [
              theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
              theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
            ],
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.indigoA400,
            spreadRadius: 2.h,
            // blurRadius: 2.h,
            offset: Offset(0, 0),
          ),
        ],
      );

  static ButtonStyle get outlineGray => OutlinedButton.styleFrom(
        backgroundColor: appTheme.gray800,
        side: BorderSide(
          color: appTheme.gray800,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.h),
        ),
        padding: EdgeInsets.zero,
      );

  static ButtonStyle get outlinel => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        elevation: 0,
        padding: EdgeInsets.zero,
      );

  // Text button style
  static ButtonStyle get none => ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        elevation: MaterialStateProperty.all<double>(0),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
        side: MaterialStateProperty.all<BorderSide>(
          BorderSide(color: Colors.transparent),
        ),
      );
}
