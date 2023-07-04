import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:showmaker/database/User/user.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<User1?> getUser(String id) async {
  User1? user1;
  try {
    var ref = await firestore
        .collection('users')
        .where("firebaseId", isEqualTo: id)
        .get();

    if (ref.size == 0) return null;

    user1 = User1.fromDatabase(ref.docs[0].data());
    user1.setId(ref.docs[0].id);
    // ignore: unused_catch_clause
  } on FirebaseException catch (e) {}
  return user1;
}

Future<User1?> createUser(User user) async {
  User1? user1;
  try {
    user1 = User1(user.uid, user.displayName ?? "null", user.photoURL ?? "");

    var ref =
        await (await firestore.collection('users').add(user1.toDatabase()))
            .get();
    if (!ref.exists) return null;

    user1 = User1.fromDatabase(ref.data()!);
    user1.setId(ref.id);
    // ignore: unused_catch_clause
  } on FirebaseException catch (e) {}
  return user1;
}
