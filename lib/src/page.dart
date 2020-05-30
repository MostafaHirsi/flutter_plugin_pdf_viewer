import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:flutter_plugin_pdf_viewer/src/mode_enum.dart';

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
      if (!alreadyPainted) setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    List<Offset> offsets = widget.controller.pageOffset[widget.num];
    if (widget.mode == PDFMode.Annotate) {
      return Transform.scale(
        alignment: Alignment.center,
        scale: widget.controller.zoomValue,
        child: Stack(
          children: [
            Image(image: provider),
            Annotater(
              data: offsets,
              onChanged: (offsets) {
                widget.controller.onChanged(offsets);
              },
            ),
          ],
        ),
      );
    }
    return ZoomableWidget(
      zoomSteps: 3,
      minScale: 1.0,
      panLimit: 0.8,
      maxScale: 3.0,
      singleFingerPan: false,
      onZoomChanged: (value) {
        widget.controller.zoomValue = value;
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image(image: provider),
          Annotater(
            data: offsets,
            onChanged: (offsets) {},
          ),
        ],
      ),
    );
  }
}
