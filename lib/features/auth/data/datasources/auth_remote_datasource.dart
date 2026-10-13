import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swasthsetu/features/auth/data/models/user_model.dart';

/// Remote data source: Firebase Auth (Google) + Cloud Firestore (user docs).
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static const String _usersCollection = 'users';

  // ── Google Sign-In ────────────────────────────────────────────────────────

  /// Signs in using Google.
  /// Returns the authenticated Firebase [User].
  Future<User> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled by the user');
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final result = await _auth.signInWithCredential(credential);
    
    if (result.user == null) {
      throw Exception('No user returned after Google sign-in');
    }
    
    return result.user!;
  }

  // ── Firestore ────────────────────────────────────────────────────────────

  /// Returns true if a Firestore user document exists for [uid].
  Future<bool> userExists({required String uid}) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    return doc.exists;
  }

  /// Creates a minimal user document in Firestore.
  Future<UserModel> createUser({required UserModel user}) async {
    final data = user.toFirestore();
    await _firestore.collection(_usersCollection).doc(user.uid).set(data);
    return user;
  }

  /// Fetches a user document from Firestore.
  Future<UserModel> getUser({required String uid}) async {
    final doc = await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data()!,
          toFirestore: (data, _) => data,
        )
        .get();

    if (!doc.exists) throw Exception('User $uid not found in Firestore');

    // Use the raw DocumentSnapshot approach for UserModel.fromFirestore
    final rawDoc = await _firestore.collection(_usersCollection).doc(uid).get();
    return UserModel.fromFirestore(rawDoc);
  }

  /// Updates the lastLoginAt field for [uid].
  Future<void> updateLastLogin({required String uid}) async {
    await _firestore.collection(_usersCollection).doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Signs out of Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Returns the currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;
}
