import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kelime_ogren/main.dart';
import 'package:kelime_ogren/providers/app_provider.dart';

void main() {
  testWidgets('App loads splash and launches dashboard successfully', (WidgetTester tester) async {
    final provider = AppProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const KelimeOgrenApp(),
      ),
    );

    // Initial splash frame
    expect(find.text('Kelime Öğren'), findsOneWidget);

    // Settle the splash timer and transition to Dashboard
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify Dashboard is loaded
    expect(find.text('Kelime Kartları'), findsOneWidget);
    expect(find.text('🎯 Günlük Hedef'), findsOneWidget);
    expect(find.text('📌 Kategoriler'), findsOneWidget);
  });
}
