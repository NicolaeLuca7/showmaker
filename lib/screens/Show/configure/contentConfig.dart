import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:showmaker/common/getFont.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/prompting/parameters.dart' as par;
import 'package:showmaker/prompting/prompts.dart';
import 'package:showmaker/screens/Show/configure/saveScreen.dart';
import 'package:showmaker/screens/Slide/fullScreenImage.dart';
import 'package:showmaker/database/Slide/slideSettings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:showmaker/screens/Slide/contentEditingScreen.dart';

class ContentConfig extends StatefulWidget {
  final MyType<int> screenIndex;
  final par.Parameters parameters;
  final StateSetter state;
  final MyType<Uint8List?> backgroundImage;
  final List<SlideSettings> settings;
  final List<Uint8List> images;
  final String userId;
  final bool existing;
  final String? showId;
  final String? previewId;

  const ContentConfig(
      {Key? key,
      required this.screenIndex,
      required this.parameters,
      required this.state,
      required this.backgroundImage,
      required this.userId,
      required this.existing,
      required this.showId,
      required this.previewId,
      this.settings = const [],
      this.images = const []})
      : super(key: key);

  @override
  State<ContentConfig> createState() => _ContentConfigState(settings, images);
}

class _ContentConfigState extends State<ContentConfig> {
  List<SlideSettings> settings;
  List<Uint8List> images;

  List<bool> loaded = [];

  _ContentConfigState(this.settings, this.images);

  bool initialized = false;
  int currentInit = 1;

  bool pageCompleted = false;
  bool loadingPage = true;

  double aheight = 0;
  double awidth = 0;
  double cardHeight = 0;
  double cardWidth = 0;
  double slideHeight = 0, slideWidth = 0; //for the small slide
  double aspectRatio = 0;

  double devicePixelRatio = 0;

