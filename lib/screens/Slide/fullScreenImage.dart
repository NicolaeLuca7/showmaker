import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

class FullScreenImage extends StatefulWidget {
  final Uint8List? image;
  final Orientation prevOrientation;
  const FullScreenImage(
      {super.key, required this.image, required this.prevOrientation});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  void initState() {
    /* SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);*/
    super.initState();
  }

  @override
  void dispose() {
    /*if (widget.prevOrientation == Orientation.portrait)
      SystemChrome.setPreferredOrientations([
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
      body: Stack(
        children: [
          if (widget.image != null)
            Center(
              child: AspectRatio(
                aspectRatio: par.ShowSizes.width / par.ShowSizes.height,
                child: Container(
                  child: Image.memory(
                    widget.image!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 5, bottom: 5),
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
        ],
      ),
    );
  }
}
