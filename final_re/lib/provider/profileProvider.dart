import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isEdit = true;
  String _buttonText = '';
  bool get isEdit => _isEdit;
  String get buttonText => _buttonText;

  changeIsEdit() {
    if (_isEdit == false) {
      _isEdit = true;
    } else {
      _isEdit = false;
    }
    notifyListeners();
  }
}
