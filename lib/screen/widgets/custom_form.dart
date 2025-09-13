import 'package:flutter/material.dart';

Widget CustomTextField({
  required TextEditingController controller,
  required String hint,
  bool obscure = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey)),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint cannot be empty";
        }
        return null;
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    ),
  );
}
