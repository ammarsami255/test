import 'package:cloud_functions/cloud_functions.dart';

class EmailService {
  EmailService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<void> sendOtpEmail({required String email}) async {
    await _functions.httpsCallable('sendEmailOtp').call({
      'email': email,
    });
  }

  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await _functions.httpsCallable('verifyEmailOtp').call({
      'email': email,
      'otp': otp,
    });
  }
}
