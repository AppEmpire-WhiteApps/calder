import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';

import 'advertising/vpn_ads.dart';
import 'app.dart';

void _trackAppLaunch() {
  var launchTracked = false;
  Clarity.setOnSessionStartedCallback((_) {
    if (!launchTracked) {
      launchTracked = Clarity.sendCustomEvent('app_launch');
    }
  });
}

void main() {
  _trackAppLaunch();
  runApp(
    ClarityWidget(
      clarityConfig: ClarityConfig(projectId: 'ycmf5ycy7v'),
      app: const VpnAds(child: CalderApp()),
    ),
  );
}
