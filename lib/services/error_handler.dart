import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Global navigator key for showing dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Centralized error handling service
/// All errors should be caught and displayed through this service
class ErrorHandler {
  ErrorHandler._();

  /// Get the current context from navigator key
  static BuildContext? get _context => navigatorKey.currentContext;

  /// Show error modal dialog - MUST appear every time
  static void showErrorDialog(
    BuildContext? context, {
    required String message,
    String title = 'Something went wrong',
  }) {
    final ctx = context ?? _context;
    if (ctx == null) {
      debugPrint('ErrorHandler: No context available for dialog');
      return;
    }

    // Always use Navigator to show dialog to ensure it appears
    Navigator.of(ctx).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _ErrorDialog(
          title: title,
          message: message,
          isError: true,
        ),
      ),
    );
  }

  /// Show success message modal
  static void showSuccessDialog(
    BuildContext? context, {
    required String message,
    String title = 'Success',
  }) {
    final ctx = context ?? _context;
    if (ctx == null) return;

    Navigator.of(ctx).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _ErrorDialog(
          title: title,
          message: message,
          isError: false,
          isSuccess: true,
        ),
      ),
    );
  }

  /// Show info message modal
  static void showInfoDialog(
    BuildContext? context, {
    required String message,
    String title = 'Info',
  }) {
    final ctx = context ?? _context;
    if (ctx == null) return;

    Navigator.of(ctx).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _ErrorDialog(
          title: title,
          message: message,
          isError: false,
        ),
      ),
    );
  }

  /// Handle any exception and show appropriate error message
  static Future<void> handleException(
    BuildContext? context,
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

    // ALWAYS show the dialog
    if (context != null) {
      showErrorDialog(context, message: userMessage);
    } else if (_context != null) {
      showErrorDialog(_context, message: userMessage);
    } else {
      // Last resort - print to console
      debugPrint('ERROR MODAL: $userMessage');
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

/// Beautiful animated error/success dialog widget
class _ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final bool isError;
  final bool isSuccess;

  const _ErrorDialog({
    required this.title,
    required this.message,
    this.isError = true,
    this.isSuccess = false,
  });

  @override
  State<_ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<_ErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.isError
        ? Colors.red.shade600
        : widget.isSuccess
            ? Colors.green.shade600
            : Colors.blue.shade600;

    final IconData icon = widget.isError
        ? Icons.error_rounded
        : widget.isSuccess
            ? Icons.check_circle_rounded
            : Icons.info_rounded;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animated background
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // OK Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
