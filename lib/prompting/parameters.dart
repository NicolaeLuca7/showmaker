import 'package:flutter/material.dart' as material;
import 'package:showmaker/design/themeColors.dart';

import 'dart:ui' as ui;

class Parameters {
  String title;
  String subject;
  int slideCount; // number of slides including the cover one
  List<String> slideTitle;
  List<Shapes> shapes;
  List<Colors> colors;
  Styles style;

  Parameters(
      {this.title = '',
      this.subject = '',
      this.slideCount = 0,
      this.slideTitle = const [],
      this.shapes = const [],
      this.colors = const [],
      this.style = Styles.Creative}) {}

  Map<String, dynamic> toDatabase() => {
        "title": title,
        "subject": subject,
        "slideCount": slideCount,
        "slideTitle": slideTitle,
        "shapes":
            List<String>.generate(shapes.length, (index) => shapes[index].name),
        "colors":
            List<String>.generate(colors.length, (index) => colors[index].name),
        "style": style.name,
      };

  static Parameters fromDatabase(Map<String, dynamic> data) => Parameters(
      title: data["title"],
      subject: data["subject"],
      slideCount: data["slideCount"],
      slideTitle: List<String>.from(data["slideTitle"]),
      shapes: _decodeShapes(List<String>.from(data["shapes"])),
      colors: _decodeColors(List<String>.from(data["colors"])),
      style: _decodeStyle(data["style"]));

  static List<Shapes> _decodeShapes(List<String> data) {
    List<Shapes> shapes = [];
    for (var s in data) {
      shapes.add(Shapes.values.firstWhere((element) => element.name == s));
    }
    return shapes;
  }

  static List<Colors> _decodeColors(List<String> data) {
    List<Colors> colors = [];
    for (var s in data) {
      colors.add(Colors.values.firstWhere((element) => element.name == s));
    }
    return colors;
  }

  static Styles _decodeStyle(String s) {
    return Styles.values.firstWhere((element) => element.name == s);
  }

  Parameters getCopy() => Parameters(
      title: title,
      subject: subject,
      slideCount: slideCount,
      slideTitle: slideTitle,
      shapes: shapes,
      colors: colors,
      style: style);
}

enum Styles { Retro, Creative, Futuristic }

enum Shapes { Lines, Squares, Circles, Triangles }

enum Colors {
  Red,
  Blue,
  Black,
  White,
  Green,
  Purple,
  Pink,
  Yellow,
  Orange,
  Brown,
}

enum Fonts {
  Alegreya,
  FrankRuhlLibre,
  Lato,
  Montserrat,
  OpenSans,
  Oswald,
  Poppins,
  Raleway,
  RalewayDots,
  Roboto,
}

enum FontWeights {
  w100,
  w200,
  w300,
  w400,
  w500,
  w600,
  w700,
  w800,
  w900,
}

Map<Colors, dynamic> colorsAsignment = {
  Colors.Red: material.Colors.red,
  Colors.Blue: material.Colors.blue,
  Colors.Black: material.Colors.black,
  Colors.White: material.Colors.white,
  Colors.Green: material.Colors.green,
  Colors.Purple: material.Colors.purple,
  Colors.Pink: material.Colors.pink,
  Colors.Yellow: material.Colors.yellow,
  Colors.Orange: themeColors.lightOrange,
  Colors.Brown: material.Colors.brown
};

Map<Shapes, String> shapesAsignment = {
  Shapes.Lines: "assets/svgs/line.svg",
  Shapes.Circles: "assets/svgs/circle.svg",
  Shapes.Squares: "assets/svgs/square.svg",
  Shapes.Triangles: "assets/svgs/triangle.svg"
};

class ShowSizes {
  static double width = 1920;
  static double height = 1080;
}

Map<FontWeights, dynamic> weightsAsignment = {
  FontWeights.w100: ui.FontWeight.w100,
  FontWeights.w200: ui.FontWeight.w200,
  FontWeights.w300: ui.FontWeight.w300,
  FontWeights.w400: ui.FontWeight.w400,
  FontWeights.w500: ui.FontWeight.w500,
  FontWeights.w600: ui.FontWeight.w600,
  FontWeights.w700: ui.FontWeight.w700,
  FontWeights.w800: ui.FontWeight.w800,
  FontWeights.w900: ui.FontWeight.w900,
};
