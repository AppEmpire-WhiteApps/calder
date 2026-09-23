import 'dart:async';

import 'package:flutter/widgets.dart';

import 'remote_config_service.dart';
import 'vpn_ads.dart';
import 'vpn_fullscreen_banner.dart';

/// Mount on the app's primary content screen, separate from feature state.
class VpnBannerScheduler extends StatefulWidget {
  const VpnBannerScheduler({super.key, required this.child});

  final Widget child;

  @override
  State<VpnBannerScheduler> createState() => _VpnBannerSchedulerState();
}

class _VpnBannerSchedulerState extends State<VpnBannerScheduler>
    with WidgetsBindingObserver {
  RemoteConfigService? _service;
  Timer? _initialTimer;
  Timer? _periodicTimer;
  bool _ready = false;
  bool _initialAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ready = true;
      _updateTimers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = VpnAdScope.maybeOf(context)?.notifier;
    _updateTimers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _updateTimers();

  void _updateTimers() {
    if (!_ready ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
        _service?.config?.canShowBanner != true) {
      _cancelTimers();
      return;
    }
    if (!_initialAttempted) {
      _initialTimer ??= Timer(const Duration(seconds: 2), () {
        _initialTimer = null;
        _initialAttempted = true;
        _tryShow();
        _startPeriodicTimer();
      });
    } else {
      _startPeriodicTimer();
    }
  }

  void _startPeriodicTimer() {
    _periodicTimer ??= Timer.periodic(const Duration(minutes: 1), (_) {
      _tryShow();
    });
  }

  void _tryShow() {
    if (!mounted || !_ready) return;
    final config = _service?.config;
    if (config == null || !config.canShowBanner) return;
    // show rechecks foreground/current route and owns the concurrent-show guard.
    unawaited(VpnFullscreenBanner.show(context, config.banner));
  }

  void _cancelTimers() {
    _initialTimer?.cancel();
    _periodicTimer?.cancel();
    _initialTimer = null;
    _periodicTimer = null;
  }

  @override
  void dispose() {
    _ready = false;
    _cancelTimers();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
