import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_ogren/ui/components/app_bottom_nav_bar.dart';

void main() {
  group('AppBottomNavBar Glassmorphism & Responsive Tests', () {
    testWidgets('Renders all navigation items and handles tab changes', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: selectedTab,
              onTabSelected: (index) => selectedTab = index,
            ),
          ),
        ),
      );

      // Verify all 5 tab items are rendered
      expect(find.text('Anasayfa'), findsOneWidget);
      expect(find.text('Keşfet'), findsOneWidget);
      expect(find.text('Çalış'), findsOneWidget);
      expect(find.text('İlerleme'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Tap on 'Çalış' tab
      await tester.tap(find.text('Çalış'));
      await tester.pumpAndSettle();

      expect(selectedTab, 2);
    });

    testWidgets('Responsive size adapts to tablet/large screens (Netflix style)', (tester) async {
      // 1. Mobile Phone Dimensions: 390 x 844
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTabSelected: (_) {},
            ),
          ),
        ),
      );

      final mobileSizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ClipRRect),
          matching: find.byType(SizedBox),
        ).first,
      );
      final mobileWidth = mobileSizedBox.width!;
      // On mobile (390 width), bar width is ~358 (screenWidth - 32)
      expect(mobileWidth, closeTo(358, 2));

      // 2. Tablet Dimensions: 1024 x 768 (Landscape / iPad)
      tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
      await tester.pumpAndSettle();

      final tabletSizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ClipRRect),
          matching: find.byType(SizedBox),
        ).first,
      );
      final tabletWidth = tabletSizedBox.width!;
      // On large tablet (1024 width), bar width is clamped/proportional (Netflix style ~368-520 dp)
      expect(tabletWidth, lessThan(600));
      expect(tabletWidth, greaterThanOrEqualTo(360));
    });

    testWidgets('Phone landscape maintains compact width and does not stretch', (tester) async {
      // Mobile in landscape: 844 x 390
      tester.view.physicalSize = const Size(844 * 2.0, 390 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTabSelected: (_) {},
            ),
          ),
        ),
      );

      final landscapeSizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ClipRRect),
          matching: find.byType(SizedBox),
        ).first,
      );
      final landscapeWidth = landscapeSizedBox.width!;
      // Maintains portrait-like compact width (~358) and does not stretch to 470+
      expect(landscapeWidth, closeTo(358, 2));
      expect(landscapeWidth, lessThan(400));
    });

    testWidgets('Contains BackdropFilter for glassmorphic blur effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTabSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });
}
