import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/src/mode_enum.dart';
import 'package:flutter_plugin_pdf_viewer/src/viewer_interface.dart';

class PDFViewerController {
  PdfViewerInterface pdfViewer;

  PDFViewerController({this.onChanged});

  int currentPage = 0;
  double zoomValue = 1;
  PDFMode pdfMode = PDFMode.View;
  List<List<Offset>> pageOffset = [];
  Function(List<Offset>) onChanged;
  Function(PDFMode) onModeChanged;
  Offset zoomOffset;
  double height;
  double width;
  double aspectRatio;
  Function() loaded;

  Future<void> changePage(int index) async {
    await pdfViewer.changePage(index);
    currentPage = index;
  }

  void setMode() {
    pdfViewer.toggleMode();
    onModeChanged(pdfMode);
  }
}
