import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:showmaker/common/messages.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/database/Show/dbMethods.dart';
import 'package:showmaker/database/Show/show.dart';
import 'package:showmaker/database/ShowPreview/dbMethods.dart';
import 'package:showmaker/database/Slide/dbMethods.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:http/http.dart' as http;
import 'package:showmaker/prompting/parameters.dart' as par;
import 'package:showmaker/screens/Show/configure/configureScreen.dart';
import 'package:showmaker/screens/Show/view/landscapeScreen.dart';
import 'package:showmaker/screens/Show/view/portraitScreen.dart';
import 'package:showmaker/screens/Slide/fullScreenImage.dart';
import 'package:pdf/widgets.dart' as pw;

class ViewShow extends StatefulWidget {
  final String id;
  const ViewShow({required this.id, super.key});

  @override
  State<ViewShow> createState() => _ViewShowState();
}

class _ViewShowState extends State<ViewShow> {
  bool loading = false;
  bool donwloading = false;

  String message = '';
  String? downloadPath;

  List<Uint8List> images = [];
  Uint8List? backgroundImg;

  MyType<int> currentImage = MyType(0);
  MyType<bool> downloaded = MyType(false);

  double aheight = 0, awidth = 0;

  Show? show;

  @override
  void initState() {
    initScreen();
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

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);

    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);*/
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);*/

    final orientation = queryData.orientation;

    aheight = queryData.size.height;
    awidth = queryData.size.width;
    return Scaffold(
      body: Container(
        height: aheight,
        width: awidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [themeColors.lightBlack, themeColors.darkBlack],
              transform: GradientRotation(pi / 4)),
        ),
        child: Center(
            child: loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        CircularProgressIndicator(
                          color: themeColors.yellowOrange,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          message,
                          style: TextStyle(fontSize: 25),
                        )
                      ])
                : orientation == Orientation.portrait
                    ? getPortraitScreen(
                        setState: setState,
                        context: context,
                        aheight: aheight,
                        awidth: awidth,
                        loading: loading,
                        message: message,
                        show: show,
                        images: images,
                        currentImage: currentImage,
                        downloadPDF: downloadPDF,
                        downloaded: downloaded,
                        downloadPath: downloadPath,
                        editDialog: editDialog,
                        deleteDialog: deleteDialog)
                    : getLandscapeScreen(
                        setState: setState,
                        context: context,
                        aheight: aheight,
                        awidth: awidth,
                        loading: loading,
                        message: message,
                        show: show,
                        images: images,
                        currentImage: currentImage,
                        downloadPDF: downloadPDF,
                        downloaded: downloaded,
                        downloadPath: downloadPath,
                        editDialog: editDialog,
                        deleteDialog: deleteDialog)),
      ),
    );
  }

  Future<void> initScreen() async {
    loading = true;
    message = '';
    setState(() {});

    Map<String, dynamic> data = await getShow(widget.id);
    if (data.containsKey('Error')) {
      message = data['Error'];
      loading = false;
      setState(() {});
      return;
    }

    show = Show.fromDatabase(data);
    show!.setId(widget.id);

    for (var slide in show!.slides) {
      try {
        images.add(
            (await http.get(Uri.parse(slide.settings.slideUrl))).bodyBytes);
      } catch (e) {
        message = e.toString();
        loading = false;
        setState(() {});
        return;
      }
    }

    try {
      backgroundImg =
          (await http.get(Uri.parse(show!.backgroundImgUrl))).bodyBytes;
    } catch (e) {
      message = e.toString();
      loading = false;
      setState(() {});
      return;
    }

    await getDownloadPath();

    loading = false;
    setState(() {});
  }

  Future<void> getDownloadPath() async {
    downloadPath = null;
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
          content: "Cannot get download folder path", textColor: Colors.red));
    }
    downloadPath = directory?.path;
    setState(() {});
  }

  void downloadPDF(
      {required List<Uint8List> images,
      required String title,
      required StateSetter state}) async {
    if (downloaded.value) return;
    downloaded.value = true;
    state(() {});

    final pdf = pw.Document();

    for (var image in images) {
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.undefined,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(image)),
            ); // Center
          }));
    }

    final file = File(downloadPath! + '/$title.pdf');
    try {
      file.writeAsBytesSync(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
          content: "The pdf was saved", textColor: Colors.green));
    } catch (e) {
      downloaded.value = false;

      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
          content: "Error downloading the pdf", textColor: Colors.red));
    }
    state(() {});
  }

  void editDialog(BuildContext context, Show show) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.accentBlack,
        title: Text(
          'Edit the show?',
          style: TextStyle(
            color: themeColors.darkOrange,
          ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    settings: RouteSettings(name: "/ConfigureScreen"),
                    builder: (context) => ConfigureScreen(
                          userId: show.userId,
                          parameters: show.parameters.getCopy(),
                          backgroundImage: MyType(backgroundImg),
                          images: images,
                          existing: true,
                          settings: show.getSettingsList(),
                          showId: show.getId(),
                          previewId: show.previewId,
                        )),
              );
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

  void deleteDialog(BuildContext context1, Show show, StateSetter state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.accentBlack,
        title: Text(
          'Delete the show?',
          style: TextStyle(
            color: themeColors.darkOrange,
          ),
        ),
        content: Text(
          'You will not be able to recover it!',
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
            onPressed: () async {
              loading = true;
              message = '';
              state(() {});

              Navigator.of(context1).pop();

              message = await deleteShow(show.getId()!);
              if (message == 'Complete') {
                message = await deletePreview(show.previewId);
                if (message == 'Complete') {
                  message = await deleteSlides(
                      show.getId()!, show.parameters.slideCount);
                }
              }
              if (message == 'Complete') {
                ScaffoldMessenger.of(context1).showSnackBar(customSnackBar(
                    content: "Deleted", textColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context1).showSnackBar(
                    customSnackBar(content: message, textColor: Colors.red));
              }
              Navigator.popUntil(context1, ModalRoute.withName("/MainScreen"));
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
}
