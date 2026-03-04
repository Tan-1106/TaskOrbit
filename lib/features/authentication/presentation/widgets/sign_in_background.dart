import 'package:flutter/material.dart';

class SignInBackground extends StatelessWidget {
  const SignInBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: Background(context),
    );
  }
}

class Background extends CustomPainter {
  final BuildContext context;

  Background(this.context);

  void _drawCircleWithShadow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    Color shadowColor = Colors.black,
    double shadowBlur = 24,
    Offset shadowOffset = const Offset(4, 8),
  }) {
    canvas.drawCircle(
      center + shadowOffset,
      radius,
      Paint()
        ..color = shadowColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur),
    );

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
    _drawCircleWithShadow(canvas, Offset(size.width * 0.5, size.height * 0.7), MediaQuery.of(context).size.width, Theme.of(context).colorScheme.onPrimary);
    _drawCircleWithShadow(canvas, Offset(size.width * 0.5, size.height * 0.75), MediaQuery.of(context).size.width, Theme.of(context).colorScheme.onPrimary);
    _drawCircleWithShadow(canvas, Offset(size.width * 0.5, size.height * 0.8), MediaQuery.of(context).size.width, Theme.of(context).colorScheme.onPrimary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
