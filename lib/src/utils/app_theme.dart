import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Primary Colors
const earth = Color(0xFF16140D); // Used for text on light backgrounds, borders
const vanilla = Color(0xFFF8F4EC); // Default background color
const midColor = Color.fromRGBO(135, 132, 125, 1); // Blended vanilla and earth

// Secondary Colors (ProfileColor options for user customization)
const aubergine = Color(0xFF3C0825);
const sherwood = Color(0xFF215143);
const royal = Color(0xFF3938B7);
const cloud = Color(0xFF5587F7);
const mandarin = Color(0xFFEC6933);
const vice = Color(0xFFECA4F4);

// Feedback Colors
const errorColor = Color(0xffd91c15);
const successColor = Colors.green;

// Spacing Standards (8px grid system)
const spacingUnit = 8.0;
const formSpacer = SizedBox(width: spacingUnit * 2, height: spacingUnit * 3);
const formPadding = EdgeInsets.symmetric(
  vertical: spacingUnit * 2,
  horizontal: spacingUnit * 1,
);

// UI Elements
var preloader = Center(
  child: CircularProgressIndicator(
    color: ProfileColorManager.getProfileColor(),
  ),
);
const unexpectedErrorMessage = 'Unexpected error occurred';

// Typography Standards
const String fontFamily = 'Helvetica';
const double titleFontSize = 24.0;
const double headerFontSize = 20.0;
const double bodyFontSize = 16.0;
const FontWeight titleFontWeight = FontWeight.w500;
const FontWeight headerFontWeight = FontWeight.w500;
const FontWeight bodyFontWeight = FontWeight.w400;

// Icon Standards
const double iconSize = 30.0;

// Button Standards
const double buttonBorderRadius = 12.0;
const double buttonElevation = 2.0; // Small shadow for buttons

// Helper function to determine text color based on background
Color getTextColor(Color backgroundColor) {
  const darkBackgrounds = [earth, royal, sherwood, aubergine];
  return darkBackgrounds.contains(backgroundColor) ? vanilla : earth;
}

// Light Theme Configuration
final lightTheme = ThemeData.light().copyWith(
  primaryColor: ProfileColorManager.getProfileColor(),
  scaffoldBackgroundColor: vanilla,
  secondaryHeaderColor: ProfileColorManager.getProfileColor().withAlpha(200),

  // AppBar
  appBarTheme: AppBarTheme(
    elevation: buttonElevation,
    backgroundColor: ProfileColorManager.getProfileColor(),
    iconTheme: IconThemeData(
      color: getTextColor(ProfileColorManager.getProfileColor()),
      size: iconSize,
    ),
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: headerFontSize,
      fontWeight: headerFontWeight,
      color: getTextColor(ProfileColorManager.getProfileColor()),
    ),
  ),

  // Typography
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: titleFontSize,
      fontWeight: titleFontWeight,
      color: earth,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: headerFontSize,
      fontWeight: headerFontWeight,
      color: earth,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
      color: earth,
    ),
  ),

  // Icons
  iconTheme: IconThemeData(color: earth, size: iconSize),

  // Buttons
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ProfileColorManager.getProfileColor(),
      textStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: bodyFontSize,
        fontWeight: bodyFontWeight,
      ),
      iconColor: ProfileColorManager.getProfileColor(),
      iconSize: iconSize,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: getTextColor(ProfileColorManager.getProfileColor()),
      backgroundColor: ProfileColorManager.getProfileColor(),
      textStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: bodyFontSize,
        fontWeight: bodyFontWeight,
        color: getTextColor(ProfileColorManager.getProfileColor()),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
      elevation: buttonElevation,
      iconColor: getTextColor(ProfileColorManager.getProfileColor()),
      iconSize: iconSize,
    ),
  ),

  // Input Fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: vanilla,
    floatingLabelStyle: TextStyle(
      color: earth,
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
    ),
    labelStyle: TextStyle(
      color: midColor,
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
    ),
    hintStyle: TextStyle(
      color: midColor,
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
      borderSide: const BorderSide(color: midColor, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
      borderSide: const BorderSide(color: earth, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: spacingUnit * 1.5,
      horizontal: spacingUnit * 1.25,
    ),
  ),
);

