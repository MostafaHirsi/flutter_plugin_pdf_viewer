import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Annotater extends StatefulWidget {
  final List<Offset> data;
  final Function(List<Offset>) onChanged;
  final bool showOverlay;

  const Annotater(
      {Key key, this.data, this.onChanged, this.showOverlay = false})
      : super(key: key);
  @override
  _AnnotaterState createState() => _AnnotaterState();
}

class _AnnotaterState extends State<Annotater> {
  bool _isVisible0 = true;
  final _frameColor = Colors.white;

  int _currentFrame = 0;
  int currentPointer;
  // For accessing the RenderBox of each frame
  final _frame0Key = GlobalKey();

  List<int> pointers = [];

  @override
  Widget build(BuildContext context) {
    return _buildGestureDetector(
      context,
      Container(
        color: Colors.red.withOpacity(0.5),
        child: _buildPositionedFrame(
            context: context,
            frameKey: _frame0Key,
            points: widget.data,
            isVisible: _isVisible0,
            frameIndex: 0),
      ),
    );
  }

  Widget _buildGestureDetector(BuildContext context, Widget child) {
    return Listener(
      onPointerDown: (details) {
        pointers.add(details.pointer);
        if (pointers.length == 1) {
          currentPointer = details.pointer;
          setState(() {
            _addPointsForCurrentFrame(details.position);
          });
        }
      },
      onPointerMove: (details) {
        if (pointers.length == 1) {
          setState(() {
            _addPointsForCurrentFrame(details.position);
          });
        }
      },
      onPointerUp: (details) {
        pointers.remove(details.pointer);
        if (details.pointer == currentPointer) {
          setState(() {
            _getPointsForFrame(_currentFrame).add(null);
          });
          currentPointer = null;
        }
      },
      child: child,
    );
  }

  void _addPointsForCurrentFrame(Offset globalPosition) {
    final RenderBox renderBox =
        _getWidgetKeyForFrame(_currentFrame).currentContext.findRenderObject();
    final offset = renderBox.globalToLocal(globalPosition);

    _getPointsForFrame(_currentFrame).add(offset);
  }

  List<Offset> _getPointsForFrame(int frameIndex) {
    return widget.data;
  }

  GlobalKey _getWidgetKeyForFrame(int frameIndex) {
    return _frame0Key;
  }

  Widget _buildPositionedFrame(
      {BuildContext context,
      GlobalKey frameKey,
      List<Offset> points,
      bool isVisible,
      int frameIndex}) {
    return Opacity(
      opacity: 0.3,
      child: Container(
        key: frameKey,
        color: _frameColor,
        child: SizedBox(
          child: ClipRect(child: _buildCustomPaint(context, points)),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  Widget _buildCustomPaint(BuildContext context, List<Offset> points) =>
      CustomPaint(
        painter: FlipBookPainter(points, widget.onChanged),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      );

  void _clearPoints() {
    widget.data.clear();
  }
}

class FlipBookPainter extends CustomPainter {
  final List<Offset> offsets;
  final Function(List<Offset>) onChanged;
  FlipBookPainter(this.offsets, this.onChanged) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..isAntiAlias = true
      ..strokeWidth = 2.0;
    int diffCounter = 0;
    for (var i = 0; i < offsets.length; i++) {
      diffCounter++;
      if (shouldDrawLine(i)) {
        canvas.drawLine(offsets[i], offsets[i + 1], paint);
        submitChange(diffCounter);
      } else if (shouldDrawPoint(i)) {
        canvas.drawPoints(PointMode.points, [offsets[i]], paint);
        submitChange(diffCounter);
      }
    }
  }

  void submitChange(int diffCounter) {
    if (diffCounter > 20) {
      if (onChanged != null) {
        onChanged(offsets);
      }
      diffCounter = 0;
    }
  }

  bool shouldDrawPoint(int i) =>
      offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] == null;

  bool shouldDrawLine(int i) =>
      offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] != null;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
