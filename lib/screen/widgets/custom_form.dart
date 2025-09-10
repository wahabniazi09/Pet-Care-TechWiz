import 'package:flutter/material.dart';

Widget CustomTextField({String? label, String? hint, controller,ispass,validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label!,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      TextFormField(
        validator: validator,
        obscureText: ispass ,
          controller: controller,
          decoration: InputDecoration(
              hintStyle:  TextStyle(
                color: Colors.grey[400],
                fontSize: 14
              ),
              // prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),  
              hintText: hint,
              isDense: true,
              // filled: true,
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent)))),
      SizedBox(
        height: 10,
      )
    ],
  );
}
