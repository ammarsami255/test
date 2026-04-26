import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'email_service.dart';

class OtpService {
  OtpService._();

  static final RegExp _otpRegex = RegExp(r'^\d{6}$');

  static String? validateOtp(String otp) {
    final value = otp.trim();
    if (value.isEmpty) {
      return 'Please enter the 6-digit code.';
    }
    if (!_otpRegex.hasMatch(value)) {
      return 'OTP must be exactly 6 digits.';
    }
    return null;
  }

  static Future<void> sendOtp({String? email}) async {
    final targetEmail = email?.trim() ?? FirebaseAuth.instance.currentUser?.email;
    if (targetEmail == null || targetEmail.isEmpty) {
      throw const FormatException('No email address is available for OTP.');
    }
    await EmailService.sendOtpEmail(email: targetEmail);
  }

  static Future<void> verifyOtp(String otp, {String? email}) async {
    final otpError = validateOtp(otp);
    if (otpError != null) {
      throw FormatException(otpError);
    }

    final targetEmail = email?.trim() ?? FirebaseAuth.instance.currentUser?.email;
    if (targetEmail == null || targetEmail.isEmpty) {
      throw const FormatException('No email address is available for OTP.');
    }

    await EmailService.verifyOtp(email: targetEmail, otp: otp.trim());
  }

  static String mapError(Object error) {
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'invalid-argument':
          return error.message ?? 'Please check the OTP and try again.';
        case 'unauthenticated':
          return 'Please sign in again to continue.';
        case 'not-found':
          return 'No active OTP was found. Please request a new code.';
        case 'deadline-exceeded':
          return 'The OTP expired. Please request a new code.';
        case 'permission-denied':
          return error.message ?? 'This action is not allowed.';
        default:
          return error.message ?? 'OTP verification failed. Please try again.';
      }
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Something went wrong while processing the OTP.';
  }
}
