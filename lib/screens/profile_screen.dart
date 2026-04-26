import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/services/auth_service.dart';
import 'package:el_moza3/services/listing_service.dart';

class ProfileScreen extends StatelessWidget {
  final Future<void> Function() onRequireLogin;
  final bool hasVerifiedSession;

  const ProfileScreen({
    super.key,
    required this.onRequireLogin,
    required this.hasVerifiedSession,
  });
void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد من تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("تسجيل الخروج"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return _buildGuest(context);
        if (!hasVerifiedSession) return _buildPendingVerification(context, user);
        return _buildProfile(context, user);
      },
    );
  }

  Widget _buildGuest(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "سجّل دخولك لعرض حسابك",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "محتاج تسجيل دخول عشان تشوف بروفايلك وإعلاناتك",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: onRequireLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      "تسجيل الدخول",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingVerification(BuildContext context, User user) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "فعّل بريدك الإلكتروني للمتابعة",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "أرسلنا كود مكوّن من 6 أرقام إلى بريدك. فعّله لفتح الحساب.",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: onRequireLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      "تفعيل الآن",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName ?? "مستخدم",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ListingService.getMyListings(),
                      builder: (context, snap) {
                        final count = snap.data?.length ?? 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _stat("$count", "إعلاناتي"),
                            Container(
                              width: 1,
                              height: 30,
                              color: AppColors.border,
                            ),
                            _stat("0", "مشاهدة"),
                            Container(
                              width: 1,
                              height: 30,
                              color: AppColors.border,
                            ),
                            _stat("0", "رسائل"),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Column(
                  children: [
                    _menuItem(
                      Icons.campaign_outlined,
                      "إعلاناتي",
                      onTap: () {},
                    ),
                    _divider(),
                    _menuItem(
                      Icons.favorite_outline_rounded,
                      "المحفوظات",
                      onTap: () {},
                    ),
                    _divider(),
                    _menuItem(
                      Icons.notifications_none_rounded,
                      "الإشعارات",
                      onTap: () {},
                    ),
                    _divider(),
                    _menuItem(
                      Icons.help_outline_rounded,
                      "المساعدة",
                      onTap: () {},
                    ),
                    _divider(),
                    _menuItem(
                      Icons.logout_rounded,
                      "تسجيل الخروج",
                      color: Colors.red,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    ],
  );

  Widget _menuItem(
    IconData icon,
    String label, {
    Color? color,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: color ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: color ?? AppColors.textSecondary,
          ),
        ],
      ),
    ),
  );

  Widget _divider() => const Divider(
    height: 1,
    color: AppColors.border,
    indent: 16,
    endIndent: 16,
  );
}
