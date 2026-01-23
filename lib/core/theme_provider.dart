import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytelling_audio_app/core/theme_data.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = false;
  
  bool get isDark => _isDarkTheme;
  ThemeData get currentTheme => _isDarkTheme ? darkTheme : lightTheme;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkTheme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }
}