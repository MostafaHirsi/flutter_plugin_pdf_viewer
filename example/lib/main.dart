import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  PDFDocument document;
  final PDFViewerController pdfViewerController = PDFViewerController();
  List<Offset> data = <Offset>[];

  @override
  void initState() {
    super.initState();
    loadDocument();
    pdfViewerController.onChanged = onChanged;
  }

  onChanged(List<Offset> offsets) {
    print("OFFSET CHANGED");
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset(
        'assets/sample 2.pdf', data, pdfViewerController);

    setState(() => _isLoading = false);
  }

  changePDF(value) async {
    setState(() => _isLoading = true);
    if (value == 1) {
      document = await PDFDocument.fromAsset(
          'assets/sample.pdf', data, pdfViewerController);
    } else if (value == 2) {
      document = await PDFDocument.fromURL(
          "https://firebasestorage.googleapis.com/v0/b/yaktub-c0b33.appspot.com/o/5n4yyFfqhXTHXdWa3iPMsW2CA453%2FStatement%2021-FEB-20%20AC%2033656225.pdf?alt=media&token=766f4ef8-9f88-4e19-beca-5e2ebc227bfd",
          data,
          pdfViewerController);
    } else {
      document = await PDFDocument.fromAsset(
          'assets/sample.pdf', data, pdfViewerController);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              SizedBox(height: 36),
              ListTile(
                title: Text('Load from Assets'),
                onTap: () {
                  changePDF(1);
                },
              ),
              ListTile(
                title: Text('Load from URL'),
                onTap: () {
                  changePDF(2);
                },
              ),
              ListTile(
                title: Text('Restore default'),
                onTap: () {
                  changePDF(3);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text('FlutterPluginPDFViewer'),
        ),
        body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(
                  document: document,
                  pdfViewerController: pdfViewerController,
                  showNavigation: false,
                  showIndicator: false,
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // await pdfViewerController.changePage(2);
            pdfViewerController.setMode();
          },
        ),
      ),
    );
  }
}
