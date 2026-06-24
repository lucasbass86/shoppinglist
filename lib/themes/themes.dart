import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/enums.dart';
import 'package:shoppinglist/utils/utils.dart';

ThemeData themeVerde = ThemeData.light().copyWith(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Utils.claro,
    primary: Utils.claro,
  ),
  inputDecorationTheme: InputDecorationTheme(
    // border: InputBorder.none,
    // disabledBorder: InputBorder.none,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
  ),
  textTheme: TextTheme(
    titleLarge: const TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
    //INPUTBOX
    titleMedium: TextStyle(fontSize: 25, color: Utils.oscuro),
    bodySmall: TextStyle(fontSize: 13, color: Utils.oscuro),
    bodyLarge: TextStyle(fontSize: 25, color: Utils.oscuro),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Utils.oscuro,
    shape: const StadiumBorder(),
    behavior: SnackBarBehavior.floating,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Utils.oscuro,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.medio),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
    trackColor: WidgetStateProperty.resolveWith((states) => Utils.claro),
    trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Utils.medio,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);

ThemeData themeNatural = ThemeData.light().copyWith(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Utils.claro,
    primary: Utils.claro,
  ),
  inputDecorationTheme: InputDecorationTheme(
    // border: InputBorder.none,
    // disabledBorder: InputBorder.none,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
  ),
  textTheme: TextTheme(
    titleLarge: const TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
    //INPUTBOX
    titleMedium: TextStyle(fontSize: 25, color: Utils.oscuro),
    bodySmall: TextStyle(fontSize: 13, color: Utils.oscuro),
    bodyLarge: TextStyle(fontSize: 25, color: Utils.oscuro),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Utils.oscuro,
    shape: const StadiumBorder(),
    behavior: SnackBarBehavior.floating,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Utils.oscuro,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.medio),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
    trackColor: WidgetStateProperty.resolveWith((states) => Utils.claro),
    trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Utils.medio,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);

ThemeData themeAzul = ThemeData.light().copyWith(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Utils.claro,
    primary: Utils.claro,
  ),
  inputDecorationTheme: InputDecorationTheme(
    // border: InputBorder.none,
    // disabledBorder: InputBorder.none,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
  ),
  textTheme: TextTheme(
    titleLarge: const TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
    //INPUTBOX
    titleMedium: TextStyle(fontSize: 25, color: Utils.oscuro),
    bodyLarge: TextStyle(fontSize: 25, color: Utils.oscuro),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Utils.oscuro,
    shape: const StadiumBorder(),
    behavior: SnackBarBehavior.floating,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Utils.oscuro,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.medio),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
    trackColor: WidgetStateProperty.resolveWith((states) => Utils.claro),
    trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Utils.medio,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);

ThemeData themeDark = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Utils.claro,
    primary: Utils.claro,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Utils.oscuro),
    ),
  ),
  textTheme: TextTheme(
    titleLarge: const TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
    //INPUTBOX
    bodyLarge: TextStyle(fontSize: 25, color: Utils.oscuro),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Utils.oscuro,
    shape: const StadiumBorder(),
    behavior: SnackBarBehavior.floating,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Utils.oscuro,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Utils.claro; // cuando está presionado
        }
        return Utils.oscuro;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) => Utils.medio),
      overlayColor: WidgetStateProperty.resolveWith((states) => Utils.oscuro),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
    trackColor: WidgetStateProperty.resolveWith((states) => Utils.claro),
    trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Utils.oscuro : Utils.medio),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Utils.medio,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);

ThemeData getTheme(ETheme eTheme) {
  switch (eTheme) {
    case ETheme.verde:
      return themeVerde;
    case ETheme.natural:
      return themeNatural;
    case ETheme.azul:
      return themeAzul;
    case ETheme.dark:
      return themeDark;
  }
}
