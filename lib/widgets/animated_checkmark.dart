import 'package:flutter/material.dart';

class AnimatedCheckmark extends StatefulWidget {
  final bool isChecked;
  final Color? color;
  final double size;
  
  const AnimatedCheckmark({
    super.key,
    required this.isChecked,
    this.color,
    this.size = 48.0,
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.isChecked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: widget.isChecked
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: CustomPaint(
              painter: _CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Define checkmark points
    final p1 = Offset(size.width * 0.3, size.height * 0.5);
    final p2 = Offset(size.width * 0.45, size.height * 0.65);
    final p3 = Offset(size.width * 0.7, size.height * 0.35);

    // Calculate current drawing point based on progress
    if (progress <= 0.5) {
      // First segment (p1 to p2)
      final segmentProgress = progress * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * segmentProgress,
        p1.dy + (p2.dy - p1.dy) * segmentProgress,
      );
    } else {
      // Second segment (p2 to p3)
      final segmentProgress = (progress - 0.5) * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * segmentProgress,
        p2.dy + (p3.dy - p2.dy) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A simple button with animated checkmark feedback
class AnimatedCheckButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? label;
  final Color? color;
  
  const AnimatedCheckButton({
    super.key,
    this.onPressed,
    this.label,
    this.color,
  });

  @override
  State<AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<AnimatedCheckButton> {
  bool _isChecked = false;

  void _handlePress() {
    setState(() {
      _isChecked = true;
    });
    
    widget.onPressed?.call();
    
    // Reset after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isChecked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed != null ? _handlePress : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color ?? Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isChecked)
            AnimatedCheckmark(
              isChecked: _isChecked,
              color: Colors.white,
              size: 24,
            )
          else if (widget.label != null)
            Text(widget.label!),
        ],
      ),
    );
  }
}
