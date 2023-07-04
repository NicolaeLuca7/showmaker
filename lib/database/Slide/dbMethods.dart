import 'dart:core';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:showmaker/database/Slide/slide.dart';

final storageRef = FirebaseStorage.instance.ref();

List<Map<String, dynamic>> slidesToDatabase(List<Slide> slides) {
  List<Map<String, dynamic>> list = [];
  for (Slide slide in slides) list.add(slide.toDatabase());
  return list;
}

List<Slide> slidesFromDatabase(List<Map<String, dynamic>> list) {
  List<Slide> slides = [];
  for (var data in list) slides.add(Slide.fromDatabase(data));
  return slides;
}

Future<List<String>> uploadSlidesImages(
    List<Uint8List> data, String showId) async {
  List<String> urls = [];
  try {
    for (int i = 0; i < data.length; i++) {
      final imageRef = storageRef.child(showId + '{$i}');
      await imageRef.putData(data[i]);
      urls.add(await imageRef.getDownloadURL());
    }
    // ignore: unused_catch_clause
  } on FirebaseException catch (e) {
    // ...
  }
  return urls;
}

Future<String> uploadBackground(Uint8List data, String showId) async {
  String url = '';
  try {
    final imageRef = storageRef.child(showId + '{background}');
    await imageRef.putData(data);
    url = await imageRef.getDownloadURL();
    // ignore: unused_catch_clause
  } on FirebaseException catch (e) {
    // ...
  }
  return url;
}
