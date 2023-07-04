import 'package:flutter/material.dart';
import 'package:showmaker/database/ShowPreview/showPreview.dart';
import 'package:showmaker/prompting/parameters.dart' as par;
import 'dart:ui';

import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/screens/Show/view/viewShow.dart';

Widget getPrevCard(BuildContext context, bool active, double height,
    double width, ShowPreview preview) {
  Color color = !active ? Colors.black.withOpacity(0.3) : Colors.transparent;
  double textHeight = 40;

  return Padding(
    padding: EdgeInsets.only(left: 5, right: 5),
    child: Center(
      child: Container(
        height: height,
        width: width,
        child: Column(
          children: [
            AnimatedContainer(
              height: active ? 0 : 30,
              duration: Duration(milliseconds: 300),
            ),
            Center(
              child: AnimatedContainer(
                width: width - (active ? 0 : 50),
                duration: Duration(milliseconds: 300),
                child: AspectRatio(
                  aspectRatio: par.ShowSizes.width / par.ShowSizes.height,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(preview.coverSlideUrl),
                      ),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: themeColors.darkBlack.withOpacity(
                              active ? 1 : 0), // Colors.black.withOpacity(0.8),
                          blurRadius: 5,
                          offset: Offset(4.5, 4.5),
                        ),
                      ],
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: color),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              settings: RouteSettings(name: '/ViewShow'),
                              builder: (context) =>
                                  ViewShow(id: preview.showId)));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: textHeight,
                child: Center(
                  child: Text(
                    preview.title,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
