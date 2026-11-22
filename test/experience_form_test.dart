import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).first);

Future<void> pumpForm(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

Future<void> tapField(WidgetTester tester, String label) async {
  await tester.ensureVisible(field(label));
  await tester.tap(field(label));
  await tester.pumpAndSettle();
}

Future<void> tapSimpan(WidgetTester tester) async {
  final simpan = find.widgetWithText(ElevatedButton, 'Simpan');
  await tester.ensureVisible(simpan);
  await tester.tap(simpan);
  await tester.pumpAndSettle();
}

/// Opens the start date picker and confirms today's date.
Future<void> pickStartToday(WidgetTester tester) async {
  await tapField(tester, 'Tanggal Mulai');
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// Opens the end date picker and picks day 1 of the previous month,
/// which is always before today.
Future<void> pickEndLastMonth(WidgetTester tester) async {
  await tapField(tester, 'Tanggal Selesai (opsional)');
  await tester.tap(find.byTooltip('Previous month'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

void main() {
  group('Opening the Pengalaman form', () {
    testWidgets('Tambah Pengalaman card pushes the form, back returns home', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.ensureVisible(find.text('Tambah Pengalaman'));
      await tester.tap(find.text('Tambah Pengalaman'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      // push keeps the home page underneath, so back is available.
      expect(navigator(tester).canPop(), isTrue);

      // Same as the device back button.
      navigator(tester).pop();
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });

    testWidgets('drawer keeps Home and Add Project, and adds Add Experience', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await openDrawer(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Experience'), findsOneWidget);
    });

    testWidgets('drawer Add Experience opens the form', (tester) async {
      await tester.pumpWidget(const MyApp());
      await openDrawer(tester);
      await tester.tap(find.text('Add Experience'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
      expect(navigator(tester).canPop(), isFalse);
    });

    testWidgets('form page has the drawer, and Home goes back home', (
      tester,
    ) async {
      await pumpForm(tester);
      await openDrawer(tester);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });
  });

  group('ExperienceFormPage validation', () {
    testWidgets('shows every field and the Simpan button', (tester) async {
      await pumpForm(tester);

      expect(find.text('Tambah Pengalaman'), findsOneWidget);
      expect(field('Judul'), findsOneWidget);
      expect(field('Deskripsi'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Full-Time'), findsOneWidget);
      expect(field('Thumbnail (opsional)'), findsOneWidget);
      expect(field('Tanggal Mulai'), findsOneWidget);
      expect(field('Tanggal Selesai (opsional)'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Simpan'), findsOneWidget);
    });

    testWidgets('empty form shows required-field errors and no dialog', (
      tester,
    ) async {
      await pumpForm(tester);
      await tapSimpan(tester);

      expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tanggal mulai tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'spaces only, short text, long title, and bad URL are rejected',
      (tester) async {
        await pumpForm(tester);
        await tester.enterText(field('Judul'), '     ');
        await tester.enterText(field('Deskripsi'), 'Pendek');
        await tester.enterText(field('Thumbnail (opsional)'), 'ftp://gambar');
        await tapSimpan(tester);

        expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
        expect(find.text('Deskripsi minimal 10 karakter!'), findsOneWidget);
        expect(
          find.text('Thumbnail harus berupa URL valid (https://...)'),
          findsOneWidget,
        );

        await tester.enterText(field('Judul'), 'a' * 256);
        await tapSimpan(tester);
        expect(find.text('Judul maksimal 255 karakter!'), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets('end date before start date is rejected', (tester) async {
      await pumpForm(tester);
      await tester.enterText(field('Judul'), 'Asisten Dosen PBP');
      await tester.enterText(field('Deskripsi'), 'Membantu mahasiswa di lab');
      // Pick the end date first, then a later start date.
      await pickEndLastMonth(tester);
      await pickStartToday(tester);
      await tapSimpan(tester);

      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('valid data shows a summary dialog, and OK resets the form', (
      tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(field('Judul'), 'Asisten Dosen PBP');
      await tester.enterText(
        field('Deskripsi'),
        'Membantu mahasiswa di lab Flutter',
      );
      await tester.ensureVisible(find.text('Full-Time'));
      await tester.tap(find.text('Full-Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Research').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        field('Thumbnail (opsional)'),
        'https://contoh.com/gambar.png',
      );
      await pickStartToday(tester);
      await tapSimpan(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
      expect(find.text('Judul: Asisten Dosen PBP'), findsOneWidget);
      expect(
        find.text('Deskripsi: Membantu mahasiswa di lab Flutter'),
        findsOneWidget,
      );
      expect(find.text('Kategori: Research'), findsOneWidget);
      expect(
        find.text('Thumbnail: https://contoh.com/gambar.png'),
        findsOneWidget,
      );
      expect(find.text('Mulai: ${formatDate(DateTime.now())}'), findsOneWidget);
      expect(find.text('Selesai: Masih berlangsung'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Asisten Dosen PBP'), findsNothing);
      expect(find.text(formatDate(DateTime.now())), findsNothing);
      expect(find.text('Full-Time'), findsOneWidget);
    });
  });

  testWidgets('Simpan stays reachable on a 320 x 568 phone screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await pumpForm(tester);
    await tapSimpan(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
  });
}
