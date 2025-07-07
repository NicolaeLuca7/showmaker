import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:showmaker/database/Slide/dbMethods.dart';
import 'package:showmaker/database/Slide/slide.dart';
import 'package:showmaker/database/Slide/slideSettings.dart';
import 'package:showmaker/database/entity.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

class Show implements Entity<Show> {
  String? _id;
  String userId;
  String title;
  String subject;
  String coverSlideUrl;
  String backgroundImgUrl;
  String previewId;
  par.Parameters parameters;
  List<Slide> slides;
  DateTime creationDate;

  Show(
      {required this.userId,
      required this.title,
      required this.subject,
      required this.coverSlideUrl,
      required this.backgroundImgUrl,
      required this.previewId,
      required this.parameters,
      required this.slides,
      required this.creationDate});

  @override
  void setId(String? id) {
    this._id = id;
  }

  @override
  Map<String, dynamic> toDatabase() => {
        'userId': userId,
        'title': title,
        'subject': subject,
        'coverSlideUrl': coverSlideUrl,
        'backgroundImgUrl': backgroundImgUrl,
        'previewId': previewId,
        'parameters': parameters.toDatabase(),
        'slides': slidesToDatabase(slides),
        'creationDate': Timestamp.fromDate(creationDate),
      };

  static Show fromDatabase(Map<String, dynamic> data) => Show(
      userId: data['userId'],
      title: data['title'],
      subject: data['subject'],
      coverSlideUrl: data['coverSlideUrl'],
      backgroundImgUrl: data['backgroundImgUrl'] ?? data['backgroundImg'],
      previewId: data['previewId'],
      parameters: par.Parameters.fromDatabase(data['parameters']),
      slides:
          slidesFromDatabase(List<Map<String, dynamic>>.from(data['slides'])),
      creationDate: data['creationDate'].toDate());

  @override
  String? getId() => _id;

  List<SlideSettings> getSettingsList() {
    List<SlideSettings> settings = [];

    for (var slide in slides) {
      settings.add(slide.settings.getCopy());
    }

    return settings;
  }
}
