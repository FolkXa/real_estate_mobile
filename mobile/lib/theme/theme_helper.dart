import 'package:flutter/material.dart';
import '../core/app_export.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.
// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  var _appTheme = PrefUtils().getThemeData();

  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme,
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme = _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.onPrimaryContainer,
          side: BorderSide(
            color: colorScheme.secondaryContainer,
            width: 1.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.h),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.h),
          ),
          elevation: 0,
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 1,
        color: appTheme.blueGray50,
      ),
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

/// Class containing the supported text theme styles.
class TextThemes {
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
        bodySmall: TextStyle(
          color: appTheme.blueGray600,
          fontSize: 8.fSize,
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: colorScheme.onErrorContainer,
          fontSize: 32.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 25.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 12.fSize,
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w700,
        ),
        labelMedium: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 10.fSize,
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: appTheme.blueGray600,
          fontSize: 8.fSize,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 20.fSize,
          fontFamily: 'Istok Web',
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 18.fSize,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: colorScheme.onErrorContainer,
          fontSize: 14.fSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      );
}

/// Class containing the supported color schemes.
class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light(
    primaryContainer: Color(0xFF234F68),
    secondaryContainer: Color(0xFFEFF0F6),
    errorContainer: Color(0xFFDD88CF),
    onError: Color(0xFF000000),
    onErrorContainer: Color(0xFF1A1C1E),
    onPrimary: Color(0xFF242B5C),
    onPrimaryContainer: Color(0xFFFFFFFF),
  );
}

// Class containing custom colors for a lightCode theme.
class LightCodeColors {
  // Amber
  Color get amber500 => Color(0xFFFBBC05);
  Color get amberA200 => Color(0xFFFFDA44);

  // Blue
  Color get blueA200 => Color(0xFF4285F4);
  Color get blueA700 => Color(0xFF1C616);

  // BlueGray
  Color get blueGray200 => Color(0xFFACB5BB);
  Color get blueGray50 => Color(0xFFEDF1F3);
  Color get blueGray5001 => Color(0xFFECEDF3);
  Color get blueGray600 => Color(0xFF53577A);
  Color get blueGray700Af => Color(0xAF3F467C);
  Color get blueGray800 => Color(0xFF1F4C6B);
  Color get blueGray80001 => Color(0xFF39367);

  // DeepOrange
  Color get deepOrangeA200 => Color(0xFFFA712D);

  // Gray
  Color get gray100 => Color(0xFFF5F4F7);
  Color get gray10099 => Color(0x99F3F5F9);
  Color get gray300 => Color(0xFFDFDFDF);
  Color get gray3003d => Color(0x3DE45E7);
  Color get gray600 => Color(0xFF6C7278);
  Color get gray800 => Color(0xFF4B164C);

  // Green
  Color get green600 => Color(0xFF34A853);

  // Indigo
  Color get indigo200 => Color(0xFFA1A4C1);
  Color get indigoA400 => Color(0xFF375DFB);

  // LightGreen
  Color get lightGreen500 => Color(0xFF8BC83F);
  Color get lightGreen50001 => Color(0xFF8BC83D);

  // Pink
  Color get pink300 => Color(0xFFF248A4);

  // Purple
  Color get purple50 => Color(0xFFF8E7F6);

  // Red
  Color get red500 => Color(0xFFEB4335);
  Color get redA200 => Color(0xFFFF5D60);
  Color get redA20001 => Color(0xFFFD5F49);

  // Yellow
  Color get yellow700 => Color(0xFFFFC42C);
}
