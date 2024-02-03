import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dart_openai/dart_openai.dart';
import 'package:showmaker/common/selectableItem.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

class Prompts {
  static Future<List<String>> getTitles(
      String subject, int slides, String language) async {
    List<String> titles = [];
    try {
      String response = (await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: _getTitlesPrompt(subject, slides, language),
            role: OpenAIChatMessageRole.user,
          ),
        ],
      ))
          .choices[0]
          .message
          .content;

      response = response.replaceAll('"', '');
      List<String> titles1 = response.split('\n');
      for (int i = 0; i < slides; i++) {
        response = titles1[i];
        String number = (i + 1).toString() + '.';
        response = response.replaceAll(number, '');
        int j = 0;
        while (j < response.length && response[j] == ' ') {
          j++;
        }
        response = response.replaceRange(0, j, '');
        titles1[i] = response;
      }
      titles = titles1;
    } catch (e) {
      titles = ["Error: " + e.toString()];
    }

    return titles;
  }

  static Future<Uint8List> getShowImage(
      List<SelectableItem<par.Colors>> selectedColors,
      List<SelectableItem<par.Shapes>> selectedShapes,
      par.Styles showStyle) async {
    Uint8List data = Uint8List(0);
    String colors = '';
    String shapes = '';
    String style = showStyle.name + ';';

    try {
      for (var color in selectedColors) {
        if (color.selected) {
          colors += color.item.name + ' , ';
        }
      }
      if (colors.isEmpty) {
        colors = 'Any;';
      } else {
        colors.replaceRange(colors.length - 3, null, ';');
      }

      for (var shape in selectedShapes) {
        if (shape.selected) {
          shapes += shape.item.name + ' , ';
        }
      }
      if (shapes.isEmpty) {
        shapes = 'Any;';
      } else {
        shapes.replaceRange(shapes.length - 3, null, ';');
      }

      String prompt = _getShowImagePrompt(colors, shapes, style);
      String url = (await OpenAI.instance.image.create(
            prompt: prompt,
            n: 1,
            size: OpenAIImageSize.size1024,
            responseFormat: OpenAIImageResponseFormat.url,
          ))
              .data[0]
              .url ??
          '';

      data = (await http.get(Uri.parse(url))).bodyBytes;
    } catch (e) {}
    return data;
  }

  static Future<String> getSlideContent(
      String title, int charCount, String subject, String language) async {
    if (charCount == 0) {
      return 'Error: "Cannot generate content with 0 characters."';
    }
    String prompt = _getSlideContentPrompt(title, charCount, subject, language);
    String response;
    try {
      response = (await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: prompt,
            role: OpenAIChatMessageRole.user,
          ),
        ],
      ))
          .choices[0]
          .message
          .content;
      response = eraseTitle(response, title);
    } catch (e) {
      response = "An error occurred!Try again.";
    }
    return response;
  }

  static String _getTitlesPrompt(String subject, int slides, String language) {
    String prompt =
        'Generate $slides short topics for a slideshow presentation about $subject.Have only the titles.Write in $language.';
    //'Generate $slides short slide titles for a slideshow presentation about $subject.Have only the titles.';
    return prompt;
  }

  static String _getShowImagePrompt(
      String colors, String shapes, String style) {
    return '''Make without text a slideshow design background using the following:
    - Colors: $colors
    - Shapes: $shapes
    - Style: $style''';
  }

  static String _getSlideContentPrompt(
      String title, int charCount, String subject, String language) {
    return '''Give me a summary with informations of the topic "$title" for the subject "$subject".Use only $charCount characters.Format the informations for a slide.Give only the content.Write in $language.''';
    //return '''Write me about the subject "$title" in around $charCount characters.''';
  }

  static String eraseTitle(String response, String title) {
    List<String> list = response.split('.');
    title = title.toLowerCase();
    int tSize = title.length;

    response = '';
    for (var s in list) {
      String s1 = s;
      s = s.toLowerCase();
      if (s.length < tSize) {
        response += s1;
        continue;
      }
      int i;
      int maxx = 0, match = 0;
      for (i = tSize; i <= s.length; i++) {
        match = 0;
        int y = 0;
        for (int j = i - tSize; j < tSize; j++) {
          if (s[j] == title[y]) {
            match++;
          }
          y++;
        }
        maxx = max(maxx, match);
      }
      if (maxx * 100 / tSize < 80) {
        response += s1;
      }
    }
    int i = 0;
    String regex = ''' "''';
    regex += "'";
    while (i < response.length && regex.contains(response[i])) {
      i++;
    }
    i--;
    response = response.replaceRange(0, i + 1, '');

    i = response.length - 1;
    while (i >= 0 && regex.contains(response[i])) {
      i--;
    }
    i++;
    response = response.replaceRange(i, null, '');

    return response;
  }
}
