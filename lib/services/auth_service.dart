import 'package:firebase_auth/firebase_auth.dart';

import 'database_service.dart';
import 'otp_service.dart';

class AuthResult {
  const AuthResult._({
    this.errorMessage,
    this.infoMessage,
    this.requiresOtp = false,
  });

  final String? errorMessage;
  final String? infoMessage;
  final bool requiresOtp;

  bool get isSuccess => errorMessage == null;

  factory AuthResult.success({String? infoMessage, bool requiresOtp = false}) {
    return AuthResult._(
      infoMessage: infoMessage,
      requiresOtp: requiresOtp,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(errorMessage: errorMessage);
  }
}

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    final nameError = validateName(trimmedName);
    if (nameError != null) {
      return AuthResult.failure(nameError);
    }

    final emailError = validateEmail(trimmedEmail);
    if (emailError != null) {
      return AuthResult.failure(emailError);
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      await credential.user!.updateDisplayName(trimmedName);
      await DatabaseService.createUserDocument(
        uid: credential.user!.uid,
        name: trimmedName,
        email: trimmedEmail,
      );

      try {
        await OtpService.sendOtp(email: trimmedEmail);
      } catch (_) {
        return AuthResult.success(
          requiresOtp: true,
          infoMessage:
              'Account created, but the OTP could not be sent automatically. Please resend the code from the verification screen.',
        );
      }

      return AuthResult.success(requiresOtp: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    } catch (_) {
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      return AuthResult.failure('Unable to complete sign up. Please try again.');
    }
  }

  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();

    final emailError = validateEmail(trimmedEmail);
    if (emailError != null) {
      return AuthResult.failure(emailError);
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      return AuthResult.failure(passwordError);
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final isVerified = await DatabaseService.isUserEmailVerified(
        credential.user!.uid,
      );
      return AuthResult.success(requiresOtp: !isVerified);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<String?> sendPasswordReset(String email) async {
    final trimmedEmail = email.trim();
    final emailError = validateEmail(trimmedEmail);
    if (emailError != null) {
      return emailError;
    }

    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  static Future<bool> isCurrentUserVerified() async {
    final user = currentUser;
    if (user == null) {
      return false;
    }
    return DatabaseService.isUserEmailVerified(user.uid);
  }

  static String? validateName(String value) {
    if (value.isEmpty) {
      return 'Please enter your name.';
    }
    return null;
  }

  static String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email.';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'user-not-found':
        return 'No account was found for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many requests. Please try again in a moment.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
