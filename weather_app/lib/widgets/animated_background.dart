import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

/// Animated gradient background with weather-specific particle effects.
class AnimatedBackground extends StatefulWidget {
  final WeatherModel weather;
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.weather,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleCtrl;
  late AnimationController _gradientCtrl;

  @override
  void initState() {
    super.initState();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _gradientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppConstants.gradientForCondition(
      widget.weather.condition,
      widget.weather.isDay,
    );

    return AnimatedBuilder(
      animation: _gradientCtrl,
      builder: (ctx, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: [0.0, 0.45 + _gradientCtrl.value * 0.15, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleCtrl,
                  builder: (ctx, _) => CustomPaint(
                    painter: _ParticlePainter(
                      condition: widget.weather.condition,
                      progress: _particleCtrl.value,
                      isDay: widget.weather.isDay,
                    ),
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

// ── Particle Painter ───────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final String condition;
  final double progress;
  final bool isDay;

  _ParticlePainter({
    required this.condition,
    required this.progress,
    required this.isDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        _drawRain(canvas, size, heavy: condition == 'rain');
        break;
      case 'thunderstorm':
        _drawThunder(canvas, size);
        break;
      case 'snow':
        _drawSnow(canvas, size);
        break;
      case 'clear':
        isDay ? _drawSunRays(canvas, size) : _drawStars(canvas, size);
        break;
      case 'clouds':
        _drawClouds(canvas, size);
        break;
      case 'mist':
      case 'fog':
      case 'haze':
        _drawFog(canvas, size);
        break;
      default:
        break;
    }
  }

  // ── Rain ──────────────────────────────────────────────────────────────────
  void _drawRain(Canvas canvas, Size size, {bool heavy = false}) {
    final paint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.35)
      ..strokeWidth = heavy ? 1.8 : 1.2
      ..strokeCap = StrokeCap.round;

    final rng = math.Random(42);
    final count = heavy ? 70 : 45;
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final speed = 0.8 + rng.nextDouble() * 0.8;
      final yFraction = (rng.nextDouble() + progress * speed) % 1.2;
      final y = yFraction * size.height;
      canvas.drawLine(
        Offset(x - 4, y - 14),
        Offset(x, y),
        paint,
      );
    }
  }

  // ── Thunderstorm ──────────────────────────────────────────────────────────
  void _drawThunder(Canvas canvas, Size size) {
    _drawRain(canvas, size, heavy: true);
    // Lightning flash
    final phase = (progress * 5).floor() % 10;
    if (phase == 0) {
      final flashPaint = Paint()
        ..color = Colors.yellow.withOpacity(
            math.max(0, 1 - (progress * 5 % 1) * 10) * 0.2);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  // ── Snow ─────────────────────────────────────────────────────────────────
  void _drawSnow(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(17);

    for (int i = 0; i < 50; i++) {
      final x = rng.nextDouble() * size.width +
          math.sin(progress * math.pi * 2 + i) * 12;
      final speed = 0.3 + rng.nextDouble() * 0.4;
      final y = ((rng.nextDouble() + progress * speed) % 1.1) * size.height;
      final r = rng.nextDouble() * 3 + 1;
      final opacity = 0.3 + rng.nextDouble() * 0.4;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  // ── Sun Rays ─────────────────────────────────────────────────────────────
  void _drawSunRays(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final cx = size.width * 0.78;
    final cy = size.height * 0.14;

    for (int i = 0; i < 10; i++) {
      final angle = (i / 10) * math.pi * 2 + progress * math.pi * 0.4;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(
          cx + math.cos(angle - 0.08) * size.width * 1.4,
          cy + math.sin(angle - 0.08) * size.width * 1.4,
        )
        ..lineTo(
          cx + math.cos(angle + 0.08) * size.width * 1.4,
          cy + math.sin(angle + 0.08) * size.width * 1.4,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  // ── Stars ─────────────────────────────────────────────────────────────────
  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(7);

    for (int i = 0; i < 55; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.65;
      final r = rng.nextDouble() * 1.6 + 0.4;
      final twinkle = math.sin(progress * math.pi * 2 + i * 0.7) * 0.5 + 0.5;
      paint.color = Colors.white.withOpacity(0.15 + twinkle * 0.55);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  // ── Clouds ────────────────────────────────────────────────────────────────
  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    for (int l = 0; l < 3; l++) {
      final xOffset = (progress * (l + 1) * 0.25 % 1.5 - 0.25) * size.width;
      _cloud(canvas, paint,
          Offset(xOffset, size.height * (0.08 + l * 0.12)),
          70.0 + l * 25);
    }
  }

  void _cloud(Canvas canvas, Paint p, Offset pos, double s) {
    canvas.drawCircle(pos, s * 0.55, p);
    canvas.drawCircle(Offset(pos.dx + s * 0.55, pos.dy - s * 0.1), s * 0.42, p);
    canvas.drawCircle(Offset(pos.dx + s * 1.05, pos.dy), s * 0.48, p);
    canvas.drawRect(
      Rect.fromLTRB(
          pos.dx - s * 0.08, pos.dy, pos.dx + s * 1.15, pos.dy + s * 0.42),
      p,
    );
  }

  // ── Fog ──────────────────────────────────────────────────────────────────
  void _drawFog(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.18);
      final drift = math.sin(progress * math.pi * 2 + i) * 20;
      canvas.drawRect(
          Rect.fromLTWH(drift - 20, y, size.width + 40, 24), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.condition != condition;
}
