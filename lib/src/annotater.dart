import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Annotater extends StatefulWidget {
  final List<Offset> data;

  const Annotater({Key key, this.data}) : super(key: key);
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

  @override
  Widget build(BuildContext context) {
    return _buildGestureDetector(
      context,
      Container(
        color: Colors.white.withOpacity(0.5),
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
        if (currentPointer == null) {
          currentPointer = details.pointer;
          setState(() {
            _addPointsForCurrentFrame(details.position);
          });
        }
      },
      onPointerMove: (details) {
        if (details.pointer == currentPointer) {
          setState(() {
            _addPointsForCurrentFrame(details.position);
          });
        }
      },
      onPointerUp: (details) {
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
        painter: FlipBookPainter(points),
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

  FlipBookPainter(this.offsets) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..isAntiAlias = true
      ..strokeWidth = 2.0;

    for (var i = 0; i < offsets.length; i++) {
      if (shouldDrawLine(i)) {
        canvas.drawLine(offsets[i], offsets[i + 1], paint);
      } else if (shouldDrawPoint(i)) {
        canvas.drawPoints(PointMode.points, [offsets[i]], paint);
      }
    }
  }

  bool shouldDrawPoint(int i) =>
      offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] == null;

  bool shouldDrawLine(int i) =>
      offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] != null;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
