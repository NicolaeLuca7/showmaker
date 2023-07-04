import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showmaker/database/ShowPreview/showPreview.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<String> createPreview(ShowPreview preview) async {
  try {
    var res =
        await firestore.collection('showsPreviews').add(preview.toDatabase());
    preview.setId(res.id);
    return "Completed";
  } on FirebaseException catch (e) {
    return e.message ?? 'Error!';
  }
}

Future<String> updatePreview(ShowPreview preview) async {
  try {
    await firestore
        .collection('showsPreviews')
        .doc(preview.getId())
        .update(preview.toDatabase());
    return "Completed";
  } on FirebaseException catch (e) {
    return e.message ?? 'Error!';
  }
}
