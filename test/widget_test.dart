import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/button.dart';

void main() {
  testWidgets('custom UI widgets render and respond to taps', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: const CustomAppBar(
            title: 'Inventory',
            subtitle: 'Live stock position across all block sizes.',
          ),
          body: CustomButton(
            name: 'Refresh dashboard',
            icon: const Icon(Icons.sync_rounded),
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Inventory'), findsOneWidget);
    expect(
      find.text('Live stock position across all block sizes.'),
      findsOneWidget,
    );
    expect(find.text('Refresh dashboard'), findsOneWidget);

    await tester.tap(find.text('Refresh dashboard'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
