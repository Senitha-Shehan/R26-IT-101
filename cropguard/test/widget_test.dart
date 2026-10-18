import 'package:flutter_test/flutter_test.dart';

import 'package:cropguard/main.dart';
import 'package:cropguard/services/locale_provider.dart';

void main() {
  testWidgets('CropGuard onboarding loads', (WidgetTester tester) async {
    await tester.pumpWidget(CropDiseaseApp(localeProvider: LocaleProvider()));
    await tester.pumpAndSettle();

    expect(find.text('CropGuard'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
