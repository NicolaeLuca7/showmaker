import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/prompting/prompts.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

// ignore: must_be_immutable
class SubjectSettings extends StatefulWidget {
  MyType<int> screenIndex;
  par.Parameters parameters;
  StateSetter state;
  bool existing;

  SubjectSettings(
      {required this.screenIndex,
      required this.parameters,
      required this.state,
      required this.existing,
      super.key});

  @override
  State<SubjectSettings> createState() => _SubjectSettingsState();
}

class _SubjectSettingsState extends State<SubjectSettings> {
  double aheight = 0;
  double awidth = 0;
  TextEditingController subjectController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  bool generated = false;
  int slideCount = 0;
  bool generateOn = true;
  bool loading = false;
  bool pageCompleted = false;

  List<TextEditingController> titlesCnt = [];

  @override
  void initState() {
    super.initState();
    if (widget.existing) {
      titleController.text = widget.parameters.title;
      subjectController.text = widget.parameters.subject;
      slideCount = widget.parameters.slideCount;
      for (int i = 1; i < slideCount; i++) {
        titlesCnt
            .add(TextEditingController(text: widget.parameters.slideTitle[i]));
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      if (subjectController.text.length == 0 || slideCount == 0)
        generateOn = false;
      else
        generateOn = true;
      if (titleController.text.length != 0 &&
          subjectController.text.length != 0 &&
          slideCount != 0 &&
          titlesCnt.length != 0 &&
          slideCount > 0) pageCompleted = true;
    } else {
      pageCompleted = false;
    }

    aheight = MediaQuery.of(context).size.height;
    awidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: SizedBox(
          height: aheight,
          width: awidth,
          child: Container(
            height: aheight,
            width: awidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [themeColors.lightBlack, themeColors.darkBlack],
                  transform: GradientRotation(pi / 4)),
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 35,
                  ),
                  //
                  Container(
                    width: awidth,
                    height: 60,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        CustomButton(
                          toolTip: 'Back',
                          activated: true,
                          widget: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          width: 40,
                          height: 40,
                          backgroundColors: [
                            themeColors.accentBlack,
                          ],
                          shadowColor: themeColors.darkOrange,
                          blurRadius: 7,
                          borderRadius: BorderRadius.circular(20),
                          splashColor: Colors.white.withOpacity(0.2),
                          onPressed: () {
                            Navigator.maybePop(context);
                          },
                        ),
                        Spacer(),
                        CustomButton(
                          activated: pageCompleted,
                          toolTip: "Language",
                          widget: Icon(
                            Icons.language,
                            color: themeColors.darkOrange,
                            size: 30,
                          ),
                          width: 40,
                          height: 40,
                          backgroundColors: [
                            Colors.transparent,
                          ],
                          //shadowColor: themeColors.darkOrange,
                          //blurRadius: 7,
                          borderRadius: BorderRadius.circular(40),
                          splashColor: themeColors.darkBlack.withOpacity(0.2),
                          onPressed: () => showLanguagePopup(),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomButton(
                          activated: pageCompleted,
                          widget: Text(
                            'Next',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w300),
                          ),
                          width: 120,
                          height: 40,
                          backgroundColors: [
                            themeColors.accentBlack,
                          ],
                          shadowColor: themeColors.darkOrange,
                          blurRadius: 7,
                          borderRadius: BorderRadius.circular(10),
                          splashColor: Colors.white.withOpacity(0.2),
                          onPressed: () => nextSlide(),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                  //
                  Container(
                    width: awidth,
                    height: 65,
                    child: Row(children: [
                      SizedBox(width: 10),
                      Text(
                        'Title & Subject',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 45,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            decorationThickness: 0.9),
                      )
                    ]),
                  ),
                  Expanded(
                    //width: awidth,
                    //height: aheight - 160,
                    child: ListView(
                      children: [
                        Container(
                            width: awidth,
                            height: 80,
                            child: Row(children: [
                              Spacer(),
                              Container(
                                width: 250,
                                height: 80,
                                child: TextField(
                                  onChanged: (t) {
                                    if (titleController.text.length != 0 &&
                                        subjectController.text.length != 0 &&
                                        slideCount != 0 &&
                                        titlesCnt.length != 0 &&
                                        slideCount > 0)
                                      pageCompleted = true;
                                    else
                                      pageCompleted = false;
                                    setState(() {});
                                  },
                                  maxLength: 100,
                                  maxLines: 1,
                                  controller: titleController,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Title",
                                    hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w200),
                                    contentPadding: EdgeInsets.only(bottom: 0),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              Spacer(),
                            ])),
                        //
                        Container(
                            width: awidth,
                            height: 80,
                            child: Row(children: [
                              Spacer(),
                              Container(
                                width: 250,
                                height: 80,
                                child: TextField(
                                  onChanged: (t) {
                                    if (titleController.text.length != 0 &&
                                        subjectController.text.length != 0 &&
                                        slideCount != 0 &&
                                        titlesCnt.length != 0 &&
                                        slideCount > 0)
                                      pageCompleted = true;
                                    else
                                      pageCompleted = false;
                                    setState(() {});
                                  },
                                  maxLength: 100,
                                  maxLines: 1,
                                  controller: subjectController,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Subject",
                                    hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w200),
                                    contentPadding: EdgeInsets.all(0.0),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              Spacer(),
                            ])),

                        //
                        Container(
                          width: awidth,
                          height: 70,
                          child: Center(
                              child: Row(
                            children: [
                              Spacer(
                                flex: 2,
                              ),
                              Text(
                                "Slides:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                ),
                              ),
                              Spacer(),
                              SizedBox(
                                width: 100,
                                height: 70,
                                child: CupertinoPicker(
                                  itemExtent: 30,
                                  onSelectedItemChanged: (val) {
                                    setState(() {
                                      slideCount = val;
                                    });
                                  },
                                  scrollController: FixedExtentScrollController(
                                      initialItem: slideCount),
                                  children: [
                                    for (int i = 0; i <= 10; i++)
                                      Text(
                                        '$i',
                                        style: TextStyle(
                                          fontSize: 25,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Spacer(
                                flex: 2,
                              ),
                            ],
                          )),
                        ),
                        //
                        SizedBox(
                          height: 20,
                        ),
                        //
                        Container(
                          height: 60,
                          child: Center(
                            child: Text(
                              'Generated titles:',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 35),
                            ),
                          ),
                        ),
                        //
                        SizedBox(
                          width: awidth,
                          height: 220,
                          child: Center(
                            child: Container(
                              width: awidth * 0.85,
                              height: 220,
                              decoration: BoxDecoration(
                                color: themeColors.accentBlack,
                                border: GradientBoxBorder(
                                  gradient: LinearGradient(
                                    colors: [
                                      themeColors.lightOrange.withOpacity(0.8),
                                      themeColors.darkOrange.withOpacity(0.8)
                                    ],
                                  ),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: !loading
                                    ? ListView(
                                        children: [
                                          for (int i = 0;
                                              i < titlesCnt.length;
                                              i++)
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 0,
                                                  bottom: 0),
                                              height: 50,
                                              child: TextField(
                                                maxLines: 1,
                                                controller: titlesCnt[i],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                ),
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                  contentPadding:
                                                      EdgeInsets.all(0.0),
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                        ],
                                      )
                                    : SizedBox(
                                        child: CircularProgressIndicator()),
                              ),
                            ),
                          ),
                        ),
                        //
                        SizedBox(height: 10),

                        //

                        SizedBox(
                          width: 120,
                          height: 60,
                          child: Center(
                            child: CustomButton(
                              activated: generateOn,
                              widget: Text(
                                'Generate',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300),
                              ),
                              width: 120,
                              height: 60,
                              backgroundColors: [themeColors.accentBlack],
                              shadowColor: themeColors.darkOrange,
                              blurRadius: 7,
                              borderRadius: BorderRadius.circular(10),
                              splashColor: Colors.white.withOpacity(0.2),
                              onPressed: () async {
                                generateOn = false;
                                loading = true;
                                setState(() {});
                                //
                                List<String> list = await Prompts.getTitles(
                                    subjectController.text,
                                    slideCount,
                                    widget.parameters.language.name);

                                titlesCnt.clear();
                                for (String s in list) {
                                  titlesCnt.add(TextEditingController(text: s));
                                }
                                //
                                generateOn = true;
                                loading = false;
                                setState(() {});
                              },
                            ),
                          ),
                        ),

                        //
                        SizedBox(
                          height: 10,
                        ),
                        //
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showLanguagePopup() {
    par.Languages language = widget.parameters.language;
    showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: themeColors.accentBlack,
            child: Container(
              height: min(350, aheight),
              width: min(400, aheight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: themeColors.darkBlack,
              ),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Language',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 150,
                      height: 200,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (val) {
                          setState(() {
                            language = par.Languages.values[val];
                          });
                        },
                        scrollController: FixedExtentScrollController(
                            initialItem: par.Languages.values.indexWhere(
                                (element) =>
                                    element == widget.parameters.language)),
                        children: [
                          for (var language in par.Languages.values)
                            Text(
                              language.name,
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomButton(
                      activated: pageCompleted,
                      widget: Text(
                        'Save',
                        style: TextStyle(
                            color: themeColors.darkOrange, fontSize: 20),
                      ),
                      width: 120,
                      height: 40,
                      backgroundColors: [
                        themeColors.accentBlack,
                      ],
                      shadowColor: themeColors.darkOrange,
                      blurRadius: 7,
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.white.withOpacity(0.2),
                      onPressed: () {
                        widget.parameters.language = language;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  void nextSlide() {
    List<String> list = [];
    list.add(titleController.text);
    for (var cnt in titlesCnt) {
      list.add(cnt.text);
    }
    widget.parameters.title = titleController.text;
    widget.parameters.subject = subjectController.text;
    widget.parameters.slideCount = list.length;
    widget.parameters.slideTitle = list;

    widget.screenIndex.value++;
    widget.state(() {});
  }
}
