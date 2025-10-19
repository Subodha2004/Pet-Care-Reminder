import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Pet Happiness Meter widget showing care completion status
class PetHappinessMeter extends StatelessWidget {
  final double happiness; // 0-100
  final String petName;
  final bool showLabel;
  final double size;

  const PetHappinessMeter({
    super.key,
    required this.happiness,
    required this.petName,
    this.showLabel = true,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            '$petName\'s Happiness',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Circular happiness meter
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(size, size),
                painter: _HappinessMeterPainter(
                  happiness: happiness,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  progressColor: _getHappinessColor(happiness),
                ),
              ),
              
              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji
                  Text(
                    _getHappinessEmoji(happiness),
                    style: TextStyle(fontSize: size * 0.3),
                  ),
                  const SizedBox(height: 8),
                  // Percentage
                  Text(
                    '${happiness.round()}%',
                    style: TextStyle(
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.bold,
                      color: _getHappinessColor(happiness),
                    ),
                  ),
                  // Status text
                  Text(
                    _getHappinessStatus(happiness),
                    style: TextStyle(
                      fontSize: size * 0.08,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getHappinessColor(double value) {
    if (value >= 90) return Colors.green;
    if (value >= 75) return Colors.lightGreen;
    if (value >= 50) return Colors.orange;
    if (value >= 25) return Colors.deepOrange;
    return Colors.red;
  }

  String _getHappinessEmoji(double value) {
    if (value >= 90) return '😍';
    if (value >= 75) return '😊';
    if (value >= 50) return '🙂';
    if (value >= 25) return '😕';
    return '😢';
  }

  String _getHappinessStatus(double value) {
    if (value >= 90) return 'Thriving!';
    if (value >= 75) return 'Happy';
    if (value >= 50) return 'Content';
    if (value >= 25) return 'Needs Care';
    return 'Urgent!';
  }
}

/// Custom painter for happiness meter
class _HappinessMeterPainter extends CustomPainter {
  final double happiness;
  final Color backgroundColor;
  final Color progressColor;

  _HappinessMeterPainter({
    required this.happiness,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 15.0;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (happiness / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_HappinessMeterPainter oldDelegate) {
    return oldDelegate.happiness != happiness;
  }
}

/// Compact happiness indicator for lists
class CompactHappinessIndicator extends StatelessWidget {
  final double happiness;
  final double size;

  const CompactHappinessIndicator({
    super.key,
    required this.happiness,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getHappinessColor(happiness).withValues(alpha: 0.1),
        border: Border.all(
          color: _getHappinessColor(happiness),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _getHappinessEmoji(happiness),
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }

  Color _getHappinessColor(double value) {
    if (value >= 90) return Colors.green;
    if (value >= 75) return Colors.lightGreen;
    if (value >= 50) return Colors.orange;
    if (value >= 25) return Colors.deepOrange;
    return Colors.red;
  }

  String _getHappinessEmoji(double value) {
    if (value >= 90) return '😍';
    if (value >= 75) return '😊';
    if (value >= 50) return '🙂';
    if (value >= 25) return '😕';
    return '😢';
  }
}
