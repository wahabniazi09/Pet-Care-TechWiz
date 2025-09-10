import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';

Widget PetCustomTextField(
    {required String label,
    required String hint,
    required TextEditingController controller,
    bool ispass = false,
    validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: whiteColor,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 5),
      TextFormField(
        validator: validator,
        obscureText: ispass,
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: whiteColor,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          filled: true,
          fillColor: Colors.white10,
          isDense: true,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
