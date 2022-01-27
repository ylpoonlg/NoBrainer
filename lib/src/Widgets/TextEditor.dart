import 'package:flutter/material.dart';

class TextEditor {
  static TextEditingController getController(text) {
    var controller = TextEditingController();
    controller.text = text;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    return controller;
  }
}
