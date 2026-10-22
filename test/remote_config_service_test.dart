import 'dart:convert';

import 'package:calder/advertising/remote_config_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _fixture = {
  'show_ad': true,
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
      'en': {
        'title': 'VPN rating',
        'subtitle': 'Working now',
        'cta_button': 'View',
      },
    },
  },
};

void main() {
  testWidgets(
    'fetches the original source when active and applies its config',
    (tester) async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        return http.Response.bytes(utf8.encode(jsonEncode(_fixture)), 200);
      });

      await http.runWithClient(() async {
        final service = RemoteConfigService();
        var updates = 0;
        service.addListener(() => updates++);

        try {
          await tester.pump();
          expect(requests, isEmpty);
          expect(service.config, isNull);

          service.setActive(true);
          await tester.pump();

          expect(requests, hasLength(1));
          expect(requests.single.method, 'GET');
          expect(
            requests.single.url,
            Uri.parse(
              'https://gist.githubusercontent.com/Avvanesyannn/'
              '65d9922f127dbbf1ae3f2f3146f871b1/raw/gistfile1.txt',
            ),
          );

          final config = service.config;
          expect(config, isNotNull);
          expect(config!.showAd, isTrue);
          expect(config.canShowButton, isTrue);
          expect(config.canShowBanner, isTrue);
          expect(config.refreshInterval, const Duration(hours: 24));
          expect(config.button.uri, Uri.parse('https://example.com/config'));
          expect(config.banner.uri, Uri.parse('https://example.com/rating'));
          expect(
            config.button.copyFor(const Locale('ru')).title,
            'Получить конфиг',
          );
          expect(config.banner.copyFor(const Locale('en')).cta, 'View');
          expect(config.banner.closeDelaySeconds, 15);
          expect(updates, 1);

          service.setActive(true);
          service.setActive(false);
          service.setActive(true);
          await tester.pump();

          expect(requests, hasLength(1));
          expect(service.config, same(config));
          expect(updates, 1);
        } finally {
          service.dispose();
        }
      }, () => client);
    },
  );
}
