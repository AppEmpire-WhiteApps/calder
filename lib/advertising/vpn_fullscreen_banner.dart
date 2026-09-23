import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'vpn_ad_colors.dart';
import 'vpn_ad_config.dart';
import 'vpn_ad_link.dart';
import 'vpn_ads.dart';

class VpnFullscreenBanner extends StatefulWidget {
  const VpnFullscreenBanner({super.key, required this.promotion});

  // A snapshot keeps text, destination and countdown consistent during a show.
  final VpnPromotion promotion;
  static bool _isShowing = false;

  static Future<void> show(BuildContext context, VpnPromotion promotion) async {
    if (_isShowing || !context.mounted || !promotion.enabled) return;
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
        route?.isCurrent != true ||
        route?.animation?.isCompleted == false ||
        route?.secondaryAnimation?.isDismissed == false ||
        navigator.userGestureInProgress) {
      return;
    }
    _isShowing = true;
    try {
      await navigator.push<void>(
        CupertinoPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => VpnFullscreenBanner(promotion: promotion),
        ),
      );
    } finally {
      _isShowing = false;
    }
  }

  @override
  State<VpnFullscreenBanner> createState() => _VpnFullscreenBannerState();
}

class _VpnFullscreenBannerState extends State<VpnFullscreenBanner>
    with WidgetsBindingObserver {
  Timer? _countdownTimer;
  late int _remainingSeconds;

  bool get _canClose => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.promotion.closeDelaySeconds;
    WidgetsBinding.instance.addObserver(this);
    _updateCountdown();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _updateCountdown();

  void _updateCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (_canClose ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      // Keep ticking while covered so counting resumes when this route returns.
      setState(() => _remainingSeconds--);
      if (_canClose) {
        timer.cancel();
        _countdownTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _close() {
    if (_canClose && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = VpnAdScope.maybeOf(context)?.locale ?? const Locale('en');
    final copy = widget.promotion.copyFor(locale);
    final theme = Theme.of(context);
    final colors = VpnAdColors(theme);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: _canClose,
        child: Scaffold(
          backgroundColor: colors.background,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.fullscreenGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Ad',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          label: locale.languageCode == 'ru'
                              ? 'Закрыть рекламу'
                              : 'Close ad',
                          child: TextButton(
                            onPressed: _canClose ? _close : null,
                            style: TextButton.styleFrom(
                              foregroundColor: colors.text,
                              disabledForegroundColor: colors.textSecondary,
                              backgroundColor: colors.surface,
                              minimumSize: const Size(48, 48),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(8),
                            ),
                            child: _canClose
                                ? const Icon(Icons.close, size: 18)
                                : Text('$_remainingSeconds'),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    children: [
                                      const Spacer(),
                                      const SizedBox(height: 24),
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: colors.iconSurface,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.shield_rounded,
                                          color: colors.primary,
                                          size: 40,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Text(
                                        copy.title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: colors.text,
                                          height: 1.2,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        copy.subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          onPressed: () => openVpnPromotion(
                                            widget.promotion.uri,
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: colors.primary,
                                            foregroundColor: colors.onPrimary,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 18,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            copy.cta,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
