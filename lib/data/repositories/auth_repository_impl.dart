import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmanager/domain/entities/user_entity.dart';
import 'package:taskmanager/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore; // Add Firestore

  AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn, this._firestore) {
    _firebaseAuth.setLanguageCode('en');
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    final User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      // Save user to Firestore
      await _saveUserToFirestore(firebaseUser);
    }

    return _userFromFirebase(firebaseUser);
  }

  @override
  Future<UserEntity?> signUpWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    log('signuwith email: ${userCredential.toString()}');
    final User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      // Save user to Firestore
      await _saveUserToFirestore(firebaseUser);
    }

    return _userFromFirebase(firebaseUser);
  }

  Future<void> _saveUserToFirestore(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? '',
      'photoUrl': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await userDoc.set(userData, SetOptions(merge: true));
  }

  @override
  Future<UserEntity?> loginWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return _userFromFirebase(userCredential.user);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  UserEntity? _userFromFirebase(User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
