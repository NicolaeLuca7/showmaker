import 'package:showmaker/database/Slide/slideSettings.dart';

class Slide {
  String title;
  SlideSettings settings;

  Slide(this.title, this.settings);

  Map<String, dynamic> toDatabase() => {
        'title': title,
        'settings': settings.toDatabase(),
      };

  static Slide fromDatabase(Map<String, dynamic> data) =>
      Slide(data['title'], SlideSettings.fromDatabase(data['settings']));
}
