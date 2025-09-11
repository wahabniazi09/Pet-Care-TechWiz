import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';

Widget petDropdown(String hint, List<String> list, String dropvalue,
    Function(String) onChanged) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: whiteColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton(
        hint: Text(
          hint,
          style: TextStyle(color: darkFontGrey),
        ),
        value: list.contains(dropvalue) ? dropvalue : null,
        items: list.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value.toString());
          }
        },
        isExpanded: true,
      ),
    ),
  );
}