// Dark Theme Configuration
final darkTheme = ThemeData.dark().copyWith(
  primaryColor: ProfileColorManager.getProfileColor(),
  scaffoldBackgroundColor: earth,
  secondaryHeaderColor: ProfileColorManager.getProfileColor().withAlpha(200),

  // AppBar
  appBarTheme: AppBarTheme(
    elevation: buttonElevation,
    backgroundColor: ProfileColorManager.getProfileColor(),
    iconTheme: IconThemeData(
      color: getTextColor(ProfileColorManager.getProfileColor()),
      size: iconSize,
    ),
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: headerFontSize,
      fontWeight: headerFontWeight,
      color: getTextColor(ProfileColorManager.getProfileColor()),
    ),
  ),

  // Typography
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: titleFontSize,
      fontWeight: titleFontWeight,
      color: vanilla,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: headerFontSize,
      fontWeight: headerFontWeight,
      color: vanilla,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
      color: vanilla,
    ),
  ),

  // Icons
  iconTheme: IconThemeData(color: vanilla, size: iconSize),

  // Buttons
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ProfileColorManager.getProfileColor(),
      textStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: bodyFontSize,
        fontWeight: bodyFontWeight,
      ),
      iconColor: ProfileColorManager.getProfileColor(),
      iconSize: iconSize,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: getTextColor(ProfileColorManager.getProfileColor()),
      backgroundColor: ProfileColorManager.getProfileColor(),
      textStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: bodyFontSize,
        fontWeight: bodyFontWeight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
      elevation: buttonElevation,
      iconColor: getTextColor(ProfileColorManager.getProfileColor()),
      iconSize: iconSize,
    ),
  ),

  // Input Fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: earth.withAlpha(200),
    floatingLabelStyle: TextStyle(
      color: vanilla,
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
    ),
    labelStyle: TextStyle(
      color: midColor,
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
    ),
    hintStyle: TextStyle(
      color: midColor,
      fontFamily: fontFamily,
      fontSize: bodyFontSize,
      fontWeight: bodyFontWeight,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
      borderSide: BorderSide(color: midColor, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
      borderSide: const BorderSide(color: vanilla, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: spacingUnit * 1.5,
      horizontal: spacingUnit * 1.25,
    ),
  ),
);

// Extension for SnackBar
extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = vanilla,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: bodyFontSize,
            fontWeight: bodyFontWeight,
            color: getTextColor(backgroundColor),
          ),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: errorColor);
  }

  void showSuccessSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: successColor);
  }
}

// Helper class to manage ProfileColor based on user preference
class ProfileColorManager {
  static Color profileColor = royal;
  static const profileColorOptions = [
    aubergine,
    sherwood,
    royal,
    mandarin,
    vice,
    cloud,
  ];

  static Color getProfileColor() {
    return profileColor;
  }

  static void setProfileColor(Color userSelectedColor) {
    profileColor = userSelectedColor;
  }
}

// Helper class to manage ThemeMode and persistence
class ThemeModeManager {
  static const String _themeModeKey = 'theme_mode';
  static ThemeMode _currentMode = ThemeMode.light;
  static Future<void> Function(ThemeMode)? _themeModeCallback;

  static getThemeModeKey() => _themeModeKey;

  static getThemeMode() => _currentMode;
  static setCurrentThemeMode(ThemeMode mode) {
    _currentMode = mode;
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey) ?? 'light';
    _currentMode = modeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  static set registerThemeModeCallback(
    Future<void> Function(ThemeMode) callback,
  ) {
    _themeModeCallback = callback;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeModeCallback != null) {
      await _themeModeCallback!(mode);
    } else {
      _currentMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeModeKey,
        mode == ThemeMode.dark ? 'dark' : 'light',
      );
    }
  }
}
