import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:showmaker/common/messages.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/database/Show/dbMethods.dart';
import 'package:showmaker/database/Show/show.dart';
import 'package:showmaker/database/ShowPreview/dbMethods.dart';
import 'package:showmaker/database/ShowPreview/showPreview.dart';
import 'package:showmaker/database/Slide/dbMethods.dart';
import 'package:showmaker/database/Slide/slide.dart';
import 'package:showmaker/database/Slide/slideSettings.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/prompting/parameters.dart' as par;
import 'package:pdf/widgets.dart' as pw;

class SaveScreen extends StatefulWidget {
  final par.Parameters parameters;
  final MyType<Uint8List> backgroundImage;
  final List<SlideSettings> settings;
  final List<Uint8List> images;
  final String userId;
  final bool saveNew;
  final String? showId;
  final String? previewId;

  const SaveScreen(
      {required this.parameters,
      required this.backgroundImage,
      required this.settings,
      required this.userId,
      required this.images,
      required this.saveNew,
      required this.showId,
      required this.previewId,
      super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState(
      parameters: parameters,
      backgroundImage: backgroundImage,
      settings: settings);
}

class _SaveScreenState extends State<SaveScreen> {
  par.Parameters parameters;
  MyType<Uint8List> backgroundImage;
  List<SlideSettings> settings;

  _SaveScreenState({
    required this.parameters,
    required this.backgroundImage,
    required this.settings,
  });

  bool loading = true;
  bool downloading = false;
  String message = '';

  double aheight = 0;
  double awidth = 0;

  String? downloadPath;

  late Show show;

  @override
  void initState() {
    super.initState();
    saveShow();
    getDownloadPath();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);

    aheight = queryData.size.height;
    awidth = queryData.size.width;

    return WillPopScope(
      onWillPop: showExitPopup, //call function on back button press
      child: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [themeColors.lightBlack, themeColors.darkBlack],
                  transform: GradientRotation(pi / 4)),
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  if (!loading)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: CustomButton(
                          widget: Text(
                            "Done",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w400),
                          ),
                          width: 120,
                          height: 45,
                          backgroundColors: [
                            themeColors.accentBlack,
                          ],
                          shadowColor: themeColors.darkOrange,
                          blurRadius: 7,
                          borderRadius: BorderRadius.circular(10),
                          splashColor: Colors.white.withOpacity(0.2),
                          activated: true,
                          onPressed: () {
                            Navigator.popUntil(
                                context, ModalRoute.withName("/MainScreen"));
                          },
                        ),
                      ),
                    ),
                  Spacer(),
                  if (loading)
                    CircularProgressIndicator(
                      color: themeColors.yellowOrange,
                    ),
                  if (loading)
                    SizedBox(
                      height: 10,
                    ),
                  Text(
                    message,
                    style: TextStyle(fontSize: 25),
                  ),
                  Spacer(),
                  //
                  if (!loading &&
                      message == "Completed" &&
                      downloadPath != null)
                    CustomButton(
                      widget: Text(
                        "Download PDF",
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w400),
                      ),
                      width: 190,
                      height: 50,
                      borderColors: [
                        themeColors.yellowOrange,
                        themeColors.lightOrange,
                        themeColors.darkOrange
                      ],
                      borderWidth: 2,
                      backgroundColors: [themeColors.accentBlack],
                      borderRadius: BorderRadius.circular(10),
                      activated: !downloading,
                      onPressed: () => downloadPDF(),
                    ),
                  //
                  SizedBox(
                    height: 20,
                  ),
                  //

                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void saveShow() async {
    List<String> urls = [];

    loading = true;

    List<Slide> slides = [];
    for (int i = 0; i < parameters.slideCount; i++) {
      slides.add(Slide(parameters.slideTitle[i], settings[i]));
    }

    DateTime creationDate = DateTime.now();

    show = Show(
        userId: widget.userId,
        title: parameters.title,
        subject: parameters.subject,
        coverSlideUrl: "",
        backgroundImgUrl: "",
        previewId: "",
        parameters: parameters,
        slides: slides,
        creationDate: creationDate);

    if (!widget.saveNew) {
      show.setId(widget.showId);
    }

    if (widget.saveNew) {
      message = "Creating the show";
      setState(() {});

      message = await createShow(show);
    }

    message = "Uploading the slides";
    setState(() {});

    urls = await uploadSlidesImages(widget.images, show.getId()!);
    for (int i = 0; i < parameters.slideCount; i++) {
      slides[i].settings.slideUrl = urls[i];
    }

    if (widget.saveNew) {
      message = "Creating the preview";
    } else {
      message = "Updating the preview";
    }
    setState(() {});

    show.backgroundImgUrl =
        await uploadBackground(backgroundImage.value, show.getId()!);
    show.coverSlideUrl = urls[0];

    ShowPreview preview = ShowPreview(
        userId: widget.userId,
        showId: show.getId()!,
        title: show.parameters.title,
        slideCount: show.parameters.slideCount,
        coverSlideUrl: show.coverSlideUrl,
        creationDate: creationDate);
    if (!widget.saveNew) {
      preview.setId(widget.previewId!);
    }

    if (widget.saveNew) {
      message = await createPreview(preview);
    } else {
      message = await updatePreview(preview);
    }

    show.previewId = preview.getId() ?? '';
    message = "Saving the show";
    setState(() {});

    message = await updateShow(show);

    loading = false;
    setState(() {});
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: themeColors.accentBlack,
            title: Text(
              'Exit saving?',
              style: TextStyle(
                color: themeColors.darkOrange,
              ),
            ),
            content: Text(
              'The saving process will be cancelled',
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
                onPressed: () => Navigator.popUntil(
                    context, ModalRoute.withName("/MainScreen")),
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

  void getDownloadPath() async {
    downloadPath = null;
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
          content: "Cannot get download folder path", textColor: Colors.red));
    }
    downloadPath = directory?.path;
    setState(() {});
  }

  void downloadPDF() async {
    downloading = true;
    setState(() {});

    final pdf = pw.Document();

    for (var image in widget.images) {
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.undefined,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(image)),
            ); // Center
          }));
    }

    final file = File(downloadPath! + '/${show.title}.pdf');
    try {
      file.writeAsBytesSync(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
          content: "The pdf was saved", textColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
          content: "Error downloading the pdf", textColor: Colors.red));
    }
    downloading = false;
    setState(() {});
  }
}