  TextEditingController creditCnt = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (settings.length == 0) {
      images = List.generate(widget.parameters.slideCount,
          (index) => widget.backgroundImage.value!);
      settings = List.generate(widget.parameters.slideCount - 1,
          (index) => SlideSettings(id: index + 1, charCount: 0));
      settings.insert(0, SlideSettings(id: 0, charCount: 0));
    }
    creditCnt.text = settings[0].content;
    loaded = List.generate(widget.parameters.slideCount, (index) => false);
    initPage();
  }

  void initPage() async {
    for (int i = 0; i < widget.parameters.slideCount; i++) {
      await updateSlide(settings[i]);
    }
    loadingPage = false;
    setState(() {});
  }

  var orientation;

  Key? key;

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);

    aheight = queryData.size.height;
    awidth = queryData.size.width;
    cardHeight = aheight * 0.65;
    cardWidth = awidth * 0.95;

    devicePixelRatio = queryData.devicePixelRatio;

    orientation = queryData.orientation;

    aspectRatio = par.ShowSizes.width / par.ShowSizes.height;
    //slideWidth = min(par.ShowSizes.width, cardWidth * 0.9);
    //slideHeight = slideWidth / (par.ShowSizes.width / par.ShowSizes.height);

    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          height: aheight,
          width: awidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [themeColors.lightBlack, themeColors.darkBlack],
                transform: GradientRotation(pi / 4)),
          ),
          child: Center(
            child: loadingPage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Creating the slides",
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  )
                : Column(
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
                              activated: true,
                              widget: Text(
                                'Save',
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
                              onPressed: () => completeDialog(),
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
                        height: 130,
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Text(
                              'Content\nConfiguration',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  decorationColor: Colors.white,
                                  decorationThickness: 0.9),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: Center(
                          child: PageView(
                            children: [
                              for (int id = 0;
                                  id < widget.parameters.slideCount;
                                  id++)
                                SingleChildScrollView(
                                  child: getContentCard(id),
                                ),
                            ],
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

  void nextSlide() {}

  Widget getContentCard(int id) {
    return StatefulBuilder(builder: (context, state) {
      return Center(
        child: Container(
          height: cardHeight,
          width: cardWidth,
          decoration: BoxDecoration(
              color: themeColors.accentBlack,
              border: Border.all(color: themeColors.yellowOrange, width: 3),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Text(
                    "Slide ${id}",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400),
                  ),
                ),
                Spacer(),
                SizedBox(
                  height: cardHeight - 60,
                  width: cardWidth,
                  child: ListView(
                    children: [
                      Center(
                        child: Text(
                          '${settings[id].charCount} characters',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Slider(
                        activeColor: themeColors.yellowOrange,
                        max: 500,
                        value: settings[id].charCount.toDouble(),
                        onChanged: (val) {
                          settings[id].charCount = val.toInt();
                          state(() {});
                        },
                      ),
                      Center(
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Container(
                            decoration: !settings[id].loading
                                ? BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(
                                        images[id],
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : BoxDecoration(
                                    color: Colors.black.withOpacity(0.3)),
                            child: settings[id].loading
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
                                                    image: images[id],
                                                    prevOrientation:
                                                        orientation),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                          (states) =>
                                              Colors.black.withOpacity(0.3),
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
                      //
                      SizedBox(
                        height: 10,
                      ),
                      //
                      if (id > 0)
                        SizedBox(
                            height: 40,
                            width: cardWidth,
                            child: Row(
                              children: [
                                Spacer(),
                                SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: IconButton(
                                    tooltip: 'Edit content',
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ContentEditingScreen(
                                            card: settings[id],
                                          ),
                                        ),
                                      );
                                      loadModifications(settings[id], state);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: themeColors.yellowOrange,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                VerticalDivider(),
                                SizedBox(
                                  width: 10,
                                ),
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
                                  activated: !settings[id].loading,
                                  backgroundColors: [themeColors.accentBlack],
                                  splashColor: Colors.white.withOpacity(0.2),
                                  borderColors: [themeColors.yellowOrange],
                                  borderWidth: 1.5,
                                  shadowColor: Colors.black,
                                  blurRadius: 7,
                                  onPressed: () async {
                                    settings[id].loading = true;
                                    state(() {});

                                    settings[id].content =
                                        await Prompts.getSlideContent(
                                            widget.parameters.slideTitle[id],
                                            settings[id].charCount,
                                            widget.parameters.subject);

                                    await updateSlide(settings[id]);

                                    settings[id].loading = false;
                                    state(() {});
                                  },
                                ),
                                Spacer(),
                              ],
                            )),
                      //
                      if (id > 0)
                        SizedBox(
                          height: 15,
                        ),
                      getTextSettings(settings[id], state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget getTextSettings(SlideSettings card, StateSetter state) {
    return Column(
      children: [
        if (card.id == 0)
          AbsorbPointer(
            absorbing: card.loading,
            child: SizedBox(
              width: 200,
              child: TextField(
                maxLength: 100,
                onSubmitted: (text) {
                  card.content = text;
                  loadModifications(card, state);
                },
                controller: creditCnt,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: "Credit",
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 20),
                  contentPadding: EdgeInsets.only(bottom: 0),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: themeColors.yellowOrange),
                  ),
                ),
              ),
            ),
          ),
        if (card.id == 0)
          SizedBox(
            height: 10,
          ),
        if (card.id > 0)
          Container(
            height: 60,
            width: 200,
            decoration: BoxDecoration(
                color: themeColors.accentBlack,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Spacer(),
                //
                CustomButton(
                    widget: Icon(
                      Icons.format_align_left,
                      color: themeColors.yellowOrange,
                      size: 30,
                    ),
                    width: 40,
                    height: 40,
                    backgroundColors: [
                      card.textAlign == TextAlign.left
                          ? themeColors.lightBlack
                          : Colors.transparent,
                    ],
                    borderRadius: BorderRadius.circular(10),
                    activated: !card.loading,
                    onPressed: () {
                      card.textAlign = TextAlign.left;
                      loadModifications(card, state);
                    }),
                //
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 4,
                  ),
                ),
                //
                CustomButton(
                  widget: Icon(
                    Icons.format_align_center,
                    color: themeColors.yellowOrange,
                    size: 30,
                  ),
                  width: 40,
                  height: 40,
                  backgroundColors: [
                    card.textAlign == TextAlign.center
                        ? themeColors.lightBlack
                        : Colors.transparent,
                  ],
                  borderRadius: BorderRadius.circular(10),
                  activated: !card.loading,
                  onPressed: () {
                    card.textAlign = TextAlign.center;
                    loadModifications(card, state);
                  },
                ),
                //
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 4,
                  ),
                ),
                //
                CustomButton(
                  widget: Icon(
                    Icons.format_align_right,
                    color: themeColors.yellowOrange,
                    size: 30,
                  ),
                  width: 40,
                  height: 40,
                  backgroundColors: [
                    card.textAlign == TextAlign.right
                        ? themeColors.lightBlack
                        : Colors.transparent,
                  ],
                  borderRadius: BorderRadius.circular(10),
                  activated: !card.loading,
                  onPressed: () {
                    card.textAlign = TextAlign.right;
                    loadModifications(card, state);
                  },
                ),
                Spacer(),
              ],
            ),
          ),
        if (card.id > 0)
          SizedBox(
            height: 10,
          ),
        if (card.id > 0)
          Container(
            height: 60,
            width: 310,
            decoration: BoxDecoration(
                color: themeColors.accentBlack,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Spacer(),
                //
                Text(
                  'Width ${card.textWidth.toInt()}%',
                  style: TextStyle(
                      fontSize: 25, color: Colors.white.withOpacity(0.9)),
                ),
                //
                SizedBox(
                  width: 150,
                  child: AbsorbPointer(
                    absorbing: card.loading,
                    child: Slider(
                      activeColor: themeColors.yellowOrange,
                      max: 90,
                      min: 30,
                      value: card.textWidth,
                      onChanged: (val) {
                        card.textWidth = val;
                        state(() {});
                      },
                      onChangeEnd: (values) {
                        loadModifications(card, state);
                      },
                    ),
                  ),
                ),

                //
                Spacer(),
              ],
            ),
          ),
        //
        if (card.id > 0)
          SizedBox(
            height: 10,
          ),
        //
        if (card.id > 0)
          Container(
            height: 60,
            width: 310,
            decoration: BoxDecoration(
                color: themeColors.accentBlack,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Spacer(),
                //
                Text(
                  'Height ${card.textHeight.toInt()}%',
                  style: TextStyle(
                      fontSize: 25, color: Colors.white.withOpacity(0.9)),
                ),
                //
                SizedBox(
                  width: 150,
                  child: AbsorbPointer(
                    absorbing: card.loading,
                    child: Slider(
                      activeColor: themeColors.yellowOrange,
                      max: 90,
                      min: 30,
                      value: card.textHeight,
                      onChanged: (val) {
                        card.textHeight = val;
                        state(() {});
                      },
                      onChangeEnd: (values) {
                        loadModifications(card, state);
                      },
                    ),
                  ),
                ),

                //
                Spacer(),
              ],
            ),
          ),
        //
        if (card.id > 0)
          SizedBox(
            height: 10,
          ),
        //
        if (card.id > 0)
          Container(
            height: 60,
            width: 310,
            decoration: BoxDecoration(
                color: themeColors.accentBlack,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Spacer(),
                //
                Text(
                  'Space ${card.emptySpace.toInt()}%',
                  style: TextStyle(
                      fontSize: 25, color: Colors.white.withOpacity(0.9)),
                ),
                //
                SizedBox(
                  width: 150,
                  child: AbsorbPointer(
                    absorbing: card.loading,
                    child: Slider(
                      activeColor: themeColors.yellowOrange,
                      max: 40,
                      min: 0,
                      value: card.emptySpace,
                      onChanged: (val) {
                        card.emptySpace = val;
                        state(() {});
                      },
                      onChangeEnd: (values) {
                        loadModifications(card, state);
                      },
                    ),
                  ),
                ),

                //
                Spacer(),
              ],
            ),
          ),
        //
        if (card.id > 0)
          SizedBox(
            height: 10,
          ),
        //
        Container(
          height: 140,
          width: 200,
          decoration: BoxDecoration(
              color: themeColors.accentBlack,
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 3),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Spacer(),
              //
              Text(
                'Title size ${card.titleSize.toInt()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25, color: Colors.white.withOpacity(0.9)),
              ),
              //
              SizedBox(
                width: 150,
                child: AbsorbPointer(
                  absorbing: card.loading,
                  child: Slider(
                    activeColor: themeColors.yellowOrange,
                    max: 200,
                    min: 10,
                    value: card.titleSize,
                    onChanged: (val) {
                      card.titleSize = val;
                      state(() {});
                    },
                    onChangeEnd: (values) {
                      loadModifications(card, state);
                    },
                  ),
                ),
              ),

              //
              Spacer(),
            ],
          ),
        ),
        //
        if (card.id > 0)
          SizedBox(
            height: 10,
          ),
        if (card.id > 0)
          Container(
            height: 140,
            width: 200,
            decoration: BoxDecoration(
                color: themeColors.accentBlack,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Spacer(),
                //
                Text(
                  'Content size ${card.contentSize.toInt()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25, color: Colors.white.withOpacity(0.9)),
                ),
                //
                SizedBox(
                  width: 150,
                  child: AbsorbPointer(
                    absorbing: card.loading,
                    child: Slider(
                      activeColor: themeColors.yellowOrange,
                      max: 200,
                      min: 10,
                      value: card.contentSize,
                      onChanged: (val) {
                        card.contentSize = val;
                        state(() {});
                      },
                      onChangeEnd: (values) {
                        loadModifications(card, state);
                      },
                    ),
                  ),
                ),
                //
                Spacer(),
              ],
            ),
          ),
        SizedBox(
          height: 10,
        ),
        //
        AbsorbPointer(
          absorbing: card.loading,
          child: Container(
            height: 60,
            width: 160,
            decoration: BoxDecoration(
                color: themeColors.accentBlack,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Spacer(),
                //
                Text(
                  'Color',
                  style: TextStyle(
                      fontSize: 25, color: Colors.white.withOpacity(0.9)),
                ),
                //
                Spacer(),
                //
                AbsorbPointer(
                    absorbing: card.loading,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: card.textColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          GestureDetector(onTap: () => pickColor(card, state)),
                    )),

                //
                Spacer(),
              ],
            ),
          ),
        ),
        //
        SizedBox(
          height: 10,
        ),
        //
        AbsorbPointer(
          absorbing: card.loading,
          child: Material(
            color: themeColors.accentBlack,
            child: Container(
              height: 60,
              child: DropdownButton<par.Fonts>(
                value: card.font,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300),
                dropdownColor: themeColors.lightBlack,
                onChanged: (value) {
                  state(() {
                    if (value != null) {
                      card.font = value;
                      loadModifications(card, state);
                    }
                  });
                },
                items: [
                  for (var font in par.Fonts.values)
                    DropdownMenuItem(
                      value: font,
                      child: Text(
                        font.name,
                        style: TextStyle(
                          color: Colors.white,
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
          height: 10,
        ),
        //
        AbsorbPointer(
          absorbing: card.loading,
          child: Material(
            color: themeColors.accentBlack,
            child: Container(
              height: 60,
              child: DropdownButton<FontWeight>(
                value: card.fontWeight,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300),
                dropdownColor: themeColors.lightBlack,
                onChanged: (value) {
                  state(() {
                    if (value != null) {
                      card.fontWeight = value;
                      loadModifications(card, state);
                    }
                  });
                },
                items: [
                  for (var weight in FontWeight.values)
                    DropdownMenuItem(
                      value: weight,
                      child: Text(
                        weight.toString(),
                        style: TextStyle(
                          color: Colors.white,
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
          height: 10,
        ),
        //

        Center(
          child: CustomButton(
            toolTip: "Underlined title",
            widget: Icon(
              Icons.format_underline,
              color: themeColors.yellowOrange,
              size: 30,
            ),
            width: 40,
            height: 40,
            backgroundColors: [
              card.underlined ? themeColors.lightBlack : Colors.transparent,
            ],
            borderRadius: BorderRadius.circular(10),
            activated: !card.loading,
            onPressed: () {
              card.underlined = !card.underlined;
              loadModifications(card, state);
            },
          ),
        ),
        //
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Map<String, TextStyle> fonts = {};

  Future<void> updateSlide(SlideSettings card) async {
    int flex1 = 0, flex2 = 0;
    if (card.textAlign == TextAlign.left) {
      flex2 = 2;
    } else if (card.textAlign == TextAlign.center) {
      flex1 = 1;
      flex2 = 1;
    } else {
      flex1 = 2;
    }

    double textWidth = par.ShowSizes.width * card.textWidth / 100;
    double textHeight = par.ShowSizes.height * card.textHeight / 100;

    TextStyle titleStyle = getFont(
        TextStyle(
          fontSize: card.titleSize,
          color: card.textColor,
          fontWeight: card.fontWeight,
          decoration: card.underlined ? TextDecoration.underline : null,
        ),
        card.font);

    TextStyle contentStyle = getFont(
        TextStyle(
            fontSize: card.contentSize,
            color: card.textColor,
            fontWeight: card.fontWeight),
        card.font);

    images[card.id] = await card.screenshotController.captureFromWidget(
      Container(
        height: par.ShowSizes.height,
        width: par.ShowSizes.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: MemoryImage(widget.backgroundImage.value!),
              fit: BoxFit.fill),
        ),
        child: card.id > 0
            ? OverflowBox(
                maxHeight: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      height: par.ShowSizes.height * 0.05,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: par.ShowSizes.width * 0.02),
                        child: Flexible(
                          //height: par.ShowSizes.height * 0.19, //- textHeight,
                          child: Text(
                            widget.parameters.slideTitle[card.id],
                            textAlign: TextAlign.left,
                            style: titleStyle,
                          ),
                        ),
                      ),
                    ),
                    //Spacer()
                    SizedBox(
                      height: par.ShowSizes.height * card.emptySpace / 100,
                    ),
                    Container(
                      width: par.ShowSizes.width,
                      height: textHeight,
                      child: Row(
                        children: [
                          SizedBox(
                            width: par.ShowSizes.width * 0.01,
                          ),
                          Spacer(),
                          if (flex1 != 0)
                            Spacer(
                              flex: flex1,
                            ),
                          Container(
                            width: textWidth,
                            child: Text(card.content,
                                textAlign: card.textAlign == TextAlign.right
                                    ? TextAlign.right
                                    : null,
                                style: contentStyle),
                          ),
                          if (flex2 != 0)
                            Spacer(
                              flex: flex2,
                            ),
                          SizedBox(
                            width: par.ShowSizes.width * 0.01,
                          ),
                        ],
                      ),
                    ),
                    //Spacer()
                  ],
                ),
              )
            : Column(
                children: [
                  Spacer(),
                  Center(
                    child: Text(
                      widget.parameters.slideTitle[card.id],
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  Spacer(),
                  if (card.content != '')
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            EdgeInsets.only(right: par.ShowSizes.height * 0.1),
                        child: Text(
                          card.content,
                          textAlign: TextAlign.right,
                          style: contentStyle,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      targetSize: Size(par.ShowSizes.width, par.ShowSizes.height),
      delay: Duration(milliseconds: 0),
    );
  }

  void loadModifications(SlideSettings card, StateSetter state) async {
    card.loading = true;
    state(() {});

    await updateSlide(card);

    card.loading = false;
    state(() {});
  }

  void pickColor(SlideSettings card, StateSetter state) {
    MyType<Color> cl = MyType(card.textColor);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              titleTextStyle: TextStyle(color: Colors.blue),
              backgroundColor: Color.fromARGB(125, 29, 29, 29),
              title: Text(
                'Text Color',
                style: TextStyle(fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Container(
                  height: 600,
                  width: 250,
                  child: Column(children: <Widget>[
                    buildcolorpicker(cl),
                    TextButton(
                      child: Text('Select', style: TextStyle(fontSize: 20)),
                      onPressed: () {
                        card.textColor = cl.value;
                        loadModifications(card, state);
                        Navigator.of(context).pop();
                      },
                    ),
                  ]),
                ),
              ),
            ));
  }

  Widget buildcolorpicker(MyType cl) {
    return Expanded(
      child: ColorPicker(
          labelTextStyle: TextStyle(),
          pickerColor: cl.value,
          hexInputBar: true,
          onColorChanged: (color) {
            //setState(() {
            cl.value = color;
            //});
          }),
    );
  }

  void completeDialog() {
    for (var card in settings) {
      if (card.loading) {
        return;
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.accentBlack,
        title: Text(
          'Save the show?',
          style: TextStyle(
            color: themeColors.darkOrange,
          ),
        ),
        content: Text(
          'Make sure you have a stable internet connection!',
          style: TextStyle(color: themeColors.darkOrange, fontSize: 20),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
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
            onPressed: () {
              if (widget.existing) {
                Navigator.of(context).pop();
                saveOptionDialog();
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: "/SaveScreen"),
                    builder: (context) => SaveScreen(
                      userId: widget.userId,
                      parameters: widget.parameters,
                      backgroundImage:
                          MyType<Uint8List>(widget.backgroundImage.value!),
                      settings: settings,
                      images: images,
                      saveNew: true,
                      showId: null,
                      previewId: widget.previewId,
                    ),
                  ),
                );
              }
            },
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
    );
  }

  void saveOptionDialog() {
    for (var card in settings) {
      if (card.loading) {
        return;
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.accentBlack,
        title: Text(
          'Saving option',
          style: TextStyle(
            color: themeColors.darkOrange,
          ),
        ),
        content: Text(
          'How do you want the show to be saved?',
          style: TextStyle(color: themeColors.darkOrange, fontSize: 20),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: "/SaveScreen"),
                  builder: (context) => SaveScreen(
                    userId: widget.userId,
                    parameters: widget.parameters,
                    backgroundImage:
                        MyType<Uint8List>(widget.backgroundImage.value!),
                    settings: settings,
                    images: images,
                    saveNew: false,
                    showId: widget.showId,
                    previewId: widget.previewId,
                  ),
                ),
              );
            },
            child: Text(
              'Save as edit',
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: "/SaveScreen"),
                  builder: (context) => SaveScreen(
                    userId: widget.userId,
                    parameters: widget.parameters,
                    backgroundImage:
                        MyType<Uint8List>(widget.backgroundImage.value!),
                    settings: settings,
                    images: images,
                    saveNew: true,
                    showId: null,
                    previewId: widget.previewId,
                  ),
                ),
              );
            },
            child: Text(
              'Save as new',
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
    );
  }
}
