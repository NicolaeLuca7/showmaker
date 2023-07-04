import 'dart:core';

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:showmaker/design/neumorphism/shadowState.dart';

// ignore: must_be_immutable
class NeumorphicTextButton extends StatelessWidget {
  Widget text;
  double width;
  double height;
  BorderRadius borderRadius;
  double borderWidth;
  Offset shadowOffset;
  double blurRadius;
  Color shadowColor;
  Color splashColor;
  List<Color> backgroundColors;
  List<Color> borderColors;
  AlignmentGeometry backgroundBegin;
  AlignmentGeometry backgroundEnd;
  AlignmentGeometry borderBegin;
  AlignmentGeometry borderEnd;
  void Function()? onPressed;
  bool activated;

  NeumorphicTextButton(
      {required this.text,
      required this.width,
      required this.height,
      required this.borderRadius,
      required this.activated,
      this.borderWidth = 0,
      this.shadowOffset = Offset.zero,
      this.blurRadius = 0.0,
      this.shadowColor = Colors.transparent,
      this.splashColor = Colors.transparent,
      this.backgroundColors = const [Colors.transparent, Colors.transparent],
      this.borderColors = const [Colors.transparent, Colors.transparent],
      this.backgroundBegin = Alignment.centerLeft,
      this.backgroundEnd = Alignment.centerRight,
      this.borderBegin = Alignment.centerLeft,
      this.borderEnd = Alignment.centerRight,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    ShadowState shadowState = ShadowState.Out;
    if (backgroundColors.length == 1) {
      backgroundColors.add(backgroundColors[0]);
    }
    if (borderColors.length == 1) {
      borderColors.add(borderColors[0]);
    }
    LinearGradient gradient = LinearGradient(
        colors: backgroundColors, begin: backgroundBegin, end: backgroundEnd);
    LinearGradient borderGradient = LinearGradient(
        colors: borderColors, begin: borderBegin, end: borderEnd);
    //
    return LayoutBuilder(
      builder: (context, contrains) {
        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius,
            border: GradientBoxBorder(
              gradient: borderGradient,
              width: borderWidth,
            ),
          ),
          child: StatefulBuilder(builder: (context, state) {
            //
            return Stack(children: [
              AnimatedContainer(
                onEnd: () {
                  if (shadowState.name == 'Out') return;

                  shadowState = ShadowState.Out;
                  state(() {});
                },
                duration: Duration(milliseconds: 150),
                height: height,
                width: width,
                child: Center(child: text),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                        color: shadowColor,
                        blurRadius:
                            !(shadowState.name == 'In') ? blurRadius : 0.1,
                        offset: shadowOffset,
                        blurStyle: BlurStyle.outer)
                  ],
                ),
              ),
              Center(
                child: Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: activated
                        ? Colors.transparent
                        : Colors.black.withOpacity(0.5),
                    borderRadius: borderRadius,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: borderRadius,
                    child: InkWell(
                      borderRadius: borderRadius,
                      splashColor: splashColor,
                      onTap: () {
                        if (!activated) return;
                        shadowState = (shadowState.name == 'Out'
                            ? ShadowState.In
                            : ShadowState.Out);
                        state(() {});
                        if (onPressed != null) onPressed!();
                      },
                    ),
                  ),
                ),
              ),
            ]);
          }),
        );
      },
    );
  }
}
