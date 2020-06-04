import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_plugin_pdf_viewer/src/mode_enum.dart';
import 'package:photo_view/photo_view.dart';

import '../flutter_plugin_pdf_viewer.dart';
import 'annotater.dart';
import 'outer_gesture.dart';

class PDFPage extends StatefulWidget {
  final PDFMode mode;
  final String imgPath;
  final int num;
  final List<Offset> data;
  final PDFViewerController controller;
  PDFPage(this.imgPath, this.num, this.mode, this.data, this.controller);

  @override
  _PDFPageState createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  ImageProvider provider;
  int height = 0;
  int width = 0;
  PhotoViewController photoViewController = new PhotoViewController();
  File file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    file = File(widget.imgPath);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repaint();
  }

  @override
  void didUpdateWidget(PDFPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imgPath != widget.imgPath) {
      _repaint();
    }
  }

  _repaint() {
    provider = FileImage(File(widget.imgPath));
    double longWidth = MediaQuery.of(context).size.width;
    final resolver = provider.resolve(
      createLocalImageConfiguration(context,
          size: new Size.fromWidth(longWidth)),
    );
    resolver.addListener(
      ImageStreamListener(
        (imgInfo, alreadyPainted) async {
          height = imgInfo.image.height;
          width = imgInfo.image.width;
          widget.controller.aspectRatio = height / width;
          Size size = context.size;
          widget.controller.height = size.width * widget.controller.aspectRatio;
          widget.controller.width = size.width;
          if (widget.controller.loaded != null) {
            widget.controller.loaded();
          }
          if (!alreadyPainted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Offset> offsets = widget.controller.pageOffset[widget.num - 1];
    if (widget.mode == PDFMode.Annotate) {
      return OuterGesture(
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Image.file(
                  file,
                ),
              ),
              if (width != null && width > 1)
                AspectRatio(
                  aspectRatio: width / height,
                  child: Annotater(
                    data: offsets,
                    onChanged: widget.controller.onChanged(offsets),
                    showOverlay: false,
                    active: true,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PhotoView.customChild(
          controller: photoViewController,
          minScale: 1.0,
          maxScale: 2.0,
          gestureDetectorBehavior: HitTestBehavior.deferToChild,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                file,
              ),
              if (width != null && width > 1)
                AspectRatio(
                  aspectRatio: width / height,
                  child: Annotater(
                    data: offsets,
                    onChanged: null,
                    showOverlay: false,
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
