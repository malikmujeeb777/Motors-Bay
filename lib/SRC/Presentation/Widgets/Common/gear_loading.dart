import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';

class GearLoading extends StatefulWidget {
  final double size;
  final Color? color;

  const GearLoading({
    super.key,
    this.size = 40.0,
    this.color,
  });

  @override
  State<GearLoading> createState() => _GearLoadingState();
}

class _GearLoadingState extends State<GearLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 3.14159,
            child: Icon(
              Icons.settings,
              size: widget.size,
              color: widget.color ?? LightColorsPalate.primaryColor,
            ),
          );
        },
      ),
    );
  }
} 