import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/onboarding/domain/models/onboarding_item.dart';

class OnboardingIllustrationWidget extends StatefulWidget {
  final OnboardingIllustration illustration;

  const OnboardingIllustrationWidget({
    super.key,
    required this.illustration,
  });

  @override
  State<OnboardingIllustrationWidget> createState() => _OnboardingIllustrationWidgetState();
}

class _OnboardingIllustrationWidgetState extends State<OnboardingIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : const Color(0x0C262624),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: _IllustrationPainter(
                illustration: widget.illustration,
                animationValue: _animController.value,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final OnboardingIllustration illustration;
  final double animationValue;
  final bool isDark;

  const _IllustrationPainter({
    required this.illustration,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background graph paper grids inside the circle
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0x088D5B4C)
      ..strokeWidth = 1.0;
    const double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    switch (illustration) {
      case OnboardingIllustration.attendance:
        _paintAttendance(canvas, center, radius);
        break;
      case OnboardingIllustration.homework:
        _paintHomework(canvas, center, radius);
        break;
      case OnboardingIllustration.timetable:
        _paintTimetable(canvas, center, radius);
        break;
      case OnboardingIllustration.fees:
        _paintFees(canvas, center, radius);
        break;
      case OnboardingIllustration.connect:
        _paintConnect(canvas, center, radius);
        break;
    }
  }

  void _paintAttendance(Canvas canvas, Offset center, double maxRadius) {
    // Attendance Calendar Sheet Custom Painting
    final rectPaint = Paint()
      ..color = isDark ? const Color(0xFF2C2C35) : Colors.white
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final sheetRect = Rect.fromCenter(center: center.translate(0, 10), width: 110, height: 130);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect, const Radius.circular(12)), rectPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect, const Radius.circular(12)), borderPaint);

    // Calendar Header
    final headerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final headerRect = Rect.fromLTWH(sheetRect.left, sheetRect.top, sheetRect.width, 32);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        headerRect,
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      headerPaint,
    );

    // Dynamic floating presence checkboxes
    final checkPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bounce = math.sin(animationValue * math.pi) * 8.0;
    
    // Checkbox 1
    final c1 = center.translate(-20, bounce);
    final p1 = Path()
      ..moveTo(c1.dx - 8, c1.dy)
      ..lineTo(c1.dx - 2, c1.dy + 6)
      ..lineTo(c1.dx + 8, c1.dy - 6);
    canvas.drawPath(p1, checkPaint);

    // Checkbox 2
    final c2 = center.translate(20, -bounce + 20);
    final p2 = Path()
      ..moveTo(c2.dx - 8, c2.dy)
      ..lineTo(c2.dx - 2, c2.dy + 6)
      ..lineTo(c2.dx + 8, c2.dy - 6);
    canvas.drawPath(p2, checkPaint);
  }

  void _paintHomework(Canvas canvas, Offset center, double maxRadius) {
    // Notebook pages custom painting
    final notebookPaint = Paint()
      ..color = isDark ? const Color(0xFF242C2A) : const Color(0xFFF3FBF9)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final sheetRect = Rect.fromCenter(center: center.translate(-10, 10), width: 100, height: 120);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect, const Radius.circular(10)), notebookPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect, const Radius.circular(10)), borderPaint);

    // Second stacked sheet
    final sheetRect2 = Rect.fromCenter(center: center.translate(10, 0), width: 100, height: 120);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect2, const Radius.circular(10)), notebookPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect2, const Radius.circular(10)), borderPaint);

    // Lined rules
    final linePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.3)
      ..strokeWidth = 2.0;

    for (var i = 0; i < 4; i++) {
      final y = sheetRect2.top + 30 + (i * 20);
      canvas.drawLine(Offset(sheetRect2.left + 15, y), Offset(sheetRect2.right - 15, y), linePaint);
    }

    // Floating achievement stars
    final starPaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.fill;

    final hoverOffset = math.sin(animationValue * math.pi) * 10;
    
    // Draw star 1
    final starCenter = center.translate(35, -35 + hoverOffset);
    _drawStar(canvas, starCenter, 14, starPaint);
  }

  void _paintTimetable(Canvas canvas, Offset center, double maxRadius) {
    // School Chalkboard / Timetable Grid
    final boardPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2827) : const Color(0xFF263C38) // Dark green chalkboard
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.info
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final boardRect = Rect.fromCenter(center: center.translate(0, 10), width: 130, height: 100);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(8)), boardPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(8)), borderPaint);

    // Timetable grid blocks sketched in chalk (dashed / thin white)
    final chalkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(boardRect.left, boardRect.top + 33), Offset(boardRect.right, boardRect.top + 33), chalkPaint);
    canvas.drawLine(Offset(boardRect.left, boardRect.top + 66), Offset(boardRect.right, boardRect.top + 66), chalkPaint);
    canvas.drawLine(Offset(boardRect.left + 43, boardRect.top), Offset(boardRect.left + 43, boardRect.bottom), chalkPaint);
    canvas.drawLine(Offset(boardRect.left + 86, boardRect.top), Offset(boardRect.left + 86, boardRect.bottom), chalkPaint);

    // Chalk timetable blocks (warm highlights)
    final blockPaint = Paint()
      ..color = AppColors.info.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final highlightRect = Rect.fromLTWH(boardRect.left + 46, boardRect.top + 36, 37, 27);
    canvas.drawRect(highlightRect, blockPaint);

    // Floating clock
    final clockPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final clockCenter = center.translate(-40, -40);
    canvas.drawCircle(clockCenter, 18, clockPaint);
    // Draw clock hands
    final rotation = animationValue * math.pi * 2;
    canvas.drawLine(clockCenter, clockCenter.translate(math.cos(rotation)*10, math.sin(rotation)*10), clockPaint..strokeWidth = 2);
  }

  void _paintFees(Canvas canvas, Offset center, double maxRadius) {
    // School Invoice / Fee card receipt
    final invoicePaint = Paint()
      ..color = isDark ? const Color(0xFF332C2A) : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final sheetRect = Rect.fromCenter(center: center.translate(0, 15), width: 90, height: 120);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect, const Radius.circular(8)), invoicePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(sheetRect, const Radius.circular(8)), borderPaint);

    // Receipt lines
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(sheetRect.left + 15, sheetRect.top + 35 + (i * 15)),
        Offset(sheetRect.right - 15, sheetRect.top + 35 + (i * 15)),
        linePaint,
      );
    }

    // Stamp circle (Paid badge!)
    final stampPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final stampCenter = center.translate(25, 45);
    canvas.drawCircle(stampCenter, 15, stampPaint);
    canvas.drawCircle(stampCenter, 12, stampPaint..strokeWidth = 1);

    // Floating money gold medals
    final coinPaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.fill;

    final float = math.sin(animationValue * math.pi) * 8;
    canvas.drawCircle(center.translate(-35, -30 + float), 14, coinPaint);
  }

  void _paintConnect(Canvas canvas, Offset center, double maxRadius) {
    // Network nodes representing Parent-Teacher connected hub
    final linkPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4)
      ..strokeWidth = 3.0;

    final c1 = center.translate(-40, 20);
    final c2 = center.translate(40, 20);
    final c3 = center.translate(0, -40);

    canvas.drawLine(c1, c2, linkPaint);
    canvas.drawLine(c2, c3, linkPaint);
    canvas.drawLine(c3, c1, linkPaint);

    final nodePaint1 = Paint()..color = AppColors.primary;
    final nodePaint2 = Paint()..color = AppColors.secondary;
    final nodePaint3 = Paint()..color = AppColors.info;

    final bounce = math.sin(animationValue * math.pi) * 5;

    // Node 1 (Parent)
    canvas.drawCircle(c1.translate(0, bounce), 18, nodePaint1);
    // Node 2 (Teacher)
    canvas.drawCircle(c2.translate(0, -bounce), 18, nodePaint2);
    // Node 3 (Student Hub)
    canvas.drawCircle(c3.translate(bounce, 0), 16, nodePaint3);
  }

  // Draw generic star path
  void _drawStar(Canvas canvas, Offset starCenter, double radius, Paint paint) {
    final path = Path();
    const double degreesPerStep = 360 / 10;
    
    for (var i = 0; i < 10; i++) {
      final double r = i.isEven ? radius : radius / 2;
      final double angle = i * degreesPerStep * math.pi / 180;
      final double x = starCenter.dx + r * math.cos(angle);
      final double y = starCenter.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
