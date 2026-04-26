import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListingService {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Map<String, dynamic>>> getListings({String? category}) {
    Query query = _db
        .collection('listings')
        .orderBy('createdAt', descending: true);

    if (category != null && category != 'الكل') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList(),
    );
  }

  static Stream<List<Map<String, dynamic>>> getMyListings() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('listings')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  static Future<String?> addListing({
    required String title,
    required String description,
    required String category,
    required String type,
    required String price,
    required String location,
    required String phone,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _db.collection('listings').add({
        'title': title,
        'description': description,
        'category': category,
        'type': type,
        'price': price,
        'location': location,
        'phone': phone,
        'userId': user.uid,
        'userName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'فشل النشر، حاول تاني';
    }
  }

  static Future<void> deleteListing(String id) async {
    await _db.collection('listings').doc(id).delete();
  }
}
