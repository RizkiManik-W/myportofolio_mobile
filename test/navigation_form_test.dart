import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'test_helpers.dart';

import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

/// Text inside the drawer only (the home page also has a Logout card).
Finder inDrawer(String text) =>
    find.descendant(of: find.byType(Drawer), matching: find.text(text));

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

/// The app's root navigator, used to inspect the route stack.
NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator));

/// Fills in the login screen with the account the fake Django accepts.
Future<void> logInAsOwner(WidgetTester tester) async {
  await tester.enterText(field('Username'), 'owner');
  await tester.enterText(field('Password'), 'secret');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  late List<http.Request> requests;

  setUp(() => requests = []);

  Future<void> pumpApp(WidgetTester tester, {String? token}) async {
    await tester.pumpWidget(
      testApp(
        api: fakeApi(handler: fakeDjango(requests: requests)),
        token: token,
      ),
    );
  }

  group('Drawer', () {
    testWidgets('shows the header and the menu items', (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);

      expect(find.text('My Portfolio'), findsOneWidget);
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('View Projects'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Experience'), findsOneWidget);
    });

    testWidgets('logged out: shows Login, not Logout', (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);

      expect(inDrawer('Login'), findsOneWidget);
      expect(inDrawer('Logout'), findsNothing);
    });

    testWidgets('Login opens the login screen and logs in', (tester) async {
      await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      await logInAsOwner(tester);

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Logged in.'), findsOneWidget);
      expect(authOf(tester).token, 'abc123');
    });

    testWidgets('logged in: Logout revokes the token and shows Login again', (
      tester,
    ) async {
      await pumpApp(tester, token: 'abc123');
      await openDrawer(tester);
      expect(inDrawer('Login'), findsNothing);

      await tester.tap(inDrawer('Logout'));
      await tester.pumpAndSettle();

      expect(requests.single.url.path, '/api/v1/auth/logout/');
      expect(requests.single.headers['Authorization'], 'Token abc123');
      expect(authOf(tester).isLoggedIn, isFalse);
      expect(find.text('Logged out. See you again!'), findsOneWidget);

      await openDrawer(tester);
      expect(inDrawer('Login'), findsOneWidget);
    });

    testWidgets('Add Project asks for login first when logged out', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);

      await logInAsOwner(tester);

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
    });

    testWidgets('Add Project closed login: stays on the current page', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('logged in: Add Project replaces the page with the form', (
      tester,
    ) async {
      await pumpApp(tester, token: 'abc123');
      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
      // pushReplacement swaps the route, so there is nothing to go back to.
      expect(navigator(tester).canPop(), isFalse);
    });

    testWidgets('Home goes back to the home page from the form', (
      tester,
    ) async {
      await pumpApp(tester, token: 'abc123');
      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });
  });

  group('Tambah Proyek card', () {
    testWidgets('logged out: opens login, then the form', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      await logInAsOwner(tester);

      expect(find.byType(ProjectFormPage), findsOneWidget);
    });

    testWidgets('logged out and login closed: no form', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('logged in: pushes the form, and back returns home', (
      tester,
    ) async {
      await pumpApp(tester, token: 'abc123');
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      // push keeps the home page underneath the form.
      expect(navigator(tester).canPop(), isTrue);

      // Same as the system back button/gesture.
      navigator(tester).pop();
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });

    testWidgets('cards without a page stay on the home page', (tester) async {
      await pumpApp(tester);
      // Lihat Proyek now opens the project list (Tutorial 10), so use a
      // card that still only shows a SnackBar.
      await tester.tap(find.text('Lihat Skills'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });
  });

  group('Logout card', () {
    testWidgets('logged out: says so and sends nothing', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('You are not logged in.'), findsOneWidget);
      expect(requests.where((r) => r.method == 'POST'), isEmpty);
    });

    testWidgets('logged in: revokes the token on the server', (tester) async {
      await pumpApp(tester, token: 'abc123');
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(requests.single.url.path, '/api/v1/auth/logout/');
      expect(requests.single.headers['Authorization'], 'Token abc123');
      expect(authOf(tester).isLoggedIn, isFalse);
      expect(find.text('Logged out. See you again!'), findsOneWidget);
    });
  });
}
