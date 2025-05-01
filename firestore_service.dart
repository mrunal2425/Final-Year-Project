import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUserToFirestore(User user, String role) async {
    await _db.collection("users").doc(user.uid).set({
      "name": user.displayName,
      "email": user.email,
      "role": role,  // Either 'admin' or 'user'
    });
  }

  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection("users").doc(uid).get();
    return doc.exists ? doc.get("role") : null;
  }
}