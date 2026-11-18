import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  final save = find.widgetWithText(ElevatedButton, 'Save');
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

/// The app's root navigator, used to inspect the route stack.
NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator));

Future<void> pumpForm(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
}

void main() {
  group('Drawer', () {
    testWidgets('shows the header and both menu items', (tester) async {
      await tester.pumpWidget(const MyApp());
      await openDrawer(tester);

      expect(find.text('My Portfolio'), findsOneWidget);
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
    });

    testWidgets('Add Project replaces the page with the form', (tester) async {
      await tester.pumpWidget(const MyApp());
      await openDrawer(tester);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
      // pushReplacement swaps the route, so there is nothing to go back to.
      expect(navigator(tester).canPop(), isFalse);
    });

    testWidgets('Home goes back to the home page from the form', (
      tester,
    ) async {
      await pumpForm(tester);
      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });
  });

  group('Tambah Proyek card', () {
    testWidgets('pushes the form, and back returns home', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsOneWidget);
      // push keeps the home page underneath the form.
      expect(navigator(tester).canPop(), isTrue);

      // Same as the system back button/gesture.
      navigator(tester).pop();
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });

    testWidgets('other cards stay on the home page', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });
  });

  group('ProjectFormPage', () {
    testWidgets('shows every field and the Save button', (tester) async {
      await pumpForm(tester);

      expect(field('Nama Proyek'), findsOneWidget);
      expect(field('Deskripsi'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(field('Teknologi'), findsOneWidget);
      expect(field('Tautan'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('empty form shows required-field errors', (tester) async {
      await pumpForm(tester);
      await tapSave(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Teknologi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tautan tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('short description and invalid link are rejected', (
      tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(field('Deskripsi'), 'Pendek');
      await tester.enterText(field('Tautan'), 'bukan url');
      await tapSave(tester);

      expect(find.text('Deskripsi minimal 10 karakter!'), findsOneWidget);
      expect(
        find.text('Tautan harus berupa URL valid (https://...)'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('valid data shows a dialog, and OK resets the form', (
      tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(field('Nama Proyek'), 'MyPortfolio');
      await tester.enterText(
        field('Deskripsi'),
        'Website portofolio pribadi saya',
      );
      await tester.tap(find.text('Web'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mobile').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('Teknologi'), 'Flutter, Django');
      await tester.enterText(
        field('Tautan'),
        'https://github.com/RizkiManik-W/myportofolio',
      );
      await tapSave(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Proyek berhasil disimpan!'), findsOneWidget);
      expect(find.text('Nama: MyPortfolio'), findsOneWidget);
      expect(
        find.text('Deskripsi: Website portofolio pribadi saya'),
        findsOneWidget,
      );
      expect(find.text('Kategori: Mobile'), findsOneWidget);
      expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
      expect(
        find.text('Tautan: https://github.com/RizkiManik-W/myportofolio'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('MyPortfolio'), findsNothing);
      expect(find.text('Flutter, Django'), findsNothing);
      expect(find.text('Web'), findsOneWidget);
    });
  });
}
