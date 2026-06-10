import 'package:flutter/material.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.onReply,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> {
  double _dragExtent = 0;
  static const double _maxDrag = 60.0;
  static const double _threshold = 40.0;
  bool _triggered = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Only allow swiping left (negative delta)
    if (details.primaryDelta! < 0 || _dragExtent < 0) {
      setState(() {
        _dragExtent += details.primaryDelta!;
        if (_dragExtent.abs() > _maxDrag) {
          _dragExtent = -_maxDrag;
        }
        
        if (_dragExtent.abs() >= _threshold && !_triggered) {
          _triggered = true;
          // You could provide haptic feedback here
        } else if (_dragExtent.abs() < _threshold) {
          _triggered = false;
        }
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_triggered) {
      widget.onReply();
    }
    setState(() {
      _dragExtent = 0;
      _triggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          if (_dragExtent < 0)
            Positioned(
              right: 10 + (_dragExtent.abs() * 0.5),
              child: Opacity(
                opacity: (_dragExtent.abs() / _maxDrag).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: app_theme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.reply,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
