import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design_system/components/flowa_mark.dart';
import '../../../design_system/tokens/flowa_spacing.dart';

/// Splash — black canvas, large open mark, quiet tagline (Radient layout).
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.duration = const Duration(seconds: 3),
  });

  final Duration duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _draw;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _tagOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _draw = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
    );
    _markOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.35, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _tagOpacity = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.55, 1, curve: Curves.easeOutCubic),
    );

    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _markOpacity,
                  child: ScaleTransition(
                    scale: _markScale,
                    child: AnimatedBuilder(
                      animation: _draw,
                      builder: (context, child) {
                        return FlowaFlowGlyph(
                          size: 168,
                          progress: _draw.value,
                          animated: _draw.value >= 0.98,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                left: FlowaSpacing.xl,
                right: FlowaSpacing.xl,
                bottom: FlowaSpacing.xxl,
                child: FadeTransition(
                  opacity: _tagOpacity,
                  child: Text(
                    'Tu dinero, claro y bajo control.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8A8A8A),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.15,
                          fontSize: 14,
                          height: 1.3,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
