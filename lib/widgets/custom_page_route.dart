import 'package:flutter/material.dart';

/// Custom page route with smooth slide and fade transitions
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteTransitionType transitionType;
  
  CustomPageRoute({
    required this.page,
    this.transitionType = RouteTransitionType.slideFromRight,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              animation,
              secondaryAnimation,
              child,
              transitionType,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
        );

  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    RouteTransitionType type,
  ) {
    switch (type) {
      case RouteTransitionType.slideFromRight:
        return _slideFromRight(animation, secondaryAnimation, child);
      case RouteTransitionType.slideFromBottom:
        return _slideFromBottom(animation, secondaryAnimation, child);
      case RouteTransitionType.fadeIn:
        return _fadeIn(animation, child);
      case RouteTransitionType.scaleAndFade:
        return _scaleAndFade(animation, child);
      case RouteTransitionType.slideAndFade:
        return _slideAndFade(animation, secondaryAnimation, child);
    }
  }

  static Widget _slideFromRight(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;
    
    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    var offsetAnimation = animation.drive(tween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget _slideFromBottom(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;
    
    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    var offsetAnimation = animation.drive(tween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  static Widget _fadeIn(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      ),
      child: child,
    );
  }

  static Widget _scaleAndFade(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget _slideAndFade(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;
    
    var slideTween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    var slideAnimation = animation.drive(slideTween);
    
    // Slide out previous page
    var previousSlide = Tween(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve,
    ));
    
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: animation,
        child: Stack(
          children: [
            SlideTransition(
              position: previousSlide,
              child: Container(),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Types of page transitions available
enum RouteTransitionType {
  slideFromRight,
  slideFromBottom,
  fadeIn,
  scaleAndFade,
  slideAndFade,
}

/// Extension on BuildContext for easy navigation with custom transitions
extension NavigationExtensions on BuildContext {
  /// Navigate to a new page with slide from right transition
  Future<T?> pushWithSlide<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: RouteTransitionType.slideFromRight,
      ),
    );
  }

  /// Navigate to a new page with slide from bottom transition (like modal)
  Future<T?> pushWithModalSlide<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: RouteTransitionType.slideFromBottom,
      ),
    );
  }

  /// Navigate to a new page with fade transition
  Future<T?> pushWithFade<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: RouteTransitionType.fadeIn,
      ),
    );
  }

  /// Navigate to a new page with scale and fade transition
  Future<T?> pushWithScale<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: RouteTransitionType.scaleAndFade,
      ),
    );
  }
}
