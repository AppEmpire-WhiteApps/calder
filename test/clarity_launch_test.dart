import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calder/main.dart' as entrypoint;

void main() {
  testWidgets('launch initializes the assigned Clarity project', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    entrypoint.main();
    await tester.pump();

    final clarity = tester.widget<ClarityWidget>(find.byType(ClarityWidget));
    expect(clarity.clarityConfig.projectId, 'ycmf5ycy7v');
    expect(tester.takeException(), isNull);
  });
}
