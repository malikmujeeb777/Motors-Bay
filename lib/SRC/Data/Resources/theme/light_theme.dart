import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Data/Resources/styles/app_textstyles.dart';


mixin CustomLightTheme {
  ThemeData lightTheme(String locale) => ThemeData(
    colorScheme: colorScheme,
    useMaterial3: false,
    buttonTheme: buttonThemeData,
    textTheme: textTheme(locale),
    iconTheme: iconThemeData,
    inputDecorationTheme: inputDecorationTheme(locale),
    appBarTheme: appBarTheme(locale),
    chipTheme: chipThemeData(locale),
    bottomNavigationBarTheme: bottomNavigationBarThemeData,
    dialogTheme: dialogTheme(locale),
    snackBarTheme: snackBarTheme(locale),
    dividerTheme: dividerThemeData,
    tabBarTheme: customTabBarTheme(locale),
  );

  static TabBarTheme customTabBarTheme(String locale) => TabBarTheme(
    labelStyle: AppTextStyles.regular(
      fontWeight: FontWeight.w500,
      locale: locale,
      fontSize: 17,
      color: LightColorsPalate.primaryColor,
    ),
    unselectedLabelStyle: AppTextStyles.regular(
      fontWeight: FontWeight.w500,
      fontSize: 17,
      locale: locale,
      color: LightColorsPalate.onSurfaceColor,
    ),
  );

  static ButtonThemeData buttonThemeData = const ButtonThemeData(
    buttonColor: LightColorsPalate.primaryColor,
    disabledColor: LightColorsPalate.primaryDisableColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );
  static ColorScheme colorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: LightColorsPalate.primaryColor,
    onPrimary: LightColorsPalate.backgroundColor,
    secondary: LightColorsPalate.secondaryColor,
    onSecondary: LightColorsPalate.backgroundColor,
    error: LightColorsPalate.errorColor,
    onError: LightColorsPalate.backgroundColor,
    background: LightColorsPalate.backgroundColor,
    onBackground: LightColorsPalate.onSurfaceColor,
    surface: LightColorsPalate.surfaceColor,
    onSurface: LightColorsPalate.onSurfaceColor,
    outline: LightColorsPalate.outlineColor,
    inversePrimary: LightColorsPalate.backgroundColor,
    tertiary: LightColorsPalate.tertiaryColor,
    primaryContainer: LightColorsPalate.primaryContainer,
  );

  static IconThemeData iconThemeData = const IconThemeData(
    color: LightColorsPalate.onSurfaceColor,
  );

  static AppBarTheme appBarTheme(String locale) => AppBarTheme(
    backgroundColor: LightColorsPalate.backgroundColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.bold(
      locale: locale,
      color: LightColorsPalate.onSurfaceColor,
      fontSize: 21,
    ),
  );

  static InputDecorationTheme inputDecorationTheme(String locale) =>
      InputDecorationTheme(
        hintStyle: AppTextStyles.regular(
          locale: locale,
          color: LightColorsPalate.tertiaryColor,
          fontSize: 15,
        ),
        fillColor: LightColorsPalate.surfaceColor,
        filled: true,
        suffixIconColor: LightColorsPalate.tertiaryColor,
        prefixIconColor: LightColorsPalate.tertiaryColor,
        border: OutlineInputBorder(
          borderSide:
          const BorderSide(width: 1, color: LightColorsPalate.outlineColor),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
          const BorderSide(width: 1, color: LightColorsPalate.outlineColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
          const BorderSide(width: 1, color: LightColorsPalate.outlineColor),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide:
          const BorderSide(width: 1, color: LightColorsPalate.outlineColor),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 1,
            color: LightColorsPalate.errorColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      );

  static ChipThemeData chipThemeData(String locale) => ChipThemeData(
    backgroundColor: LightColorsPalate.surfaceColor,
    disabledColor: LightColorsPalate.surfaceColor,
    selectedColor: LightColorsPalate.primaryColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(width: 1, color: LightColorsPalate.outlineColor),
    ),
    showCheckmark: false,
    brightness: Brightness.light,
    labelStyle: AppTextStyles.regular(
      locale: locale,
      fontSize: 13,
      color: LightColorsPalate.onSurfaceColor,
    ),
  );
  static BottomNavigationBarThemeData bottomNavigationBarThemeData =
  const BottomNavigationBarThemeData(
    unselectedItemColor: LightColorsPalate.tertiaryColor,
    selectedItemColor: LightColorsPalate.primaryColor,
    backgroundColor: Color(0xFFf9f9f9),
    elevation: 16,
    selectedLabelStyle: TextStyle(fontSize: 12.0),
    unselectedLabelStyle: TextStyle(fontSize: 12.0),
  );

  static DialogTheme dialogTheme(String locale) => DialogTheme(
    iconColor: LightColorsPalate.primaryColor,
    backgroundColor: LightColorsPalate.backgroundColor,
    alignment: Alignment.center,
    titleTextStyle: AppTextStyles.medium(
      locale: locale,
      color: LightColorsPalate.onSurfaceColor,
      fontSize: 21,
    ),
    contentTextStyle: AppTextStyles.regular(
      locale: locale,
      color: LightColorsPalate.secondaryColor,
      fontSize: 15,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );

  static SnackBarThemeData snackBarTheme(String locale) => SnackBarThemeData(
    backgroundColor: LightColorsPalate.onSurfaceColor,
    actionTextColor: LightColorsPalate.backgroundColor,
    actionBackgroundColor: LightColorsPalate.primaryColor,
    contentTextStyle: AppTextStyles.regular(
      locale: locale,
      color: LightColorsPalate.backgroundColor,
      fontSize: 15,
    ),
  );

  static DividerThemeData dividerThemeData = const DividerThemeData(
      color: LightColorsPalate.outlineColor, thickness: 1, space: 1);

  static TextTheme textTheme(String locale) => TextTheme(
    headlineLarge: AppTextStyles.bold(
      fontSize: 29,
      locale: locale,
      fontWeight: FontWeight.w600,
      color: LightColorsPalate.secondaryColor,
    ),
    headlineMedium: AppTextStyles.bold(
      locale: locale,
      fontSize: 25,
      fontWeight: FontWeight.w600,
      color: LightColorsPalate.secondaryColor,
    ),
    headlineSmall: AppTextStyles.medium(
      locale: locale,
      fontSize: 21,
      fontWeight: FontWeight.w500,
      color: LightColorsPalate.secondaryColor,
    ),
    titleLarge: AppTextStyles.bold(
      locale: locale,
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: LightColorsPalate.onSurfaceColor,
    ),
    titleMedium: AppTextStyles.bold(
      locale: locale,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: LightColorsPalate.primaryColor,
    ),
    titleSmall: AppTextStyles.medium(
      locale: locale,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: LightColorsPalate.onSurfaceColor,
    ),
    bodyLarge: AppTextStyles.regular(
      locale: locale,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: LightColorsPalate.chatTextColor,
    ),
    bodyMedium: AppTextStyles.regular(
      locale: locale,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: LightColorsPalate.chatTimeColor,
    ),
    bodySmall: AppTextStyles.regular(
      locale: locale,
      fontSize: 9,
      fontWeight: FontWeight.w400,
      color: LightColorsPalate.secondaryColor,
    ),
  );
}
