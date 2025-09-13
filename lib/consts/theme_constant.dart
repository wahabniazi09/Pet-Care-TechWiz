import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color.fromRGBO(49, 39, 79, 1);
  static const Color secondaryColor = Color.fromRGBO(196, 135, 198, 1);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF333333);
  
  static ButtonStyle buttonStyle({double fontSize = 14}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(fontSize: fontSize),
    );
  }
  
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
  
  static EdgeInsets screenPadding(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 16 : 20,
      vertical: isSmallScreen ? 12 : 16,
    );
  }
  
  static double responsiveFontSize(BuildContext context, 
      {double small = 14, double large = 16}) {
    return MediaQuery.of(context).size.width < 600 ? small : large;
  }
}