import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import 'dart:ui' as ui;

import 'package:showmaker/common/myType.dart';

class ImageEditTest extends StatefulWidget {
  final MyType<Uint8List?> image;

  const ImageEditTest({super.key, required this.image});

  @override
  State<ImageEditTest> createState() => _ImageEditTestState();
}

class _ImageEditTestState extends State<ImageEditTest> {
  Uint8List? edit;
  int cnt = 0;

  double val = 10;

  bool capture = false;
  GlobalKey key = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    if (widget.image.value != null)
      edit = Uint8List.fromList(widget.image.value!.cast());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*widgetTest();
    if (widget.image != null) {
      cnt = (cnt + 1) % 2;
      if (cnt == 1) makeEdit();
    }*/
    return Scaffold(
      body: Center(
          child: edit != null
              ? Image.memory(
                  edit!,
                  fit: BoxFit.fill,
                )
              : null),
      floatingActionButton: IconButton(
        icon: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          val += 10;
          captureWidget();
        },
      ),
    );
  }

  Widget getEditingWidget() {
    return RepaintBoundary(
      key: key,
      child: Container(
          height: val,
          width: val,
          color: val == 20 ? Colors.black : Colors.red,
          child: Image.memory(
            widget.image.value!,
            fit: BoxFit.fill,
          )),
    );
  }

  Future<void> captureWidget() async {
    edit = await screenshotController.captureFromWidget(getEditingWidget());
    setState(() {});
  }

  Future<Uint8List> convertToRgba(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      1024,
      1024,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return (await (await completer.future).toByteData())!.buffer.asUint8List();
  }

  /*void widgetTest() async {
    setState(() {});
    GlobalKey key = GlobalKey();
    Widget widget = RepaintBoundary(
      key: key,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.red,
      ),
    );
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    int i = 0;
  }*/

  /* void makeEdit() async {
    final tempDir = await getTemporaryDirectory();
    final currentDir = Directory.current.path;

    Uint8List bytes; //= await convertToRgba(widget.image.value!);
    /*(await http.get(Uri.parse(
            'https://raw.githubusercontent.com/betalgo/openai/master/OpenAI.Playground/SampleData/image_edit_original.png')))
        .bodyBytes;*/

    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(widget.image.value!);
    /*bytes = await convertToRgba(file.readAsBytesSync());
    file.delete();
    file.create();
    file.writeAsBytesSync(bytes);*/

    String uri =
        'https://png.pngtree.com/element_our/sm/20180323/sm_5ab4a26e8d73b.png'; //'https://raw.githubusercontent.com/betalgo/openai/master/OpenAI.Playground/SampleData/image_edit_mask.png'
    //(await OpenAI.instance.image.create(prompt: 'Rhino')).data[0].url ?? '';

    //bytes = (await http.get(Uri.parse(uri))).bodyBytes;
    //bytes = await convertToRgba(bytes);

    bytes =
        (await rootBundle.load('assets/masks/mask1.png')).buffer.asUint8List();
    Image img = Image.memory(bytes);

    //(await http.get(Uri.parse(uri))).bodyBytes;
    File? mask = await File('${tempDir.path}/mask.png').create();
    mask.writeAsBytesSync(bytes);

    edit = (await http.get(Uri.parse((await OpenAI.instance.image.edit(
                    image: file,
                    mask: mask,
                    prompt: 'Edit the image',
                    size: OpenAIImageSize.size1024))
                .data[0]
                .url ??
            '')))
        .bodyBytes;
    setState(() {});
  }*/
}
