import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showmaker/database/Show/show.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<String> createShow(Show show) async {
  try {
    var ref = await firestore.collection('shows').add(show.toDatabase());
    show.setId(ref.id);
    return "Completed";
  } on FirebaseException catch (e) {
    return e.toString();
  }
}

Future<String> updateShow(Show show) async {
  try {
    String id = show.getId()!;
    await firestore.collection('shows').doc(id).update(show.toDatabase());
    return "Completed";
  } on FirebaseException catch (e) {
    return e.toString();
  }
}

Future<Map<String, dynamic>> getShow(String id) async {
  Map<String, dynamic> data = {};
  try {
    data = (await firestore.collection('shows').doc(id).get()).data()!;
  } on FirebaseException catch (e) {
    data = {'Error': e.message};
  }
  return data;
}
