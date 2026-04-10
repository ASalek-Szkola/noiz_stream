import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveWidget extends StatelessWidget {
  final Color color;
  final int pattern;
  final double volume;

  const WaveWidget({
    super.key,
    required this.color,
    this.pattern = 0,
    this.volume = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WavePainter(color: color, pattern: pattern, volume: volume),
      size: Size.infinite,
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  final int pattern;
  final double volume;

  WavePainter({required this.color, this.pattern = 0, this.volume = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;
    final amplitude = size.height / 2 * 0.85 * volume;

    // Generates completely smooth, randomized peak heights for the envelope
    List<double> generateWave(int seed, int count, double envelopePower) {
      final rand = math.Random(seed);
      List<double> mags = [];
      for (int i = 0; i < count; i++) {
        double t = count <= 1 ? 0.5 : i / (count - 1);

        // Use a Sine wave to create a smooth tapering envelope at the edges
        double env = math.sin(t * math.pi);
        env = math.pow(env, envelopePower).toDouble();

        // Randomize the peak amplitudes
        double mag = 0.2 + 0.8 * rand.nextDouble();
        mags.add(env * mag);
      }
      // Guarantee perfectly flat start and end lines
      if (mags.isNotEmpty) {
        mags.first = 0.0;
        mags.last = 0.0;
      }
      return mags;
    }

    int count;
    int seed;
    double envPower;

    // Adjust frequencies (point counts) and stroke width for each noise type
    switch (pattern) {
      case 0: // Brown Noise (Deepest / Lowest frequency)
        count = 13;
        seed = 42;
        envPower = 1.0;
        paint.strokeWidth = 3.5;
        break;
      case 2: // Green Noise (Medium-low frequency)
        count = 21;
        seed = 101;
        envPower = 1.2;
        paint.strokeWidth = 3.0;
        break;
      case 1: // Pink Noise (Medium frequency)
        count = 35;
        seed = 202;
        envPower = 1.5;
        paint.strokeWidth = 2.5;
        break;
      case 3: // White Noise (Highest frequency)
      default:
        count = 55;
        seed = 303;
        envPower = 2.0;
        paint.strokeWidth = 1.8;
        break;
    }

    List<double> mags = generateWave(seed, count, envPower);
    List<Offset> points = [];

    for (int i = 0; i < mags.length; i++) {
      double x = (i / (mags.length - 1)) * size.width;
      // Alternate going up and down
      double dir = (i % 2 == 0) ? 1 : -1;
      double y = midY + (mags[i] * amplitude * dir);
      points.add(Offset(x, y));
    }

    // Draw using perfectly smooth cubic beziers instead of harsh lineTo zig-zags
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      // Setting control points perfectly halfway horizontally ensures a slope of 0 (flat horizontal tangent) at every peak!
      final cpX = (p0.dx + p1.dx) / 2;
      path.cubicTo(
        cpX,
        p0.dy, // Control Point 1
        cpX,
        p1.dy, // Control Point 2
        p1.dx,
        p1.dy, // End Point
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pattern != pattern ||
        oldDelegate.volume != volume;
  }
}
