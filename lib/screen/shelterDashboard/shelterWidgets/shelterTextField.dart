import 'package:flutter/material.dart';

Widget buildTextField(String label, TextEditingController controller,
    String? Function(String?) validator) {
  return TextFormField(
    controller: controller,
    validator: validator,
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
