import 'package:flutter/material.dart';
import 'dart:math' show pi;

class CustomLoader extends StatefulWidget {
  final double outerSize;
  final double innerSize;
  final Color color;
  final double opacity;
  final bool isRefreshing;

  const CustomLoader({
    Key? key,
    this.outerSize = 150,
    this.innerSize = 50,
    this.color = const Color(0xFF1976D2),
    this.opacity = 0.7,
    this.isRefreshing = true,
  }) : super(key: key);

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _reverseRotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _reverseRotateAnimation = Tween<double>(
      begin: 0.0,
      end: -2 * pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    if (widget.isRefreshing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing != oldWidget.isRefreshing) {
      if (widget.isRefreshing) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer settings icon rotating counter-clockwise
            Transform.rotate(
              angle: _reverseRotateAnimation.value,
              child: Icon(
                Icons.settings,
                size: widget.outerSize,
                color: widget.color.withOpacity(widget.opacity),
              ),
            ),
            // Inner settings icon rotating clockwise
            Transform.rotate(
              angle: _rotateAnimation.value,
              child: Icon(
                Icons.settings,
                size: widget.innerSize,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 