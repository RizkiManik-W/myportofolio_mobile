import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

/// A page with one button that runs [ensureLoggedIn] and shows the result.
class GuardHost extends StatefulWidget {
  const GuardHost({super.key});

  @override
  State<GuardHost> createState() => _GuardHostState();
}

class _GuardHostState extends State<GuardHost> {
  String result = 'not asked';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('result: $result'),
          ElevatedButton(
            onPressed: () async {
              final ok = await ensureLoggedIn(context);
              setState(() => result = '$ok');
            },
            child: const Text('Protected'),
          ),
        ],
      ),
    );
  }
}

/// Server that accepts only owner / secret.
Future<http.Response> tokenServer(http.Request request) async {
  final body = jsonDecode(request.body) as Map<String, dynamic>;
  if (body['username'] == 'owner' && body['password'] == 'secret') {
    return http.Response(jsonEncode({'token': 'abc123'}), 200);
  }
  return http.Response('{}', 400);
}

Future<AuthState> pumpGuard(WidgetTester tester, {String? token}) async {
  final api = fakeApi(handler: tokenServer);
  final auth = AuthState(api, initialToken: token);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider<AuthState>.value(value: auth),
      ],
      child: const MaterialApp(home: GuardHost()),
    ),
  );
  await tester.tap(find.text('Protected'));
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  group('ensureLoggedIn', () {
    testWidgets('already logged in: no login screen, returns true', (
      tester,
    ) async {
      await pumpGuard(tester, token: 'abc123');

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('result: true'), findsOneWidget);
    });

    testWidgets('logged out: opens LoginScreen, success returns true', (
      tester,
    ) async {
      final auth = await pumpGuard(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.enterText(field('Username'), 'owner');
      await tester.enterText(field('Password'), 'secret');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('result: true'), findsOneWidget);
      expect(auth.token, 'abc123');
    });

    testWidgets('closing the login screen returns false', (tester) async {
      await pumpGuard(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('result: false'), findsOneWidget);
    });
  });

  group('LoginScreen', () {
    testWidgets('empty fields show errors and send nothing', (tester) async {
      await pumpGuard(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);
    });

    testWidgets('wrong password shows a SnackBar and stays on the screen', (
      tester,
    ) async {
      final auth = await pumpGuard(tester);
      await tester.enterText(field('Username'), 'owner');
      await tester.enterText(field('Password'), 'wrong');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Login failed (400)'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(auth.isLoggedIn, isFalse);
    });

    testWidgets('password is hidden', (tester) async {
      await pumpGuard(tester);
      final password = tester.widget<TextField>(
        find.descendant(
          of: field('Password'),
          matching: find.byType(TextField),
        ),
      );
      expect(password.obscureText, isTrue);
    });
  });
}
