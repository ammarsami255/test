import 'package:flutter/material.dart';

import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/screens/otp_verification_screen.dart';
import 'package:el_moza3/services/auth_service.dart';
import 'package:el_moza3/services/error_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String id = 'RegisterScreen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirmPassword = _confirmCtrl.text;

    // Show validation errors via modal
    final nameError = AuthService.validateName(name);
    if (nameError != null) {
      ErrorHandler.showErrorDialog(context, message: nameError);
      return;
    }

    final emailError = AuthService.validateEmail(email);
    if (emailError != null) {
      ErrorHandler.showErrorDialog(context, message: emailError);
      return;
    }

    final passwordError = AuthService.validatePassword(password);
    if (passwordError != null) {
      ErrorHandler.showErrorDialog(context, message: passwordError);
      return;
    }

    if (password != confirmPassword) {
      ErrorHandler.showErrorDialog(
        context,
        message: 'كلمتا المرور غير متطابقتين',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (!result.isSuccess) {
        ErrorHandler.showErrorDialog(
          context,
          message: result.errorMessage ?? 'Registration failed',
        );
        return;
      }

      if (result.infoMessage != null) {
        ErrorHandler.showInfoDialog(
          context,
          message: result.infoMessage!,
          title: 'Note',
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ErrorHandler.handleException(context, e);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "إنشاء حساب",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive padding based on screen width
          final screenWidth = constraints.maxWidth;
          final isTablet = screenWidth >= 600;
          final isDesktop = screenWidth >= 900;
          
          final horizontalPadding = isDesktop
              ? 100.0
              : isTablet
                  ? 60.0
                  : 20.0;
          final maxWidth = isDesktop ? 450.0 : (isTablet ? 400.0 : double.infinity);

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _field(_nameCtrl, "الاسم الكامل", Icons.person_outline),
                    const SizedBox(height: 14),
                    _field(_emailCtrl, "البريد الإلكتروني", Icons.email_outlined),
                    const SizedBox(height: 14),
                    _field(_phoneCtrl, "رقم الموبايل", Icons.phone_outlined),
                    const SizedBox(height: 14),
                    _field(
                      _passCtrl,
                      "كلمة المرور",
                      Icons.lock_outline,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _confirmCtrl,
                      "تأكيد كلمة المرور",
                      Icons.lock_outline,
                      obscure: _obscure,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "إنشاء الحساب",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
