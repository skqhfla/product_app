import 'package:flutter/material.dart';

class DropDownProvider extends ChangeNotifier {
  bool _isASC = true;
  bool get isASC => _isASC;

  isType(String _typeValue) {
    if (_typeValue == 'ASC') {
      _isASC = true;
    } else {
      _isASC = false;
    }
    notifyListeners();
  }
}
