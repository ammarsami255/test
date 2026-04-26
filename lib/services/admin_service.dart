import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminService {
  AdminService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult();
    return token.claims?['admin'] == true;
  }

  static Future<bool> verifyAdminPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await _functions.httpsCallable('verifyAdminPassword').call({
      'password': password,
    });
    await user.getIdToken(true);
    return isAdmin();
  }

  static Future<bool> requireAdmin(BuildContext context) async {
    if (await isAdmin()) return true;

    final controller = TextEditingController();
    bool submitting = false;
    String? errorText;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> submit() async {
              final value = controller.text;
              if (value.isEmpty) {
                setState(() => errorText = 'Enter admin password.');
                return;
              }
              setState(() {
                submitting = true;
                errorText = null;
              });
              try {
                final isOk = await verifyAdminPassword(value);
                if (context.mounted) Navigator.pop(context, isOk);
              } catch (e) {
                setState(() {
                  submitting = false;
                  errorText = _mapError(e);
                });
              }
            }

            return AlertDialog(
              title: const Text('Admin Access'),
              content: TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Admin password',
                  errorText: errorText,
                ),
                onSubmitted: (_) => submit(),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting ? null : submit,
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return ok == true;
  }

  static String _mapError(Object error) {
    if (error is FirebaseFunctionsException) {
      return error.message ?? 'Admin verification failed.';
    }
    return 'Admin verification failed.';
  }
}
