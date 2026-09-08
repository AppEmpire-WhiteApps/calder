import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainingDeskSupport {
  static const email = 'matthewdavidclark31@icloud.com';
  static Future<String> version() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }

  static Future<bool> support() => launchUrl(
    Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Calder support'},
    ),
    mode: LaunchMode.externalApplication,
  );
  static Future<void> rate() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  }
}
