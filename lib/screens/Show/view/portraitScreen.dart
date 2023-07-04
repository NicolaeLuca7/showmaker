import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/database/Show/show.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/screens/Slide/fullScreenImage.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

Widget getPortraitScreen({
  required StateSetter setState,
  required BuildContext context,
  required double aheight,
  required double awidth,
  required bool loading,
  required String message,
  required Show? show,
  required List<Uint8List> images,
  required MyType<int> currentImage,
  required Function downloadPDF,
  required MyType<bool> downloaded,
  required String? downloadPath,
  required Function editDialog,
  required Function deleteDialog,
}) {
  final orientation = MediaQuery.of(context).orientation;
  return message != ''
      ? Column(
          children: [
            Spacer(),
            Text(
              message,
              style: TextStyle(fontSize: 30),
            ),
            Spacer(),
          ],
        )
      : Column(
          children: [
            //
            SizedBox(
              height: 30,
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
                  //
                  Spacer(),
                  //
                  Center(
                    child: Text(
                      show!.title,
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  //
                  Spacer(),
                  CustomButton(
                    toolTip: "Download as pdf",
                    activated: !downloaded.value && downloadPath != null,
                    widget: Icon(
                      Icons.download_sharp,
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
                    onPressed: () => downloadPDF(
                        title: show.title, images: images, state: setState),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  CustomButton(
                      toolTip: "Edit",
                      activated: true,
                      widget: Icon(
                        Icons.edit,
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
                      onPressed: () => editDialog(context, show)),
                  SizedBox(
                    width: 20,
                  ),
                  CustomButton(
                      toolTip: "Delete",
                      activated: true,
                      widget: Icon(
                        Icons.delete,
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
                      onPressed: () => deleteDialog(context, show, setState)),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),

            Spacer(),

            Container(
              width: awidth,
              height: 300,
              child: Center(
                child: AspectRatio(
                  aspectRatio: par.ShowSizes.width / par.ShowSizes.height,
                  child: Stack(
                    children: [
                      Image.memory(images[currentImage.value]),
                      //
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 0, bottom: 0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FullScreenImage(
                                          image: images[currentImage.value],
                                          prevOrientation: orientation,
                                        )),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.black.withOpacity(0.3),
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
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
            Container(
              width: awidth,
              height: 150,
              decoration: BoxDecoration(
                color: themeColors.darkBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(color: themeColors.darkOrange, blurRadius: 13)
                ],
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int index = 0; index < images.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      child: Center(
                        child: SizedBox(
                          width: 200,
                          child: AspectRatio(
                            aspectRatio:
                                par.ShowSizes.width / par.ShowSizes.height,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: MemoryImage(images[index]),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentImage.value = index;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
}

/* ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.memory(image),
                            )),*/