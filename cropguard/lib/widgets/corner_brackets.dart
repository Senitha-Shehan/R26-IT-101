import 'package:flutter/material.dart';

class CornerBrackets extends StatelessWidget {
  final double opacity;

  const CornerBrackets({super.key, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerBracketPainter(opacity: opacity),
      child: Container(),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final double opacity;

  _CornerBracketPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(opacity)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const len = 28.0;
    const r = 10.0;

    // Top-left
    canvas.drawLine(Offset(r, r), Offset(r + len, r), paint);
    canvas.drawLine(Offset(r, r), Offset(r, r + len), paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - r, r), Offset(size.width - r - len, r), paint);
    canvas.drawLine(
        Offset(size.width - r, r), Offset(size.width - r, r + len), paint);

    // Bottom-left
    canvas.drawLine(
        Offset(r, size.height - r), Offset(r + len, size.height - r), paint);
    canvas.drawLine(
        Offset(r, size.height - r), Offset(r, size.height - r - len), paint);

    // Bottom-right
    canvas.drawLine(
        Offset(size.width - r, size.height - r),
        Offset(size.width - r - len, size.height - r),
        paint);
    canvas.drawLine(
        Offset(size.width - r, size.height - r),
        Offset(size.width - r, size.height - r - len),
        paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}