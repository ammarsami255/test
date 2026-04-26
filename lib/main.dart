import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/firebase_options.dart';
import 'package:el_moza3/screens/main_screen.dart';
import 'package:el_moza3/screens/otp_verification_screen.dart';
import 'package:el_moza3/screens/register_screen.dart';
import 'package:el_moza3/widget/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ElMoza3App());
}

class ElMoza3App extends StatelessWidget {
  const ElMoza3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الموزّع',
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background2,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ar', 'SA'),
      home: const MainScreen(),
      routes: <String, WidgetBuilder>{
        MainScreen.id: (context) => const MainScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegisterScreen.id: (context) => const RegisterScreen(),
        OtpVerificationScreen.id: (context) {
          final email =
              ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return OtpVerificationScreen(email: email);
        },
      },
    );
  }
}
