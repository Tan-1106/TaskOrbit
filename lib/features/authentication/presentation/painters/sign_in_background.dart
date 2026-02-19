import 'package:flutter/material.dart';

class SignInBackground extends CustomPainter {
  final BuildContext context;

  SignInBackground(this.context);

  void _drawCircleWithShadow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    Color shadowColor = Colors.black,
    double shadowBlur = 24,
    Offset shadowOffset = const Offset(4, 8),
  }) {
    // Shadow layer
    canvas.drawCircle(
      center + shadowOffset,
      radius,
      Paint()
        ..color = shadowColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur),
    );

    // Circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawCircleWithShadow(
      canvas,
      Offset(size.width * 0.5, size.height * 0.7),
      MediaQuery.of(context).size.width,
      Colors.white.withValues(alpha: 0.8)
    );
    _drawCircleWithShadow(
        canvas,
        Offset(size.width * 0.5, size.height * 0.75),
        MediaQuery.of(context).size.width,
        Colors.white
    );
    _drawCircleWithShadow(
        canvas,
        Offset(size.width * 0.5, size.height * 0.8),
        MediaQuery.of(context).size.width,
        Colors.white
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
