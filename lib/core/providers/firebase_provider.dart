import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider que expone la instancia de FirebaseAuth.
/// 
/// Este provider proporciona acceso a Firebase Authentication
/// en toda la aplicación usando Riverpod.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider que expone la instancia de FirebaseFirestore.
/// 
/// Este provider proporciona acceso a Cloud Firestore
/// en toda la aplicación usando Riverpod.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

