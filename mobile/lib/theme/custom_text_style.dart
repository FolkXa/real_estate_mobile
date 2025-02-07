import 'package:flutter/material.dart';
import '../core/app_export.dart';

extension on TextStyle {
  TextStyle get lato {
    return copyWith(
      fontFamily: 'Lato',
    );
  }

  TextStyle get inter {
    return copyWith(
      fontFamily: 'Inter',
    );
  }

  TextStyle get raleway {
    return copyWith(
      fontFamily: 'Raleway',
    );
  }

  TextStyle get montserrat {
    return copyWith(
      fontFamily: 'Montserrat',
    );
  }

  TextStyle get plusJakartaSans {
    return copyWith(
      fontFamily: 'Plus Jakarta Sans',
    );
  }
}
/// A collection of pre-defined text styles for customizing text appearance, /// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStylel to easily apply specific font families t class CustomTextStyles ‹
// Body text style
class CustomTextStyles {
  static TextStyle get bodySmall12 => theme.textTheme.bodySmall!.copyWith(
      fontSize: 12.fSize,
    );
static TextStyle get bodySmall12_1 => theme.textTheme.bodySmall!.copyWith(
      fontSize: 12.fSize,
    );
static TextStyle get bodySmall12_2 => theme.textTheme.bodySmall!.copyWith(
      fontSize: 12.fSize,
    );
static TextStyle get bodySmall => theme.textTheme.bodySmall!.copyWith(
      fontSize: 9.fSize,
    );
static TextStyle get bodySmal19_1 => theme.textTheme.bodySmall!.copyWith(
      fontSize: 9.fSize,
    );

static TextStyle get bodySmallBluegray800 => theme.textTheme.bodySmall!.copyWith(
      color: appTheme.blueGray800,
    );
static TextStyle get bodySmallIndigo200 => theme.textTheme.bodySmall!.copyWith(
      color: appTheme.indigo200,
      fontSize: 12.fSize,
    );
static TextStyle get bodySmallInterGray600 =>
    theme.textTheme.bodySmall!.inter.copyWith(
      color: appTheme.gray600,
      fontSize: 12.fSize,
    );
static TextStyle get bodySmallInterOnError =>
    theme.textTheme.bodySmall!.inter.copyWith(
      color: theme.colorScheme.onError,
      fontSize: 12.fSize,
    );
static TextStyle get bodySmallMontserrat =>
    theme.textTheme.bodySmall!.montserrat.copyWith(
      fontSize: 9.fSize,
    );
static TextStyle get bodySmallMontserrat_1 => theme.textTheme.bodySmall!.montserrat;
static TextStyle get bodySmallOnPrimary => theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 12.fSize,
    );
static TextStyle get bodySmallOnPrimary12 =>
    theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 12.fSize,
    );
static TextStyle get bodySmallOnPrimaryContainer =>
    theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontSize: 10.fSize,
    );
// Headline text style
static TextStyle get headlineSmallBold =>
    theme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w700,
    );
static TextStyle get headlineSmallExtraBold => theme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w800,
    );
static TextStyle get headlineSmallMedium => theme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w500,
    );
static TextStyle get headlineSmallMontserrat => theme.textTheme.headlineSmall!.montserrat;
static TextStyle get headlineSmallPrimaryContainer =>
    theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.primaryContainer,
      fontWeight: FontWeight.w800,
    );
static TextStyle get headlineSmallRaleway =>
    theme.textTheme.headlineSmall!.raleway.copyWith(
      fontWeight: FontWeight.w400,
    );
static TextStyle get headlineSmallRalewayBold =>
    theme.textTheme.headlineSmall!.raleway.copyWith(
      fontWeight: FontWeight.w700,
    );
static TextStyle get headlineSmallRegular => theme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w400,
    );
// Label text style
static TextStyle get labelLargeBluegray600 =>
    theme.textTheme.labelLarge!.copyWith(
      color: appTheme.blueGray600,
      fontWeight: FontWeight.w500,
    );
static TextStyle get labelLargeBluegray80001 =>
    theme.textTheme.labelLarge!.copyWith(
      color: appTheme.blueGray80001,
      fontWeight: FontWeight.w500,
    );
