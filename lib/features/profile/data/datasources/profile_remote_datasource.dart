import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 10));
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
  }
}
