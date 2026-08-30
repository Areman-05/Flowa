import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design_system/components/flowa_mark.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

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
  late final AnimationController _load;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final loadMs = widget.duration.inMilliseconds.clamp(300, 20000);
    _load = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: loadMs),
    )..forward();
  }

  @override
  void dispose() {
    _load.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: FlowaColors.ink,
        body: FlowaCanvas(
          mist: false,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FlowaSpacing.gutter,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const FlowaFlowGlyph(size: 72),
                  const SizedBox(height: FlowaSpacing.xl),
                  Text('Flowa', style: FlowaType.wordmark(size: 42)),
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    'Tu dinero, claro.',
                    style: FlowaType.body(color: FlowaColors.boneMuted),
                  ),
                  const Spacer(flex: 4),
                  AnimatedBuilder(
                    animation: _load,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: FlowaRadii.pillAll,
                        child: LinearProgressIndicator(
                          value: _load.value,
                          minHeight: 4,
                          backgroundColor: FlowaColors.inkHigh,
                          color: FlowaColors.mint,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: FlowaSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
