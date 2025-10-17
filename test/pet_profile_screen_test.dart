import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_care_reminder/screens/pet_profile_screen.dart';
import 'package:pet_care_reminder/models/pet.dart';

void main() {
  testWidgets('PetProfileScreen renders basic info', (WidgetTester tester) async {
    final pet = Pet(id: 1, name: 'Buddy', age: 3, photo: null, notes: 'Friendly');

    await tester.pumpWidget(
      MaterialApp(
        home: PetProfileScreen(pet: pet),
      ),
    );

    expect(find.text('Buddy'), findsOneWidget);
    expect(find.text('Name: Buddy'), findsOneWidget);
    expect(find.text('Age: 3'), findsOneWidget);
    expect(find.text('Notes: Friendly'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
}
