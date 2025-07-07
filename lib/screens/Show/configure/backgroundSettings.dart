import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/common/selectableItem.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/prompting/prompts.dart';
import 'package:showmaker/prompting/parameters.dart' as par;
import 'package:showmaker/screens/Slide/fullScreenImage.dart';

// ignore: must_be_immutable
class BackgroundSettings extends StatefulWidget {
  MyType<int> screenIndex;
  par.Parameters parameters;
  StateSetter state;
  MyType<Uint8List?> backgroundImage;
  bool existing;

  BackgroundSettings(
      {required this.screenIndex,
      required this.parameters,
      required this.state,
      required this.backgroundImage,
      required this.existing,
      super.key});

  @override
  State<BackgroundSettings> createState() => _BackgroundSettingsState();
}

class _BackgroundSettingsState extends State<BackgroundSettings> {
  double aheight = 0;
  double awidth = 0;
  bool pageCompleted = false;

  List<par.Colors> colors = [];

  List<SelectableItem<par.Colors>> selectedColors = [];

  List<SelectableItem<par.Shapes>> selectedShapes = [];

  par.Styles showStyle = par.Styles.Creative;

  bool loading = false;

  @override
  void initState() {
    for (var cl in par.Colors.values) {
      selectedColors.add(SelectableItem<par.Colors>(false, cl));
    }
    for (var s in par.Shapes.values) {
      selectedShapes.add(SelectableItem<par.Shapes>(false, s));
    }
    if (widget.existing) {
      for (var color in widget.parameters.colors) {
        selectedColors[
                selectedColors.indexWhere((element) => element.item == color)]
            .selected = true;
      }

      for (var shape in widget.parameters.shapes) {
        selectedShapes[
                selectedShapes.indexWhere((element) => element.item == shape)]
            .selected = true;
      }

      showStyle = widget.parameters.style;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    aheight = MediaQuery.of(context).size.height;
    awidth = MediaQuery.of(context).size.width;

    final orientation = MediaQuery.of(context).orientation;

    if (widget.backgroundImage.value != null) {
      pageCompleted = true;
    } else {
      pageCompleted = false;
    }

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
                transform: GradientRotation(pi / 4),
              ),
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
                  //SizedBox(height: aheight * 0.03),
                  //
                  Container(
                    width: awidth,
                    height: 140,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Background\nSettings',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              decorationColor: Colors.white,
                              decorationThickness: 0.9),
                        )
                      ],
                    ),
                  ),
                  //
                  SizedBox(height: 15),
                  //Spacer(),
                  //
                  Expanded(
                    //width: awidth,
                    //height: aheight - 230,
                    child: Center(
                      child: ListView(
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              //
                              CustomButton(
                                widget: Text(
                                  'Design Settings',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                backgroundColors: [themeColors.accentBlack],
                                borderColors: [
                                  themeColors.lightOrange.withOpacity(0.8),
                                  themeColors.darkOrange.withOpacity(0.8)
                                ],
                                shadowColor: themeColors.lightOrange,
                                blurRadius: 7,
                                borderWidth: 2,
                                splashColor: Colors.white.withOpacity(0.3),
                                width: 170,
                                height: 60,
                                borderRadius: BorderRadius.circular(10),
                                activated: true,
                                onPressed: designSettingDialogue,
                              ),

                              //
                              Spacer(),
                            ],
                          ),
                          //
                          SizedBox(
                            height: 40,
                          ),
                          //
                          Center(
                            child: Container(
                              width: awidth * 0.85,
                              child: AspectRatio(
                                aspectRatio:
                                    par.ShowSizes.width / par.ShowSizes.height,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                      image: widget.backgroundImage.value !=
                                              null
                                          ? DecorationImage(
                                              fit: BoxFit.fill,
                                              image: MemoryImage(
                                                widget.backgroundImage.value!,
                                              ),
                                            )
                                          : null),
                                  child: loading
                                      ? Center(
                                          child: SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: CircularProgressIndicator(
                                              color: themeColors.yellowOrange,
                                            ),
                                          ),
                                        )
                                      : Align(
                                          alignment: Alignment.bottomRight,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FullScreenImage(
                                                    image: widget
                                                        .backgroundImage.value,
                                                    prevOrientation:
                                                        orientation,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateColor
                                                      .resolveWith(
                                                (states) => Colors.black
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            icon: Icon(
                                              Icons.fullscreen,
                                              color: themeColors.yellowOrange,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Container(
                              width: 300,
                              child: Row(
                                children: [
                                  Text(
                                    "Slide design",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 25,
                                    ),
                                  ),
                                  Spacer(),
                                  CustomButton(
                                    toolTip: 'Generate',
                                    widget: SvgPicture.asset(
                                      'assets/svgs/generate.svg',
                                      width: 30,
                                      height: 30,
                                      color: themeColors.yellowOrange,
                                    ),
                                    width: 100,
                                    height: 40,
                                    borderRadius: BorderRadius.circular(10),
                                    activated: !loading,
                                    backgroundColors: [themeColors.accentBlack],
                                    splashColor: Colors.white.withOpacity(0.2),
                                    borderColors: [themeColors.yellowOrange],
                                    borderWidth: 1.5,
                                    onPressed: () async {
                                      loading = true;
                                      setState(() {});

                                      widget.backgroundImage.value =
                                          await Prompts.getShowImage(
                                              selectedColors,
                                              selectedShapes,
                                              showStyle);

                                      loading = false;
                                      setState(() {});
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void nextSlide() {
    widget.screenIndex.value++;

    List<par.Colors> colors = [];
    for (var item in selectedColors) {
      if (item.selected) {
        colors.add(item.item);
      }
    }
    widget.parameters.colors = colors;

    List<par.Shapes> shapes = [];
    for (var item in selectedShapes) {
      if (item.selected) {
        shapes.add(item.item);
      }
    }
    widget.parameters.shapes = shapes;

    widget.parameters.style = showStyle;

    widget.state(() {});
  }

  void designSettingDialogue() {
    showDialog(
      context: context,
      builder: (contex) {
        return StatefulBuilder(
          builder: (context, state) {
            return Container(
              width: awidth,
              height: aheight,
              color: Colors.black.withOpacity(0.1),
              child: Stack(
                children: [
                  SizedBox(
                    width: awidth,
                    height: aheight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Container(
                        height: 600,
                        width: 300,
                        decoration: BoxDecoration(
                          color: themeColors.accentBlack,
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                              colors: [
                                themeColors.lightOrange,
                                themeColors.darkOrange
                              ],
                            ),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            //
                            Container(
                              height: 45,
                              child: Center(
                                child: Text(
                                  "Colors",
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  height: 60,
                                  child: Row(
                                    children: [
                                      for (var scolor in selectedColors)
                                        SizedBox(
                                          height: 40,
                                          width: 50,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                scolor.selected =
                                                    !scolor.selected;
                                                state(() {});
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  color: par.colorsAsignment[
                                                          scolor.item]
                                                      .withOpacity(
                                                    scolor.selected ? 0.3 : 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  color: scolor.selected
                                                      ? themeColors.yellowOrange
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //
                            SizedBox(
                              height: 20,
                            ),
                            //
                            Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Center(
                                child: Divider(
                                  height: 2,
                                  color: themeColors.yellowOrange,
                                ),
                              ),
                            ),
                            //
                            SizedBox(
                              height: 20,
                            ),
                            //
                            Container(
                              height: 45,
                              child: Center(
                                child: Text(
                                  "Style",
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: themeColors.accentBlack,
                              child: Container(
                                height: 60,
                                child: DropdownButton<par.Styles>(
                                  value: showStyle,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                  dropdownColor: themeColors.lightBlack,
                                  onChanged: (value) {
                                    state(() {
                                      if (value != null) {
                                        showStyle = value;
                                      }
                                    });
                                  },
                                  items: [
                                    for (var style in par.Styles.values)
                                      DropdownMenuItem(
                                        value: style,
                                        child: Text(
                                          style.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            //
                            SizedBox(
                              height: 20,
                            ),
                            //
                            Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Center(
                                child: Divider(
                                  height: 2,
                                  color: themeColors.yellowOrange,
                                ),
                              ),
                            ),
                            //
                            SizedBox(
                              height: 20,
                            ),
                            //
                            Container(
                              height: 45,
                              child: Center(
                                child: Text(
                                  "Shapes",
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            //
                            Container(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  height: 60,
                                  child: Row(
                                    children: [
                                      for (var sshape in selectedShapes)
                                        SizedBox(
                                          height: 40,
                                          width: 50,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                sshape.selected =
                                                    !sshape.selected;
                                                state(() {});
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    SvgPicture.asset(
                                                      height: 40,
                                                      width: 40,
                                                      par.shapesAsignment[
                                                          sshape.item]!,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      width: 40,
                                                      color: sshape.selected
                                                          ? Colors.black
                                                              .withOpacity(0.2)
                                                          : Colors.transparent,
                                                      child: Icon(
                                                        Icons.check,
                                                        color: sshape.selected
                                                            ? themeColors
                                                                .yellowOrange
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            //
                            CustomButton(
                              widget: Text(
                                "Close",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400),
                              ),
                              width: 150,
                              height: 60,
                              borderRadius: BorderRadius.circular(10),
                              activated: true,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              backgroundColors: [themeColors.accentBlack],
                              borderColors: [
                                themeColors.lightOrange.withOpacity(0.8),
                                themeColors.darkOrange.withOpacity(0.8)
                              ],
                              borderWidth: 2,
                            ),

                            //
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
