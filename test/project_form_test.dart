import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

import 'test_helpers.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> tapSave(WidgetTester tester) async {
  final save = find.widgetWithText(ElevatedButton, 'Save');
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

Future<void> fillValidForm(WidgetTester tester, {String imageUrl = ''}) async {
  await tester.enterText(field('Title'), 'MyPortfolio');
  await tester.enterText(field('Description'), 'Personal portfolio website');
  await tester.enterText(field('Tech Stack'), 'Flutter, Django');
  await tester.enterText(
    field('Project URL'),
    'https://github.com/owner/myportofolio',
  );
  if (imageUrl.isNotEmpty) {
    await tester.enterText(field('Project Image URL (optional)'), imageUrl);
  }
}

void main() {
  late List<http.Request> requests;

  setUp(() => requests = []);

  /// Requests that tried to create a project.
  Iterable<http.Request> creates() => requests.where(
    (r) => r.method == 'POST' && r.url.path == '/api/v1/projects/',
  );

  /// Opens the app straight on the form, with a fake Django behind it.
  Future<void> pumpForm(
    WidgetTester tester, {
    String? token = 'abc123',
    int createStatus = 201,
    Future<http.Response> Function(http.Request)? handler,
  }) async {
    await tester.pumpWidget(
      testApp(
        api: fakeApi(
          handler:
              handler ??
              fakeDjango(requests: requests, createStatus: createStatus),
        ),
        token: token,
      ),
    );
    final home = tester.element(find.byType(Scaffold).first);
    Navigator.push(
      home,
      MaterialPageRoute(builder: (context) => const ProjectFormPage()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the Django fields and the Save button', (tester) async {
    await pumpForm(tester);

    expect(field('Title'), findsOneWidget);
    expect(field('Description'), findsOneWidget);
    expect(field('Tech Stack'), findsOneWidget);
    expect(field('Project URL'), findsOneWidget);
    expect(field('Project Image URL (optional)'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
  });

  testWidgets('empty form shows errors and sends nothing', (tester) async {
    await pumpForm(tester);
    await tapSave(tester);

    expect(find.text('Title cannot be empty!'), findsOneWidget);
    expect(find.text('Description cannot be empty!'), findsOneWidget);
    expect(find.text('Tech stack cannot be empty!'), findsOneWidget);
    expect(find.text('Project URL cannot be empty!'), findsOneWidget);
    expect(creates(), isEmpty);
  });

  testWidgets('short description and bad URLs are rejected', (tester) async {
    await pumpForm(tester);
    await tester.enterText(field('Description'), 'Short');
    await tester.enterText(field('Project URL'), 'not a url');
    await tester.enterText(
      field('Project Image URL (optional)'),
      'ftp://example.com/a.png',
    );
    await tapSave(tester);

    expect(
      find.text('Description must be at least 10 characters!'),
      findsOneWidget,
    );
    expect(find.text('Must be a valid URL (https://...)'), findsNWidgets(2));
    expect(creates(), isEmpty);
  });

  testWidgets('logged in: POSTs with the token and shows a dialog', (
    tester,
  ) async {
    await pumpForm(tester);
    await fillValidForm(tester, imageUrl: 'https://example.com/shot.png');
    await tapSave(tester);

    final request = creates().single;
    expect(request.headers['Authorization'], 'Token abc123');
    expect(jsonDecode(request.body), {
      'title': 'MyPortfolio',
      'description': 'Personal portfolio website',
      'tech_stack': 'Flutter, Django',
      'project_url': 'https://github.com/owner/myportofolio',
      'project_image_url': 'https://example.com/shot.png',
    });

    expect(find.text('Project saved!'), findsOneWidget);
    expect(find.text('Title: MyPortfolio'), findsOneWidget);
    expect(
      find.text('Image URL: https://example.com/shot.png'),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    // The form is cleared for the next project.
    expect(find.text('MyPortfolio'), findsNothing);
  });

  testWidgets('image URL is optional', (tester) async {
    await pumpForm(tester);
    await fillValidForm(tester);
    await tapSave(tester);

    final body = jsonDecode(creates().single.body) as Map<String, dynamic>;
    expect(body['project_image_url'], '');
    expect(find.text('Project saved!'), findsOneWidget);
  });

  testWidgets('logged out while on the form: asks to log in, then sends', (
    tester,
  ) async {
    await pumpForm(tester, token: null);
    await fillValidForm(tester);
    await tapSave(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(creates(), isEmpty);

    await tester.enterText(field('Username'), 'owner');
    await tester.enterText(field('Password'), 'secret');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(creates().single.headers['Authorization'], 'Token abc123');
    expect(find.text('Project saved!'), findsOneWidget);
  });

  testWidgets('401: logs out and asks to log in again', (tester) async {
    await pumpForm(tester, createStatus: 401);
    await fillValidForm(tester);
    await tapSave(tester);

    expect(authOf(tester).isLoggedIn, isFalse);
    expect(
      find.text('Your session has expired. Please log in again.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('403: explains only the owner can add projects', (tester) async {
    await pumpForm(tester, createStatus: 403);
    await fillValidForm(tester);
    await tapSave(tester);

    expect(
      find.text('Only the portfolio owner can add projects (403).'),
      findsOneWidget,
    );
    // A 403 means the token works, just not for this user.
    expect(authOf(tester).isLoggedIn, isTrue);
  });

  testWidgets('server down: shows a connection error', (tester) async {
    await pumpForm(
      tester,
      handler: (request) async {
        if (request.method == 'POST') {
          throw http.ClientException('Connection refused');
        }
        return http.Response('[]', 200);
      },
    );
    await fillValidForm(tester);
    await tapSave(tester);

    expect(
      find.text('Cannot reach the server. Is Django running?'),
      findsOneWidget,
    );
  });
}
