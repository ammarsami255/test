import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/screens/add_service_screen.dart';
import 'package:el_moza3/screens/chat_screen.dart';
import 'package:el_moza3/screens/otp_verification_screen.dart';
import 'package:el_moza3/screens/profile_screen.dart';
import 'package:el_moza3/screens/search_screen.dart';
import 'package:el_moza3/screens/services_screen.dart';
import 'package:el_moza3/services/auth_service.dart';
import 'package:el_moza3/services/database_service.dart';
import 'package:el_moza3/widget/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static String id = "MainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Future<void> requireLogin() async {
    if (AuthService.currentUser == null) {
      await Navigator.pushNamed(context, LoginScreen.id);
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final isVerified = await AuthService.isCurrentUserVerified();
    if (!isVerified && mounted) {
      final email = AuthService.currentUser?.email;
      if (email != null && email.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _onAddTap() async {
    await requireLogin();
    if (await AuthService.isCurrentUserVerified()) {
      setState(() => _currentIndex = 2);
    }
  }

  Future<void> _onNavTap(int index) async {
    if (index == 2 || index == 3) {
      await requireLogin();
      if (!await AuthService.isCurrentUserVerified()) return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return _buildScaffold(false);
        }

        return StreamBuilder<Map<String, dynamic>?>(
          stream: DatabaseService.watchUserDocument(user.uid),
          builder: (context, profileSnapshot) {
            final hasVerifiedSession =
                profileSnapshot.data?['isEmailVerified'] == true;
            return _buildScaffold(hasVerifiedSession);
          },
        );
      },
    );
  }

  Widget _buildScaffold(bool hasVerifiedSession) {
    final screens = [
      ServicesScreen(onRequireLogin: requireLogin),
      SearchScreen(onRequireLogin: requireLogin),
      hasVerifiedSession ? const AddServiceScreen() : const SizedBox(),
      hasVerifiedSession ? const ChatScreen() : const SizedBox(),
      ProfileScreen(
        onRequireLogin: requireLogin,
        hasVerifiedSession: hasVerifiedSession,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _navItem(0, Icons.home_rounded, "الرئيسية"),
                _navItem(1, Icons.search_rounded, "بحث"),
                _addButton(),
                _navItem(3, Icons.chat_bubble_outline_rounded, "رسائل"),
                _navItem(4, Icons.person_outline_rounded, "حسابي"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _onAddTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
