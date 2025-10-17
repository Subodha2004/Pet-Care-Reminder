// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_care_reminder/main.dart';

void main() {
  testWidgets('Pet Care Reminder app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PetCareReminderApp());

    // Verify that our app title is displayed.
    expect(find.text('Pet Care Reminder'), findsOneWidget);

    // Verify that the empty state is shown initially.
    expect(find.text('No reminders yet'), findsOneWidget);

    // Verify that the add button is present.
    expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
  });
}
