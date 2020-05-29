abstract class PdfViewerInterface {
  Future<void> changePage(int index);

  Future<void> toggleMode();
}
