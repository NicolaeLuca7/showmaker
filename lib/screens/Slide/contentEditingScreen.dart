import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showmaker/common/messages.dart';
import 'package:showmaker/database/Slide/slideSettings.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

// ignore: must_be_immutable
class ContentEditingScreen extends StatefulWidget {
  SlideSettings card;

  ContentEditingScreen({required this.card, super.key});

  @override
  State<ContentEditingScreen> createState() => _ContentEditingScreenState();
}

class _ContentEditingScreenState extends State<ContentEditingScreen> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);*/
    controller.text = widget.card.content;
    super.initState();
  }

  @override
  void dispose() {
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);*/
    super.dispose();
  }

  double aheight = 0, awidth = 0;

  @override
  Widget build(BuildContext context) {
    aheight = MediaQuery.of(context).size.height;
    awidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: aheight,
        width: awidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [themeColors.lightBlack, themeColors.darkBlack],
              transform: GradientRotation(pi / 4)),
        ),
        child: AspectRatio(
          aspectRatio: par.ShowSizes.width / par.ShowSizes.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    maxLines: 10,
                    controller: controller,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                //
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: CustomButton(
                      toolTip: 'Back',
                      activated: true,
                      widget: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      width: 60,
                      height: 60,
                      backgroundColors: [
                        Colors.white.withOpacity(0.3),
                      ],
                      borderColors: [Colors.white],
                      borderWidth: 1.7,
                      borderRadius: BorderRadius.circular(30),
                      splashColor: Colors.white.withOpacity(0.3),
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10, bottom: 10),
                    child: CustomButton(
                      toolTip: 'Save',
                      activated: true,
                      widget: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(
                            Icons.check,
                            size: 30,
                            color: Colors.white,
                          )),
                      width: 60,
                      height: 60,
                      backgroundColors: [
                        Colors.white.withOpacity(0.3),
                      ],
                      borderColors: [Colors.white],
                      borderWidth: 1.7,
                      borderRadius: BorderRadius.circular(30),
                      splashColor: Colors.white.withOpacity(0.3),
                      onPressed: () {
                        widget.card.content = controller.text;
                        FocusManager.instance.primaryFocus?.unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                            customSnackBar(
                                content: "Saved!", textColor: Colors.green));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
