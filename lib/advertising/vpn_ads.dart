import 'package:flutter/widgets.dart';

import 'remote_config_service.dart';

/// Owns remote ad configuration independently of the host app's feature state.
class VpnAds extends StatefulWidget {
  const VpnAds({super.key, required this.child});

  final Widget child;

  @override
  State<VpnAds> createState() => _VpnAdsState();
}

class _VpnAdsState extends State<VpnAds> with WidgetsBindingObserver {
  final _service = RemoteConfigService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateActivity();
  }

  void _updateActivity() {
    final state = WidgetsBinding.instance.lifecycleState;
    _service.setActive(state == null || state == AppLifecycleState.resumed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _updateActivity();

  @override
  void didChangeLocales(List<Locale>? locales) => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VpnAdScope(
    service: _service,
    // MaterialApp currently supports only English. Ads follow the real device
    // locale without changing the language of the rest of the application.
    locale: WidgetsBinding.instance.platformDispatcher.locale,
    child: widget.child,
  );
}

class VpnAdScope extends InheritedNotifier<RemoteConfigService> {
  const VpnAdScope({
    super.key,
    required RemoteConfigService service,
    required this.locale,
    required super.child,
  }) : super(notifier: service);

  final Locale locale;

  static VpnAdScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VpnAdScope>();

  @override
  bool updateShouldNotify(VpnAdScope oldWidget) =>
      locale != oldWidget.locale || super.updateShouldNotify(oldWidget);
}
