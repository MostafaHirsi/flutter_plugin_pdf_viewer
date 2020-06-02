import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter_plugin_pdf_viewer/src/mode_enum.dart';
import 'package:flutter_plugin_pdf_viewer/src/viewer_interface.dart';
import 'package:numberpicker/numberpicker.dart';
import 'controller.dart';
import 'tooltip.dart';

enum IndicatorPosition { topLeft, topRight, bottomLeft, bottomRight }

class PDFViewer extends StatefulWidget {
  final PDFDocument document;
  final Color indicatorText;
  final Color indicatorBackground;
  final IndicatorPosition indicatorPosition;
  final bool showIndicator;
  final bool showPicker;
  final bool showNavigation;
  final PDFViewerTooltip tooltip;
  final PDFViewerController pdfViewerController;

  PDFViewer(
      {Key key,
      @required this.document,
      this.indicatorText = Colors.white,
      this.indicatorBackground = Colors.black54,
      this.showIndicator = true,
      this.showPicker = true,
      this.showNavigation = true,
      this.tooltip = const PDFViewerTooltip(),
      this.indicatorPosition = IndicatorPosition.topRight,
      this.pdfViewerController})
      : super(key: key);

  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> implements PdfViewerInterface {
  bool _isLoading = true;
  int _oldPage = 0;
  PDFPage _page;
  List<PDFPage> _pages = List();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _oldPage = 0;
    widget.pdfViewerController.currentPage = 1;
    _isLoading = true;
    _pages.clear();
    _loadPage();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.pdfViewerController?.pdfViewer = this;
  }

  @override
  void didUpdateWidget(PDFViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _oldPage = 0;
    widget.pdfViewerController.currentPage = 1;
    _isLoading = true;
    _pages.clear();
    _loadPage();
  }

  _loadPage({PDFMode viewMode = PDFMode.View}) async {
    setState(() => _isLoading = true);
    if (_oldPage == 0) {
      _page = await widget.document.get(viewMode, page: widget.pdfViewerController.currentPage);
    } else if (_oldPage != widget.pdfViewerController.currentPage) {
      _oldPage = widget.pdfViewerController.currentPage;
      _page = await widget.document.get(viewMode, page: widget.pdfViewerController.currentPage);
    }
    if (this.mounted) {
      setState(() => _isLoading = false);
    }
  }

  _toggleView({PDFMode viewMode = PDFMode.View}) async {
    if (_oldPage == 0) {
      _page = await widget.document.get(viewMode, page: widget.pdfViewerController.currentPage);
    } else if (_oldPage != widget.pdfViewerController.currentPage) {
      _oldPage = widget.pdfViewerController.currentPage;
      _page = await widget.document.get(viewMode, page: widget.pdfViewerController.currentPage);
    }
    setState(() {});
  }

  Widget _drawIndicator() {
    Widget child = GestureDetector(
        onTap: _pickPage,
        child: Container(
            padding:
                EdgeInsets.only(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: widget.indicatorBackground),
            child: Text("$widget.pdfViewerController.currentPage/${widget.document.count}",
                style: TextStyle(
                    color: widget.indicatorText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400))));

    switch (widget.indicatorPosition) {
      case IndicatorPosition.topLeft:
        return Positioned(top: 20, left: 20, child: child);
      case IndicatorPosition.topRight:
        return Positioned(top: 20, right: 20, child: child);
      case IndicatorPosition.bottomLeft:
        return Positioned(bottom: 20, left: 20, child: child);
      case IndicatorPosition.bottomRight:
        return Positioned(bottom: 20, right: 20, child: child);
      default:
        return Positioned(top: 20, right: 20, child: child);
    }
  }

  _pickPage() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.integer(
            title: Text(widget.tooltip.pick),
            minValue: 1,
            cancelWidget: Container(),
            maxValue: widget.document.count,
            initialIntegerValue: widget.pdfViewerController.currentPage,
          );
        }).then((int value) {
      if (value != null) {
        widget.pdfViewerController.currentPage = value;
        _loadPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: widget.showNavigation ? 90 : 100,
          child: Stack(
            children: <Widget>[
              _isLoading
                  ? Center(
                      child: Platform.isIOS
                          ? CupertinoActivityIndicator()
                          : CircularProgressIndicator(),
                    )
                  : _page,
              (widget.showIndicator && !_isLoading)
                  ? _drawIndicator()
                  : Container(),
            ],
          ),
        ),
        if (widget.showNavigation)
          Flexible(
            flex: 10,
            child: buildBottomBar(),
          )
      ],
    );
  }

  Widget buildBottomBar() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: IconButton(
              icon: Icon(Icons.first_page),
              tooltip: widget.tooltip.first,
              onPressed: () {
                widget.pdfViewerController.currentPage = 1;
                _loadPage();
              },
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.chevron_left),
              tooltip: widget.tooltip.previous,
              onPressed: () {
                widget.pdfViewerController.currentPage--;
                if (1 > widget.pdfViewerController.currentPage) {
                  widget.pdfViewerController.currentPage = 1;
                }
                _loadPage();
              },
            ),
          ),
          widget.showPicker ? Expanded(child: Text('')) : SizedBox(width: 1),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.chevron_right),
              tooltip: widget.tooltip.next,
              onPressed: () {
                widget.pdfViewerController.currentPage++;
                if (widget.document.count < widget.pdfViewerController.currentPage) {
                  widget.pdfViewerController.currentPage = widget.document.count;
                }
                _loadPage();
              },
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.last_page),
              tooltip: widget.tooltip.last,
              onPressed: () {
                widget.pdfViewerController.currentPage = widget.document.count;
                _loadPage();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> changePage(int index) {
    if (index != null) {
      widget.pdfViewerController.currentPage = index;
      _loadPage();
    }
  }

  @override
  Future<void> toggleMode() {
    widget.pdfViewerController.pdfMode =
        widget.pdfViewerController.pdfMode == PDFMode.View
            ? PDFMode.Annotate
            : PDFMode.View;
    _toggleView(viewMode: widget.pdfViewerController.pdfMode);
  }
}
