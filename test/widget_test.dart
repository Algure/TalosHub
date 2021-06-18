// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'package:talos_hub/main.dart';
import 'package:talos_hub/utitlities/keys.dart';

Future<void> main() async {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
  await deleteTalos();
}

deleteTalos() async {
  String url = 'https://[service name].search.windows.net/indexes/talohubdex/docs/index?api-version=2020-06-30-Preview';
  Response response = await post(
      Uri.parse('$searchEndPoint/indexes/talohubdex/docs/index?api-version=2020-06-30-Preview'),
      body:'{  '
      '"value": ['
      '{'
      '"@search.action": "delete","id":"blablabla"'
      '}'
      ']'
  '}',
      headers:
      {'Content-Type': 'application/json',
        'api-key': '77334EA99E5C257A037ECDA1BA5DFF3F',
        'Access-Control-Allow-Origin':'*'
      });
  print('search status response: ${response.body}');
  if (response != null && response.body != null) {
    // Do shit
  }
}
