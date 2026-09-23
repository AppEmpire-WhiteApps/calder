import 'package:flutter/widgets.dart';

import 'vpn_ad_link.dart';

@immutable
class VpnAdConfig {
  const VpnAdConfig({
    required this.showAd,
    required this.refreshInterval,
    required this.button,
    required this.banner,
  });

  factory VpnAdConfig.fromJson(Object? value) {
    final json = _object(value);
    final hours = _integer(json['refresh_hours'], minimum: 1);
    final refreshInterval = Duration(hours: hours);
    if (refreshInterval.inHours != hours) {
      throw const FormatException('Ad refresh interval is out of range.');
    }
    return VpnAdConfig(
      showAd: _boolean(json['show_ad']),
      refreshInterval: refreshInterval,
      button: VpnPromotion.fromJson(json['vpn_button']),
      banner: VpnPromotion.fromJson(json['vpn_banner'], fullscreen: true),
    );
  }

  final bool showAd;
  final Duration refreshInterval;
  final VpnPromotion button;
  final VpnPromotion banner;

  bool get canShowButton => showAd && button.enabled && button.uri != null;
  bool get canShowBanner => showAd && banner.enabled && banner.uri != null;
}

@immutable
class VpnPromotion {
  const VpnPromotion({
    required this.enabled,
    required this.uri,
    required this.closeDelaySeconds,
    required this.locales,
  });

  factory VpnPromotion.fromJson(Object? value, {bool fullscreen = false}) {
    final json = _object(value);
    final enabled = _boolean(json['enabled']);
    final url = json['url'];
    if (url is! String) throw const FormatException('Expected an ad URL.');
    final uri = promotionUri(url);
    if (enabled && uri == null) {
      throw const FormatException('Expected an HTTP(S) ad URL.');
    }
    final locales = _object(
      json['locales'],
    ).map((language, copy) => MapEntry(language, VpnAdCopy.fromJson(copy)));
    final english = locales['en'];
    if (enabled &&
        (english == null ||
            english.title.isEmpty ||
            english.subtitle.isEmpty ||
            (fullscreen && english.cta.isEmpty))) {
      throw const FormatException('Expected English ad copy for fallback.');
    }
    return VpnPromotion(
      enabled: enabled,
      uri: uri,
      closeDelaySeconds: fullscreen
          ? _integer(json['close_delay_seconds'], minimum: 0)
          : 0,
      locales: Map.unmodifiable(locales),
    );
  }

  final bool enabled;
  final Uri? uri;
  final int closeDelaySeconds;
  final Map<String, VpnAdCopy> locales;

  VpnAdCopy copyFor(Locale locale) {
    final english = locales['en'] ?? const VpnAdCopy();
    final localized = locale.languageCode.toLowerCase() == 'ru'
        ? locales['ru'] ?? english
        : english;
    return VpnAdCopy(
      title: localized.title.isEmpty ? english.title : localized.title,
      subtitle: localized.subtitle.isEmpty
          ? english.subtitle
          : localized.subtitle,
      cta: localized.cta.isEmpty ? english.cta : localized.cta,
    );
  }
}

@immutable
class VpnAdCopy {
  const VpnAdCopy({this.title = '', this.subtitle = '', this.cta = ''});

  factory VpnAdCopy.fromJson(Object? value) {
    final json = _object(value);
    return VpnAdCopy(
      title: _text(json['title']),
      subtitle: _text(json['subtitle']),
      cta: _text(json['cta_button']),
    );
  }

  final String title;
  final String subtitle;
  final String cta;
}

Map<String, dynamic> _object(Object? value) {
  if (value is Map<String, dynamic>) return value;
  throw const FormatException('Expected an ad configuration object.');
}

bool _boolean(Object? value) {
  if (value is bool) return value;
  throw const FormatException('Expected an ad configuration boolean.');
}

int _integer(Object? value, {required int minimum}) {
  if (value is int && value >= minimum) return value;
  throw const FormatException('Expected a valid ad configuration integer.');
}

String _text(Object? value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  throw const FormatException('Expected ad copy text.');
}
