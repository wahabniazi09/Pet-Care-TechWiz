import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotifier {
  static void showSnack(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(isSmallScreen ? 10 : 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void handleAuthError(BuildContext context, FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = "This email is already registered. Please login instead.";
        break;
      case 'weak-password':
        message = "Your password is too weak. Try a stronger one.";
        break;
      case 'invalid-email':
        message = "Please enter a valid email address.";
        break;
      case 'network-request-failed':
        message = "No internet connection. Please check your network.";
        break;
      case 'user-not-found':
        message = "No user found with this email.";
        break;
      case 'wrong-password':
        message = "Incorrect password. Please try again.";
        break;
      case 'user-disabled':
        message = "This account has been disabled. Contact support.";
        break;
      case 'too-many-requests':
        message = "Too many attempts. Try again later.";
        break;
      default:
        message = e.message ?? "Authentication failed. Please try again.";
    }

    showSnack(context, message: message, isError: true);
  }

  static void handleError(BuildContext context, Object error) {
    if (error is FirebaseAuthException) {
      handleAuthError(context, error);
    } else {
      showSnack(
        context,
        message: "Something went wrong. Please try again.",
        isError: true,
      );
    }
  }
}