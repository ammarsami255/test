import 'package:flutter/material.dart';

import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/screens/forgot_password_screen.dart';
import 'package:el_moza3/screens/main_screen.dart';
import 'package:el_moza3/screens/otp_verification_screen.dart';
import 'package:el_moza3/screens/register_screen.dart';
import 'package:el_moza3/services/auth_service.dart';
import 'package:el_moza3/services/error_handler.dart';
import 'package:el_moza3/utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String id = "LoginScreen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    // Show validation errors via modal
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

    setState(() => _loading = true);

    try {
      final result = await AuthService.login(email: email, password: password);

      if (!mounted) return;
      setState(() => _loading = false);

      if (!result.isSuccess) {
        ErrorHandler.showErrorDialog(
          context,
          message: result.errorMessage ?? 'Login failed',
        );
        return;
      }

      if (result.requiresOtp) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
        return;
      }

      Navigator.pushReplacementNamed(context, MainScreen.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ErrorHandler.handleException(context, e);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
    });

    try {
      final result = await AuthService.signInWithGoogle();

      if (!mounted) return;
      setState(() => _googleLoading = false);

      if (!result.isSuccess) {
        ErrorHandler.showErrorDialog(context, message: result.errorMessage ?? 'Google sign-in failed');
        return;
      }

      Navigator.pushReplacementNamed(context, MainScreen.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _googleLoading = false);
      ErrorHandler.handleException(context, e);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background1, AppColors.background2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= ResponsiveUtils.tabletBreakpoint;
              
              if (isDesktop) {
                return _buildDesktopLayout();
              }
              return _buildMobileLayout();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            const SizedBox(height: 20),
            const Text(
              "منصة الموزع",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            const Text(
              "سجّل دخولك للمتابعة",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 40),
            _buildFormFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),
              const SizedBox(height: 24),
              const Text(
                "منصة الموزع",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "سجّل دخولك للمتابعة",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildFormFields(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: const Icon(
        Icons.storefront,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _field(
          _emailCtrl,
          "البريد الإلكتروني",
          Icons.email_outlined,
          false,
        ),
        const SizedBox(height: 15),
        _field(
          _passCtrl,
          "كلمة المرور",
          Icons.lock_outline,
          _obscure,
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ForgotPasswordScreen(),
              ),
            ),
            child: const Text(
              "نسيت كلمة المرور؟",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadius,
                ),
              ),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Google Sign-In Button
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: _googleLoading ? null : _signInWithGoogle,
            icon: _googleLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.g_mobiledata, size: 28),
            label: Text(
              _googleLoading ? 'جاري...' : 'تسجيل عبر Google',
              style: const TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: const Text(
                "إنشاء حساب",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            const Text(
              "ليس لديك حساب؟",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    bool obscure, {
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
