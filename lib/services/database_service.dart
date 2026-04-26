import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  DatabaseService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  static Future<void> createUserDocument({
    required String uid,
    required String name,
    required String email,
  }) {
    return _usersCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'isEmailVerified': false,
    });
  }

  static Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    final snapshot = await _usersCollection.doc(uid).get();
    return snapshot.data();
  }

  static Stream<Map<String, dynamic>?> watchUserDocument(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      return snapshot.data();
    });
  }

  static Future<bool> isUserEmailVerified(String uid) async {
    final user = await getUserDocument(uid);
    return user?['isEmailVerified'] == true;
  }
}
