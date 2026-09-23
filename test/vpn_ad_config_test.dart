import 'package:calder/advertising/vpn_ad_config.dart';
import 'package:calder/advertising/vpn_ad_link.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object> _config({bool showAd = true}) => {
  'show_ad': showAd,
  'refresh_hours': 24,
  'vpn_button': {
    'enabled': true,
    'url': 'https://example.com/config',
    'locales': {
      'ru': {'title': 'Получить конфиг', 'subtitle': 'Бесплатная настройка'},
      'en': {'title': 'Get config', 'subtitle': 'Free setup'},
    },
  },
  'vpn_banner': {
    'enabled': true,
    'url': 'https://example.com/rating',
    'close_delay_seconds': 15,
    'locales': {
      'ru': {
        'title': 'Рейтинг VPN',
        'subtitle': 'Работает сейчас',
        'cta_button': 'Посмотреть',
      },
      'en': {
        'title': 'VPN rating',
        'subtitle': 'Working now',
        'cta_button': 'View',
      },
    },
  },
};

void main() {
  test('parses the supplied promotion shape and localizes copy', () {
    final config = VpnAdConfig.fromJson(_config());

    expect(config.refreshInterval, const Duration(hours: 24));
    expect(config.canShowButton, isTrue);
    expect(config.canShowBanner, isTrue);
    expect(config.button.copyFor(const Locale('ru')).title, 'Получить конфиг');
    expect(config.banner.copyFor(const Locale('ru')).cta, 'Посмотреть');
    expect(config.banner.closeDelaySeconds, 15);
  });

  test('hides both placements when the remote switch is off', () {
    final config = VpnAdConfig.fromJson(_config(showAd: false));

    expect(config.canShowButton, isFalse);
    expect(config.canShowBanner, isFalse);
  });

  test('accepts only safe HTTP(S) promotion links', () {
    expect(promotionUri('https://example.com/path'), isNotNull);
    expect(promotionUri('ftp://example.com/path'), isNull);
    expect(promotionUri('https://user:pass@example.com'), isNull);
    expect(promotionUri('https://example.com/with space'), isNull);
  });
}
