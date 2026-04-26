import 'package:flutter/material.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
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
