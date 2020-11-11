import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifire extends ChangeNotifier {
  final theme1 = ThemeData(
    primaryColor: Colors.red,
    buttonColor: Colors.red[400],
    accentColor: Color(0xFFB4B4B4),
    canvasColor: Color(0xFFFAE5E5),
    scaffoldBackgroundColor: Colors.white,
  );
  final theme2 = ThemeData(
    primaryColor: Colors.blue,
    buttonColor: Colors.blue[400],
    accentColor: Color(0xFFB4B4B4),
    canvasColor: Color(0xFFE9E5FA),
    scaffoldBackgroundColor: Colors.white,
  );

  bool _themeFlag = false;

  SharedPreferences _flagStorage;
  void init() async {
    _flagStorage = await SharedPreferences.getInstance();
    if (_flagStorage.containsKey("flag")) {
      _themeFlag = _flagStorage.getBool("flag");
    } else {
      _flagStorage.setBool("flag", false);
    }
    notifyListeners();
  }

  bool get flag => _themeFlag;

  void toggleTheme() {
    _themeFlag = !_themeFlag;

    _flagStorage.setBool("flag", _themeFlag);
    notifyListeners();
  }
}
