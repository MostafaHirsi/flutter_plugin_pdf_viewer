import 'dart:math';

import 'package:flutter/material.dart';

class OuterGesture extends StatefulWidget {
  final Widget child;

  const OuterGesture({Key key, this.child}) : super(key: key);
  @override
  _OuterGestureState createState() => _OuterGestureState();
}

class _OuterGestureState extends State<OuterGesture> {
  double _scale = 2.0;
  double rotation = 2.0;
  double _previousScale = null;

  Offset panOffset = Offset(0.5, 0.5);
  int pointers = 0;
  bool touchBegan = false;

  double _zoom = 1.0;
  double _previousZoom = 1.0;
  Offset _previousPanOffset = Offset.zero;
  Offset _pan = Offset.zero;
  Offset _zoomOriginOffset = Offset.zero;

  Size _childSize = Size.zero;
  Size _containerSize = Size.zero;

  void _onScaleStart(ScaleStartDetails details) {
    if (_childSize == Size.zero) {
      final RenderBox renderbox = _key.currentContext.findRenderObject();
      _childSize = renderbox.size;
    }
    setState(() {
      _zoomOriginOffset = details.focalPoint;
      _previousPanOffset = _pan;
      _previousZoom = _zoom;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    Size boundarySize = _boundarySize;

    Size _marginSize = const Size(100.0, 100.0);

    setState(() {
      if (details.scale != 1.0) {
        _zoom = (_previousZoom * details.scale).clamp(1.0, 3.0);
      }
    });

    if (details.scale != 1.0) {
      Offset _panRealOffset = (details.focalPoint -
              _zoomOriginOffset +
              _previousPanOffset * _previousZoom) /
          _zoom;
      Offset _baseOffset = Offset(
        _panRealOffset.dx
            .clamp(-boundarySize.width / 2, boundarySize.width / 2),
        _panRealOffset.dy
            .clamp(-boundarySize.height / 2, boundarySize.height / 2),
      );

      Offset _marginOffset = _panRealOffset - _baseOffset;
      double _widthFactor = sqrt(_marginOffset.dx.abs()) / _marginSize.width;
      double _heightFactor = sqrt(_marginOffset.dy.abs()) / _marginSize.height;
      _marginOffset = Offset(
        _marginOffset.dx * _widthFactor * 2,
        _marginOffset.dy * _heightFactor * 2,
      );
      _pan = _baseOffset + _marginOffset;
      setState(() {});
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    Size boundarySize = _boundarySize;

    final Offset velocity = details.velocity.pixelsPerSecond;
    final double magnitude = velocity.distance;
    if (magnitude > 800.0 * _zoom) {
      final Offset direction = velocity / magnitude;
      final double distance = (Offset.zero & context.size).shortestSide;
      final Offset endOffset = _pan + direction * distance * 1.0 * 0.5;
      _pan = Offset(
        endOffset.dx.clamp(-boundarySize.width / 2, boundarySize.width / 2),
        endOffset.dy.clamp(-boundarySize.height / 2, boundarySize.height / 2),
      );
    }
    Offset _clampedOffset = Offset(
      _pan.dx.clamp(-boundarySize.width / 2, boundarySize.width / 2),
      _pan.dy.clamp(-boundarySize.height / 2, boundarySize.height / 2),
    );
    // if (_zoom == widget.minScale && widget.autoCenter) {
    //   _clampedOffset = Offset.zero;
    // }
    setState(() => _pan = _clampedOffset);
  }

  Size get _boundarySize {
    Size _boundarySize = Size(
          (_containerSize.width == _childSize.width)
              ? (_containerSize.width - _childSize.width / _zoom).abs()
              : (_containerSize.width - _childSize.width * _zoom).abs() / _zoom,
          (_containerSize.height == _childSize.height)
              ? (_containerSize.height - _childSize.height / _zoom).abs()
              : (_containerSize.height - _childSize.height * _zoom).abs() /
                  _zoom,
        ) *
        1.0;

    return _boundarySize;
  }

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _containerSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Center(
            child: Container(
              key: _key,
              child: Transform(
                origin: Offset(-_pan.dx, -_pan.dy),
                transform: Matrix4.identity()
                  ..translate(_pan.dx, _pan.dy)
                  ..scale(_zoom),
                alignment: FractionalOffset(panOffset.dx, panOffset.dy),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
