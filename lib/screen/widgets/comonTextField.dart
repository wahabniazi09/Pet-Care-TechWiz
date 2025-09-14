import 'package:flutter/material.dart';
import 'package:pet_care/screen/widgets/snackBar.dart';

Widget buildTextField(String label, TextEditingController controller,
    String? Function(String? value) validator,
    {TextInputType inputType = TextInputType.text, 
     int? maxLines,
     TextAlign textAlign = TextAlign.start}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 600;
      
      return TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: inputType,
        maxLines: maxLines,
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.yellow),
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          ),
          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          errorStyle: TextStyle(fontSize: isSmallScreen ? 12 : 14),
        ),
        validator: (value) {
          final error = validator(value);
          if (error != null) {
            AppNotifier.showSnack(
              context,
              message: error,
              isError: true,
            );
          }
          return error;
        },
      );
    },
  );
}