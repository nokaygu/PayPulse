import 'package:flutter/services.dart';

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) {
      return newValue;
    }

    if (RegExp(r'\s').hasMatch(newValue.text)) {
      return oldValue;
    }

    return newValue;
  }
}