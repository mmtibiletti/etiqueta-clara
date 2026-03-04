import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class UserProfileService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(profile.toJson());
  }

  Future<UserProfile?> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
    await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return UserProfile.fromJson(doc.data()!);
  }

  Stream<UserProfile?> profileStream() {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {

      if (!doc.exists) return null;

      return UserProfile.fromJson(doc.data()!);

    });

  }

}