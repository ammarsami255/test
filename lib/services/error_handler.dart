import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized error handling service
/// All errors should be caught and displayed through this service
class ErrorHandler {
  ErrorHandler._();

  /// Show error modal dialog
  /// This replaces all SnackBars and raw error displays
  static void showErrorDialog(
    BuildContext context, {
    required String message,
    String title = 'Error',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade600,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success message dialog
  static void showSuccessDialog(
    BuildContext context, {
    required String message,
    String title = 'Success',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green.shade600,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show info message dialog
  static void showInfoDialog(
    BuildContext context, {
    required String message,
    String title = 'Info',
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.blue.shade600,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle any exception and show appropriate error message
  static Future<void> handleException(
    BuildContext context,
    dynamic error,
  ) async {
    // Log the error for debugging
    debugPrint('ErrorHandler caught: $error');

    String userMessage;

    if (error is FirebaseAuthException) {
      userMessage = _mapAuthError(error.code);
    } else if (error is FirebaseException) {
      userMessage = _mapFirestoreError(error.code);
    } else if (error is FormatException) {
      userMessage = 'Invalid data format. Please check your input.';
    } else if (error is NetworkException) {
      userMessage = 'Network error. Please check your internet connection.';
    } else if (error is Exception) {
      // Generic exception - show user-friendly message
      userMessage = 'Something went wrong. Please try again.';
    } else {
      userMessage = 'An unexpected error occurred. Please try again.';
    }

    if (context.mounted) {
      showErrorDialog(context, message: userMessage);
    }
  }

  /// Map Firebase Auth error codes to user-friendly messages
  static String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'expired-verification-code':
        return 'Verification code has expired.';
      case 'session-expired':
        return 'Your session has expired. Please log in again.';
      case 'credential-already-in-use':
        return 'This credential is already in use.';
      case 'provider-already-linked':
        return 'This account is already linked.';
      default:
        return 'Authentication error. Please try again.';
    }
  }

  /// Map Firestore error codes to user-friendly messages
  static String _mapFirestoreError(String code) {
    switch (code) {
      case 'aborted':
        return 'The operation was aborted.';
      case 'already-exists':
        return 'This record already exists.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'data-loss':
        return 'Data loss occurred.';
      case 'deadline-exceeded':
        return 'The operation took too long.';
      case 'internal':
        return 'Internal error occurred.';
      case 'not-found':
        return 'The requested document was not found.';
      case 'permission-denied':
        return 'Permission denied.';
      case 'resource-exhausted':
        return 'Resource limit exceeded.';
      case 'unauthenticated':
        return 'Please log in to continue.';
      case 'unavailable':
        return 'Service is temporarily unavailable.';
      case 'unknown':
        return 'An unknown error occurred.';
      default:
        return 'Database error. Please try again.';
    }
  }
}

/// Custom exception for network errors
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => message;
}