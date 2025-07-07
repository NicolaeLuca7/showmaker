import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/database/Slide/slideSettings.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/prompting/parameters.dart' as par;
import 'package:showmaker/screens/Show/configure/backgroundSettings.dart';
import 'package:showmaker/screens/Show/configure/contentConfig.dart';
import 'package:showmaker/screens/Show/configure/subjectSettings.dart';

// ignore: must_be_immutable
class ConfigureScreen extends StatefulWidget {
  String userId;
  par.Parameters parameters;
  MyType<Uint8List?> backgroundImage;
  List<Uint8List> images;
  bool existing;
  List<SlideSettings> settings;
  String? showId;
  String? previewId;
  ConfigureScreen(
      {required this.userId,
      required this.parameters,
      required this.backgroundImage,
      required this.images,
      required this.existing,
      required this.settings,
      required this.showId,
      required this.previewId,
      super.key});

  @override
  State<ConfigureScreen> createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  MyType<int> screenIndex = MyType<int>(0);
  List<Widget> screens = [];

  @override
  void initState() {
    /*parameters = par.Parameters(
        title: "Mr. Beast",
        subject: "Mr. Beast's success",
        slidesCount: 4,
        slideTitle: [
          "Mr. Beast",
          "The Rise of Mr. Beast: A Journey to Success",
          "The Secret Formula of Mr. Beast's Success",
          "Unlocking the Strategies Behind Mr. Beast's Rise to Fame"
        ]);
    screenIndex.value++;*/
    screens = [
      SubjectSettings(
        screenIndex: screenIndex,
        parameters: widget.parameters,
        state: setState,
        existing: widget.existing,
      ),
      BackgroundSettings(
        screenIndex: screenIndex,
        parameters: widget.parameters,
        state: setState,
        backgroundImage: widget.backgroundImage,
        existing: widget.existing,
      ),
      //ImageEditTest(image: backgroundImage),
      ContentConfig(
        userId: widget.userId,
        screenIndex: screenIndex,
        parameters: widget.parameters,
        state: setState,
        backgroundImage: widget.backgroundImage,
        images: widget.images,
        settings: widget.settings,
        existing: widget.existing,
        showId: widget.showId,
        previewId: widget.previewId,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: showExitPopup, //call function on back button press
        child: Scaffold(
          body: screens[screenIndex.value],
        ));
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: themeColors.accentBlack,
            title: Text(
              'Exit Configuration?',
              style: TextStyle(
                color: themeColors.darkOrange,
              ),
            ),
            content: Text(
              'The current show will be lost',
              style: TextStyle(color: themeColors.darkOrange, fontSize: 20),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: TextStyle(
                    color: themeColors.darkOrange,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                    (states) => themeColors.lightBlack,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: themeColors.darkOrange,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                    (states) => themeColors.lightBlack,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }
}
