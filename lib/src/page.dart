import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:flutter_plugin_pdf_viewer/src/mode_enum.dart';
import 'package:photo_view/photo_view.dart';

import '../flutter_plugin_pdf_viewer.dart';
import 'annotater.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    photoViewController.addIgnorableListener(() {
      double scale = getScale(photoViewController.scale);
      Offset offset = getPosition(photoViewController.position, (scale));
      print("PositionX: " + offset.dx.toString());
      print("PositionY: " + offset.dy.toString());

      print("Zoom Cleaned: " + scale.toString());
      print("Zoom : " + (photoViewController.scale).toString());
      setState(() {});
    });
  }

  double getScale(double inputScale) {
    double roundedDecimalPoint = dp(inputScale, 2);
    double cleanScale = roundedDecimalPoint > 0.2 ? roundedDecimalPoint : 0;
    return (1 / (1 - cleanScale));
  }

  Offset getPosition(Offset position, double scale) {
    // Offset offset = Offset((-position.dx / scale), (-position.dy / scale));
    Offset offset =
        Offset.fromDirection(position.direction, -position.distance);
    return offset;
  }

  double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
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
    final resolver = provider.resolve(createLocalImageConfiguration(context));
    resolver.addListener(ImageStreamListener((imgInfo, alreadyPainted) {
      height = imgInfo.image.height;
      width = imgInfo.image.width;
      if (!alreadyPainted) setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    List<Offset> offsets = widget.controller.pageOffset[widget.num - 1];
    if (widget.mode == PDFMode.Annotate) {
      return Transform.scale(
        scale: photoViewController.scale,
        origin: getPosition(
            photoViewController.position, photoViewController.scale),
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Image.file(
                  File(widget.imgPath),
                ),
              ),
              if (width != null && width > 1)
                AspectRatio(
                  aspectRatio: width / height,
                  child: Annotater(
                    data: offsets,
                    onChanged: widget.controller.onChanged(offsets),
                    showOverlay: true,
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                File(widget.imgPath),
              ),
              if (width != null && width > 1)
                IgnorePointer(
                  child: AspectRatio(
                    aspectRatio: width / height,
                    child: Annotater(
                      data: offsets,
                      onChanged: null,
                    ),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}

// scale: 1.88,
// origin: Offset(
//   511/2.5,
//   663/2.5,
// ),
