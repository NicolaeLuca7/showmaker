import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

class SlideSettings {
  int id;
  int charCount;
  bool loading;
  String content;
  double titleSize;
  double contentSize;
  Color textColor;
  ScreenshotController screenshotController = ScreenshotController();
  String slideUrl;
  TextAlign textAlign;
  double textWidth; // percentage of the slide's size
  double textHeight; // percentage of the slide's size
  double
      emptySpace; // percentage of the slide's size for the space between title and content
  FontWeight fontWeight;
  par.Fonts font;
  bool underlined;

  SlideSettings({
    required this.id,
    required this.charCount,
    this.slideUrl = '',
    this.loading = false,
    this.content = '',
    this.titleSize = 100,
    this.contentSize = 100,
    this.textColor = Colors.white,
    this.textAlign = TextAlign.left,
    this.textWidth = 80,
    this.textHeight = 60,
    this.emptySpace = 10,
    this.fontWeight = FontWeight.w400,
    this.font = par.Fonts.OpenSans,
    this.underlined = false,
  });

  static SlideSettings fromDatabase(Map<String, dynamic> data) => SlideSettings(
        id: data["id"],
        charCount: data["charCount"],
        slideUrl: data["slideUrl"],
        loading: data["loading"],
        content: data["content"],
        titleSize: data["titleSize"],
        contentSize: data["contentSize"],
        emptySpace: data['emptySpace'],
        textColor: Color.fromARGB(data["textColor"][0], data["textColor"][1],
            data["textColor"][2], data["textColor"][3]),
        textAlign: _decodeAlignment(data["textAlign"]),
        textWidth: data["textWidth"],
        textHeight: data["textHeight"],
        fontWeight: _decodeWeight(data["fontWeight"]),
        font: _decodeFont(data["font"]),
        underlined: data["underlined"],
      );

  Map<String, dynamic> toDatabase() => {
        "id": id,
        "charCount": charCount,
        "loading": loading,
        "content": content,
        "titleSize": titleSize,
        "contentSize": contentSize,
        'emptySpace': emptySpace,
        "textColor": [
          textColor.alpha,
          textColor.red,
          textColor.green,
          textColor.blue
        ],
        "slideUrl": slideUrl,
        "textAlign": textAlign.toString(),
        "textWidth": textWidth,
        "textHeight": textHeight,
        "fontWeight": fontWeight.toString(),
        "font": font.name,
        "underlined": underlined,
      };

  static TextAlign _decodeAlignment(String val) {
    switch (val) {
      case "TextAlign.center":
        return TextAlign.center;
      case "TextAlign.end":
        return TextAlign.end;
      case "TextAlign.justify":
        return TextAlign.justify;
      case "TextAlign.left":
        return TextAlign.left;
      case "TextAlign.right":
        return TextAlign.right;
      case "TextAlign.start":
        return TextAlign.start;
    }
    return TextAlign.start;
  }

  static FontWeight _decodeWeight(String val) {
    switch (val) {
      case "FontWeight.w100":
        return FontWeight.w100;
      case "FontWeight.w200":
        return FontWeight.w200;
      case "FontWeight.w300":
        return FontWeight.w300;
      case "FontWeight.w400":
        return FontWeight.w400;
      case "FontWeight.w500":
        return FontWeight.w500;
      case "FontWeight.w600":
        return FontWeight.w600;
      case "FontWeight.w700":
        return FontWeight.w700;
      case "FontWeight.w800":
        return FontWeight.w800;
      case "FontWeight.w900":
        return FontWeight.w900;
    }
    return FontWeight.normal;
  }

  static par.Fonts _decodeFont(String val) {
    return par.Fonts.values.firstWhere((e) => e.toString() == 'Fonts.' + val);
  }

  SlideSettings getCopy() => SlideSettings(
      id: id,
      charCount: charCount,
      slideUrl: slideUrl,
      loading: loading,
      content: content,
      titleSize: titleSize,
      contentSize: contentSize,
      textColor: textColor,
      textAlign: textAlign,
      textWidth: textWidth,
      textHeight: textHeight,
      emptySpace: emptySpace,
      fontWeight: fontWeight,
      font: font,
      underlined: underlined);
}
