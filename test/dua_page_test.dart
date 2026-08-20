import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/dua_page.dart';

void main() {
  testWidgets('tapping a repeated dua increments the counter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DuaPage(
          themeColor: Colors.amber,
          langCode: 'en',
        ),
      ),
    );

    await tester.tap(find.text('Morning Duas'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ'),
      100,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ'));
    await tester.pump();

    expect(find.text('1/100'), findsOneWidget);
  });
}
