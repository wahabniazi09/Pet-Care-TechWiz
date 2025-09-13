import 'package:flutter/material.dart';

Widget buildTextField(String label, TextEditingController controller,
    String? Function(String? value) validatePetName,
    {TextInputType inputType = TextInputType.text, maxLines}) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    keyboardType: inputType,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.yellow),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    validator: (value) =>
        value == null || value.isEmpty ? "Please enter $label" : null,
  );
}
