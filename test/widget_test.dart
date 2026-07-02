import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ews_semeru/app.dart';

void main() {
  testWidgets('App smoke test — widget tree builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EWSApp()));
    // Pump a few frames to let providers resolve, but don't settle
    // (the map widget continuously fetches tiles which won't resolve in test).
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify the app rendered something
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
