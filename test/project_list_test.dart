import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

import 'test_helpers.dart';

Future<void> openProjectList(WidgetTester tester) async {
  await tester.tap(find.text('Lihat Proyek'));
  await tester.pumpAndSettle();
}

void main() {
  group('ProjectListScreen', () {
    testWidgets('Lihat Proyek card opens the list with projects from the API', (
      tester,
    ) async {
      await tester.pumpWidget(testApp());
      await openProjectList(tester);

      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(find.text('MyPortfolio Web'), findsOneWidget);
      expect(find.text('MyPortfolio Mobile'), findsOneWidget);
      expect(find.text('Django, Tailwind'), findsOneWidget);
    });

    testWidgets('shows a spinner while loading', (tester) async {
      // The fake server only answers after `reply` is completed.
      final reply = Completer<http.Response>();
      await tester.pumpWidget(
        testApp(api: fakeApi(handler: (_) => reply.future)),
      );
      await tester.tap(find.text('Lihat Proyek'));
      // The spinner never stops animating, so pumpAndSettle would time out;
      // pump past the page transition instead.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      reply.complete(http.Response('[]', 200));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('tapping a project opens its detail screen', (tester) async {
      await tester.pumpWidget(testApp());
      await openProjectList(tester);
      await tester.tap(find.text('MyPortfolio Mobile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.text('Flutter version of the portfolio'), findsOneWidget);
      expect(find.text('https://example.com/mobile'), findsOneWidget);
    });

    testWidgets('empty list shows a message', (tester) async {
      final api = fakeApi(handler: (_) async => http.Response('[]', 200));
      await tester.pumpWidget(testApp(api: api));
      await openProjectList(tester);

      expect(find.text('No projects found.'), findsOneWidget);
    });

    testWidgets('server error shows Retry, and Retry loads again', (
      tester,
    ) async {
      var calls = 0;
      final api = fakeApi(
        handler: (_) async {
          calls++;
          return calls == 1
              ? http.Response('server down', 500)
              : http.Response('[]', 200);
        },
      );
      await tester.pumpWidget(testApp(api: api));
      await openProjectList(tester);

      expect(find.textContaining('Failed to load projects'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.text('No projects found.'), findsOneWidget);
    });

    testWidgets('drawer View Projects opens the list', (tester) async {
      await tester.pumpWidget(testApp());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Projects'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(find.text('MyPortfolio Web'), findsOneWidget);
    });
  });

  group('ProjectDetailScreen image', () {
    const base = Project(
      title: 'P',
      description: 'D',
      techStack: 'T',
      projectUrl: 'https://example.com',
    );

    testWidgets('no image widget when the image URL is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProjectDetailScreen(project: base)),
      );

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows an image when the image URL is set', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProjectDetailScreen(
            project: Project(
              title: 'P',
              description: 'D',
              techStack: 'T',
              projectUrl: 'https://example.com',
              projectImageUrl: 'https://example.com/cover.png',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
