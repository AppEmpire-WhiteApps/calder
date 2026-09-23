import 'package:flutter/material.dart';

import 'vpn_ad_colors.dart';
import 'vpn_ad_config.dart';
import 'vpn_ad_link.dart';
import 'vpn_ads.dart';

class VpnPromoButton extends StatelessWidget {
  const VpnPromoButton({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final scope = VpnAdScope.maybeOf(context);
    final config = scope?.notifier?.config;
    if (scope == null || config == null || !config.canShowButton) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: margin,
      child: _AnimatedPromo(
        promotion: config.button,
        copy: config.button.copyFor(scope.locale),
      ),
    );
  }
}

class _AnimatedPromo extends StatefulWidget {
  const _AnimatedPromo({required this.promotion, required this.copy});

  final VpnPromotion promotion;
  final VpnAdCopy copy;

  @override
  State<_AnimatedPromo> createState() => _AnimatedPromoState();
}

class _AnimatedPromoState extends State<_AnimatedPromo>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final AnimationController _gradientController;
  late final Animation<double> _pulse;
  late final Animation<double> _shimmer;
  late final Listenable _animation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _pulse = Tween<double>(
      begin: 1,
      end: 1.02,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_pulseController);
    _shimmer = Tween<double>(
      begin: -1,
      end: 2,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_shimmerController);
    _animation = Listenable.merge([
      _pulseController,
      _shimmerController,
      _gradientController,
    ]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimations();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _updateAnimations();

  void _updateAnimations() {
    final active =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    final animate =
        active &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
      if (!_shimmerController.isAnimating) _shimmerController.repeat();
      if (!_gradientController.isAnimating) _gradientController.repeat();
    } else {
      _pulseController.stop();
      _shimmerController.stop();
      _gradientController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _shimmerController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, _) {
      final palette = VpnAdColors(Theme.of(context));
      final colors = _interpolateGradient(
        palette.cardGradient,
        _gradientController.value,
      );
      return Transform.scale(
        scale: _pulse.value,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(color: palette.outline),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                onTap: () => openVpnPromotion(widget.promotion.uri),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ShimmerPainter(
                            progress: _shimmer.value,
                            color: palette.shimmer,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: palette.iconSurface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.shield_rounded,
                              color: palette.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.copy.title,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: palette.text,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.copy.subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: palette.iconSurface,
                            child: Icon(
                              Icons.chevron_right,
                              color: palette.primary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 20,
                      child: Text(
                        'Ad',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  List<Color> _interpolateGradient(List<Color> gradientColors, double phase) {
    final position = phase * (gradientColors.length - 1);
    final index = position.floor().clamp(0, gradientColors.length - 2);
    final amount = position - index;
    final following = (index + 2).clamp(0, gradientColors.length - 1);
    return [
      Color.lerp(gradientColors[index], gradientColors[index + 1], amount)!,
      Color.lerp(gradientColors[index + 1], gradientColors[following], amount)!,
    ];
  }
}

class _ShimmerPainter extends CustomPainter {
  const _ShimmerPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final transparent = color.withValues(alpha: 0);
    final paint = Paint()
      ..shader =
          LinearGradient(
            colors: [transparent, color, transparent],
            stops: [0, 0.5, 1],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * progress, size.height / 2),
              width: size.width * 0.6,
              height: size.height,
            ),
          );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
