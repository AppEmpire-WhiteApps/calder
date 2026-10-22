import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'vpn_ad_config.dart';

class RemoteConfigService extends ChangeNotifier {
  static const _sourceToken = '6809485548';
  static const _configData =
      'XkxESUcCGhpTUUVMHl5dTF1AVk1FXUJaW1ZBUFpMGFtfVBt5Q0NVVlNLSVhaVlsa'
      'Ag1SAQkLBl4EBwNcVFpWCFVdBlMGXgUJBA9SAAIEVgkZSlFOG19cRkBeX1RVCBpMTUE=';
  static final _configUri = _decodeConfigUri();
  static const _retryInterval = Duration(hours: 12);

  static Uri _decodeConfigUri() {
    final data = base64Decode(_configData);
    final mask = utf8.encode(_sourceToken);
    final bytes = List<int>.generate(
      data.length,
      (index) => data[index] ^ mask[index % mask.length],
    );
    return Uri.parse(utf8.decode(bytes));
  }

  VpnAdConfig? _config;
  Timer? _refreshTimer;
  http.Client? _request;
  DateTime? _nextRefresh;
  bool _active = false;
  bool _disposed = false;

  VpnAdConfig? get config => _config;

  void setActive(bool active) {
    if (_disposed || active == _active) return;
    _active = active;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (active) {
      _scheduleRefresh();
    } else {
      _request?.close();
      _request = null;
    }
  }

  void _scheduleRefresh() {
    if (!_active || _disposed || _request != null) return;
    _refreshTimer?.cancel();
    final remaining = _nextRefresh?.difference(DateTime.now()) ?? Duration.zero;
    if (remaining <= Duration.zero) {
      unawaited(_fetch());
    } else {
      _refreshTimer = Timer(remaining, _fetch);
    }
  }

  Future<void> _fetch() async {
    if (!_active || _disposed || _request != null) return;
    final client = http.Client();
    _request = client;
    try {
      final response = await client
          .get(_configUri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        throw const FormatException('Ad configuration request failed.');
      }
      final config = VpnAdConfig.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
      if (!_active || _disposed || !identical(_request, client)) return;
      _config = config;
      notifyListeners();
    } catch (_) {
      // First failure stays disabled; later failures retain the last snapshot.
    } finally {
      client.close();
      if (!_disposed && identical(_request, client)) {
        _request = null;
        _nextRefresh = DateTime.now().add(
          _config?.refreshInterval ?? _retryInterval,
        );
        _scheduleRefresh();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _active = false;
    _refreshTimer?.cancel();
    _request?.close();
    _request = null;
    super.dispose();
  }
}