static TextStyle get labelLargeInterGray600 =>
    theme.textTheme.labelLarge!.inter.copyWith(
      color: appTheme.gray600,
      fontWeight: FontWeight.w500,
    );
static TextStyle get labelLargeInterOnError =>
    theme.textTheme.labelLarge!.inter.copyWith(
      color: theme.colorScheme.onError,
      fontWeight: FontWeight.w600,
    );
static TextStyle get labelLargeInterRedA200 =>
    theme.textTheme.labelLarge!.inter.copyWith(
      color: appTheme.redA200,
      fontWeight: FontWeight.w600,
    );
static TextStyle get labelLargeMontserrat => theme.textTheme.labelLarge!.montserrat;
static TextStyle get labelLargeMontserratGray100 =>
    theme.textTheme.labelLarge!.montserrat.copyWith(
      color: appTheme.gray100,
      fontWeight: FontWeight.w600,
    );
static TextStyle get labelLargePlusJakartaSansGray600 =>
    theme.textTheme.labelLarge!.plusJakartaSans.copyWith(
      color: appTheme.gray600,
      fontWeight: FontWeight.w500,
    );
static TextStyle get labelMediumBluegray600 =>
    theme.textTheme.labelMedium!.copyWith(
      color: appTheme.blueGray600,
    );
static TextStyle get labelMediumBluegray800 =>
    theme.textTheme.labelMedium!.copyWith(
      color: appTheme.blueGray800,
      fontWeight: FontWeight.w600,
    );
static TextStyle get labelMediumGray100 => theme.textTheme.labelMedium!.copyWith(
      color: appTheme.gray100,
      fontWeight: FontWeight.w700,
    );
static TextStyle get labelMediumOnPrimaryContainer =>
    theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
static TextStyle get labelMediumOnPrimaryContainerBold =>
    theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w700,
    );
static TextStyle get labelMediumPrimaryContainer =>
    theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.primaryContainer,
      fontWeight: FontWeight.w600,
    );
static TextStyle get labelMediumSemiBold => theme.textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w600,
    );
static TextStyle get labelSmallBluegray800 =>
    theme.textTheme.labelSmall!.copyWith(
      color: appTheme.blueGray800,
    );
static TextStyle get labelSmallOnPrimary =>
    theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w500,
    );
static TextStyle get labelSmallRalewayGray100 =>
    theme.textTheme.labelSmall!.raleway.copyWith(
      color: appTheme.gray100,
      fontWeight: FontWeight.w500,
    );
static TextStyle get labelSmallRalewayOnPrimaryContainer =>
    theme.textTheme.labelSmall!.raleway.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w500,
    );
// Montserrat text style
static TextStyle get montserratGray100 => TextStyle(
      color: appTheme.gray100,
      fontSize: 6.fSize,
      fontWeight: FontWeight.w500,
    ).montserrat;
// Title style
static TextStyle get titleLargeLato => theme.textTheme.titleLarge!.lato;
static TextStyle get titleMediumMontserrat =>
    theme.textTheme.titleMedium!.montserrat;
static TextStyle get titleMediumMontserratBluegray5001 =>
    theme.textTheme.titleMedium!.montserrat.copyWith(
      color: appTheme.blueGray5001,
      fontWeight: FontWeight.w500,
    );
static TextStyle get titleMediumMontserratSemiBold =>
    theme.textTheme.titleMedium!.montserrat.copyWith(
      fontSize: 16.fSize,
      fontWeight: FontWeight.w600,
    );
static TextStyle get titleMediumMontserrat_1 =>
    theme.textTheme.titleMedium!.montserrat;
static TextStyle get titleMediumOnPrimaryContainer =>
    theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontSize: 16.fSize,
    );
static TextStyle get titleMediumOnPrimaryContainer_1 =>
    theme.textTheme.titleMedium!.raleway.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
static TextStyle get titleSmallMontserratOnPrimaryContainer =>
    theme.textTheme.titleSmall!.montserrat.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w700,
    );
static TextStyle get titleSmallOnPrimaryContainer =>
    theme.textTheme.titleSmall!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
static TextStyle get titleSmallRalewayOnPrimary =>
    theme.textTheme.titleSmall!.raleway.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w700,
    );
static TextStyle get titleSmallSemiBold => theme.textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w600,
    );
}