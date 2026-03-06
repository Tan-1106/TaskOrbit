import 'package:flutter/material.dart';

class SignInBackground extends StatelessWidget {
  const SignInBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MediaQueryData.fromView to get the real screen size unaffected by keyboard
    final mediaQuery = MediaQueryData.fromView(View.of(context));
    final screenSize = mediaQuery.size;
    final circleColor = Theme.of(context).colorScheme.onPrimary;

    return OverflowBox(
      alignment: Alignment.topLeft,
      minWidth: screenSize.width,
      maxWidth: screenSize.width,
      minHeight: screenSize.height,
      maxHeight: screenSize.height,
      child: CustomPaint(
        size: screenSize,
        painter: Background(
          screenWidth: screenSize.width,
          circleColor: circleColor,
        ),
      ),
    );
  }
}

class Background extends CustomPainter {
  final double screenWidth;
  final Color circleColor;

  Background({required this.screenWidth, required this.circleColor});

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
    _drawCircleWithShadow(canvas, Offset(size.width * 0.5, size.height * 0.7), screenWidth, circleColor);
    _drawCircleWithShadow(canvas, Offset(size.width * 0.5, size.height * 0.75), screenWidth, circleColor);
    _drawCircleWithShadow(canvas, Offset(size.width * 0.5, size.height * 0.8), screenWidth, circleColor);
  }

  @override
  bool shouldRepaint(covariant Background oldDelegate) =>
      oldDelegate.screenWidth != screenWidth || oldDelegate.circleColor != circleColor;
}
