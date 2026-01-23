import 'package:flutter/material.dart';

// LIGHT THEME
ThemeData lightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Colors.white,
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
    fontFamily: 'SF Pro'
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          }
          return Colors.black;
        },
      ),
    )
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    hintStyle: TextStyle(
      fontSize: 16,
      color: Color(0xFFB3B3B3)
    ),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Color(0xFFB3B3B3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.black)
    )
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    trackColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Color.fromRGBO(0, 85, 255, 1);
      }
      return Color.fromARGB(255, 213, 208, 214);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return Colors.transparent;
    }),
  ),
);

// DARK THEME
ThemeData darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Color.fromRGBO(26, 26, 30, 1),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
    fontFamily: 'SF Pro'
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          }
          return Colors.white;
        },
      ),
    )
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    hintStyle: TextStyle(
      fontSize: 16,
      color: Color(0xFFB3B3B3)
    ),
    filled: true,
    fillColor: Colors.grey[900],
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Color(0xFFB3B3B3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.black)
    )
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    trackColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Color.fromRGBO(0, 85, 255, 1);
      }
      return Color.fromARGB(255, 70, 69, 71);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return Colors.transparent;
    }),
  )
);
