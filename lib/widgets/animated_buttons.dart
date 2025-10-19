import 'package:flutter/material.dart';

/// An animated FAB that pulses and scales on press
class AnimatedFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final bool showPulse;
  
  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.showPulse = true,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.showPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    setState(() => _isPressed = true);
    
    // Quick scale down animation
    _controller.stop();
    _controller.animateTo(0.8, duration: const Duration(milliseconds: 100)).then((_) {
      _controller.animateTo(1.0, duration: const Duration(milliseconds: 100)).then((_) {
        setState(() => _isPressed = false);
        if (widget.showPulse) {
          _controller.repeat(reverse: true);
        }
      });
    });
    
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.9 : (_scaleAnimation.value),
          child: FloatingActionButton(
            onPressed: widget.onPressed != null ? _handlePress : null,
            tooltip: widget.tooltip,
            backgroundColor: widget.backgroundColor,
            elevation: _isPressed ? 2 : 6,
            child: Icon(widget.icon),
          ),
        );
      },
    );
  }
}

/// Extended FAB with animation
class AnimatedExtendedFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  
  const AnimatedExtendedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
  });

  @override
  State<AnimatedExtendedFAB> createState() => _AnimatedExtendedFABState();
}

class _AnimatedExtendedFABState extends State<AnimatedExtendedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: FloatingActionButton.extended(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon),
              label: Text(widget.label),
              backgroundColor: widget.backgroundColor,
            ),
          ),
        );
      },
    );
  }
}

/// Bouncing button widget with press animation
class BouncingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double bounceScale;
  
  const BouncingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.bounceScale = 0.95,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.bounceScale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
