import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotifier {
  static void showSnack(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
      default:
        message = e.message ?? "Authentication failed. Please try again.";
    }

    showSnack(context, message: message, isError: true);
  }

  static void handleError(BuildContext context, Object error) {
    showSnack(
      context,
      message: "Something went wrong. Please try again.",
      isError: true,
    );
  }
}
