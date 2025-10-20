import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProductivityScoreWidget extends StatefulWidget {
  final double score; // 0-100
  final Map<String, double> breakdown;

  const ProductivityScoreWidget({
    super.key,
    required this.score,
    required this.breakdown,
  });

  @override
  State<ProductivityScoreWidget> createState() => _ProductivityScoreWidgetState();
}

class _ProductivityScoreWidgetState extends State<ProductivityScoreWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(widget.score).withAlpha((0.1 * 255).round()),
            _getScoreColor(widget.score).withAlpha((0.05 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getScoreColor(widget.score).withAlpha((0.3 * 255).round()),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Productivity Score',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Animated score ring
          SizedBox(
            width: 180,
            height: 180,
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScoreRingPainter(
                    score: _scoreAnimation.value,
                    color: _getScoreColor(widget.score),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_scoreAnimation.value.toInt()}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(widget.score),
                            height: 1,
                          ),
                        ),
                        Text(
                          'out of 100',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Breakdown
          ...widget.breakdown.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toInt()}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getScoreColor(entry.value * 100),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: theme.colorScheme.onSurface.withAlpha((0.1 * 255).round()),
                      valueColor: AlwaysStoppedAnimation(
                        _getScoreColor(entry.value * 100),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;

  _ScoreRingPainter({
    required this.score,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    // Background ring
    final bgPaint = Paint()
      ..color = color.withAlpha((0.15 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring with gradient (only draw if score > 0 to avoid SweepGradient assertion)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final double sweepAngle = 2 * math.pi * (score / 100);

    if (sweepAngle > 0) {
      final gradient = SweepGradient(
        colors: [
          color,
          color.withAlpha((0.6 * 255).round()),
        ],
        stops: const [0.0, 1.0],
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..color = color.withAlpha((0.3 * 255).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
