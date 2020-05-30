import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_plugin_pdf_viewer/src/mode_enum.dart';
import 'package:flutter_plugin_pdf_viewer/src/page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../flutter_plugin_pdf_viewer.dart';

class PDFDocument {
  static const MethodChannel _channel =
      const MethodChannel('flutter_plugin_pdf_viewer');

  String _filePath;
  int count;
  PDFViewerController controller;

  /// Load a PDF File from a given File
  ///
  ///
  static Future<PDFDocument> fromFile(
      File f, PDFViewerController controller) async {
    PDFDocument document = PDFDocument();
    document._filePath = f.path;
    document.controller = controller;
    try {
      var pageCount =
          await _channel.invokeMethod('getNumberOfPages', {'filePath': f.path});
      document.count = document.count = int.parse(pageCount);
      populateOffsets(document, controller);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  static void populateOffsets(
      PDFDocument document, PDFViewerController controller) {
    for (var i = 0; i < document.count; i++) {
      List<Offset> pageOffset = [];
      controller.pageOffset.add(pageOffset);
    }
  }

  /// Load a PDF File from a given URL.
  /// File is saved in cache
  ///
  static Future<PDFDocument> fromURL(
      String url, List<Offset> data, PDFViewerController controller) async {
    // Download into cache
    File f = await DefaultCacheManager().getSingleFile(url);
    PDFDocument document = PDFDocument();
    document._filePath = f.path;
    document.controller = controller;
    try {
      var pageCount =
          await _channel.invokeMethod('getNumberOfPages', {'filePath': f.path});
      document.count = document.count = int.parse(pageCount);
      populateOffsets(document, controller);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Load a PDF File from assets folder
  ///
  ///
  static Future<PDFDocument> fromAsset(
      String asset, List<Offset> data, PDFViewerController controller) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    File file;
    try {
      var dir = await getApplicationDocumentsDirectory();
      file = File("${dir.path}/file.pdf");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    PDFDocument document = PDFDocument();
    document._filePath = file.path;
    document.controller = controller;
    try {
      var pageCount = await _channel
          .invokeMethod('getNumberOfPages', {'filePath': file.path});
      document.count = document.count = int.parse(pageCount);
      populateOffsets(document, controller);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Load specific page
  ///
  /// [page] defaults to `1` and must be equal or above it
  Future<PDFPage> get(PDFMode mode, {int page = 1}) async {
    assert(page > 0);
    var data = await _channel
        .invokeMethod('getPage', {'filePath': _filePath, 'pageNumber': page});
    List<Offset> drawingData = controller.pageOffset[page];
    return new PDFPage(data, page, mode, drawingData, controller);
  }

  // Stream all pages
  Observable<PDFPage> getAll(
    PDFMode mode,
  ) {
    return Future.forEach<PDFPage>(List(count), (i) async {
      print(i);
      final data = await _channel
          .invokeMethod('getPage', {'filePath': _filePath, 'pageNumber': i});
      List<Offset> drawingData = controller.pageOffset[i.num];
      return new PDFPage(data, 1, mode, drawingData, controller);
    }).asStream();
  }
}
