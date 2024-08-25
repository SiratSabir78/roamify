import 'package:flutter/material.dart';

class SettingsModel extends ChangeNotifier {
  bool _darkMode = false;
  double _fontSize = 14.0;

  bool get darkMode => _darkMode;
  double get fontSize => _fontSize;
  Color get textColor => _darkMode ? Colors.white : Colors.black;
  Color get iconColor => _darkMode ? Colors.white : Colors.black;

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }

  // Notifications setting
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
