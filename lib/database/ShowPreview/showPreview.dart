import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showmaker/database/entity.dart';

class ShowPreview implements Entity<ShowPreview> {
  String? _id;
  String userId;
  String showId;
  String title;
  int slideCount;
  String coverSlideUrl;
  DateTime creationDate;

  ShowPreview(
      {required this.userId,
      required this.showId,
      required this.title,
      required this.slideCount,
      required this.coverSlideUrl,
      required this.creationDate});

  @override
  String? getId() => this._id;

  @override
  void setId(String id) {
    this._id = id;
  }

  @override
  Map<String, dynamic> toDatabase() => {
        "userId": userId,
        "showId": showId,
        "title": title,
        "slideCount": slideCount,
        "coverSlideUrl": coverSlideUrl,
        'creationDate': Timestamp.fromDate(creationDate),
      };

  static ShowPreview fromDatabase(Map<String, dynamic> data) => ShowPreview(
      userId: data['userId'],
      showId: data['showId'],
      title: data['title'],
      slideCount: data['slideCount'],
      coverSlideUrl: data['coverSlideUrl'],
      creationDate: data['creationDate'].toDate());
}
