import 'package:flutter_plugin_pdf_viewer/src/mode_enum.dart';
import 'package:flutter_plugin_pdf_viewer/src/viewer_interface.dart';

class PDFViewerController {
  PdfViewerInterface pdfViewer;

  PDFViewerController();

  int currentPage = 0;
  double zoomValue = 1;

  Future<void> changePage(int index) async {
    await pdfViewer.changePage(index);
    currentPage = index;
  }

  void setMode() {
    pdfViewer.toggleMode();
  }
}
