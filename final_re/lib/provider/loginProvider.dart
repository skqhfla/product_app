import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  String loginType = '';
  bool _isGoogle = false;
  bool get isGooge => _isGoogle;
  isLoginType(loginType) {
    if (loginType == 'google') {
      _isGoogle = true;
    } else {
      _isGoogle = false;
    }
  }

  notifyListeners();
}
