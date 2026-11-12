import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _formatGrouped(
      oldValue,
      newValue,
      maxDigits: 16,
      separator: ' ',
      groupSize: 4,
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _formatGrouped(
      oldValue,
      newValue,
      maxDigits: 4,
      separator: ' / ',
      groupSize: 2,
    );
  }
}

class TurkishCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;

    final text = newValue.text;

    // Boş değer ve "1500," gibi yazım sırasındaki ara durumlar kabul.
    if (!RegExp(r'^[0-9]{0,9}(?:,[0-9]{0,2})?$').hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }
}

TextEditingValue _formatGrouped(
  TextEditingValue oldValue,
  TextEditingValue newValue, {
  required int maxDigits,
  required String separator,
  required int groupSize,
}) {
  if (!newValue.composing.isCollapsed) return newValue;

  final digitPattern = RegExp(r'[0-9]');
  final nonDigitPattern = RegExp(r'[^0-9]');

  var digits = newValue.text.replaceAll(nonDigitPattern, '');

  final selectionEnd = newValue.selection.extentOffset
      .clamp(0, newValue.text.length)
      .toInt();

  var digitsBeforeCursor = digitPattern
      .allMatches(newValue.text.substring(0, selectionEnd))
      .length;

  final previousDigits = oldValue.text.replaceAll(nonDigitPattern, '');

  // Sadece ayırıcı silindiyse, geri silmenin takılmaması için
  // önceki rakamı da kaldır.
  if (newValue.text.length < oldValue.text.length &&
      digits == previousDigits &&
      digitsBeforeCursor > 0 &&
      newValue.selection.isCollapsed) {
    final index = digitsBeforeCursor - 1;

    digits = digits.replaceRange(index, index + 1, '');
    digitsBeforeCursor--;
  }

  if (digits.length > maxDigits) return oldValue;

  digitsBeforeCursor = digitsBeforeCursor.clamp(0, digits.length).toInt();

  final buffer = StringBuffer();
  var cursor = 0;

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && i % groupSize == 0) {
      buffer.write(separator);
    }

    buffer.write(digits[i]);

    if (i + 1 == digitsBeforeCursor) {
      cursor = buffer.length;
    }
  }

  return TextEditingValue(
    text: buffer.toString(),
    selection: TextSelection.collapsed(offset: cursor),
  );
}
