# Portfolio Mobile Project

Nama : PUTU RIZKI MANIK WIDIADNYANA

NPM : 2506621900

Kelas : B

## About
Proyek ini adalah versi mobile dari website portofolio pribadi saya ([myportofolio](https://github.com/RizkiManik-W/myportofolio)) yang dibuat dengan Flutter. Proyek ini saya buat untuk belajar pengembangan aplikasi mobile multiplatform dan, kedepannya, akan terhubung dengan backend Django portofolio saya.

## Tech Stack
- Dart
- Flutter (Material 3)
- flutter_test (widget testing)
- flutter_lints (static analysis)

## Local Setup

### 1. Install Flutter SDK
Ikuti panduan resmi di https://docs.flutter.dev/get-started/install, lalu cek instalasi:
```bash
flutter doctor
```

### 2. Clone the repository
```bash
git clone https://github.com/RizkiManik-W/myportofolio_mobile.git
cd myportofolio_mobile
```

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the app
```bash
flutter run -d chrome
```

Untuk melihat device yang tersedia (Chrome, emulator Android, dll.):
```bash
flutter devices
```

Saat aplikasi berjalan, tekan `r` untuk hot reload, `R` untuk hot restart, dan `q` untuk keluar.

### 5. Check code quality and run tests
```bash
flutter analyze
flutter test
```

## Project Structure
```bash
myportofolio_mobile/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart        # bootstrap aplikasi (MyApp, MaterialApp, tema)
│   └── menu.dart        # halaman utama (MyHomePage, InfoCard, ItemCard, ItemHomepage)
├── test/
│   └── widget_test.dart # widget tests untuk halaman utama
├── tool/
│   └── halo_burhan.dart # contoh program Dart dari tutorial
├── docs/                # screenshot
├── android/ ios/ web/ windows/ linux/ macos/
└── README.md
```

## Tutorial 08
Di tutorial ini, saya melakukan setup Flutter SDK, membuat proyek `myportofolio_mobile`, memisahkan halaman utama ke `menu.dart`, mengubah `MyHomePage` menjadi `StatelessWidget`, dan membuat widget `InfoCard` dan `ItemCard` dengan SnackBar untuk setiap tombol.

Screenshot:
- [Tampilan ponsel](docs/tutorial08-mobile.png)
- [Tampilan desktop](docs/tutorial08-desktop.png)

## Notes
This is a learning project, so feel free to explore, modify, and improve it, hehe~.

## AI Disclosure
Saya menggunakan Claude Code (Anthropic) di VS Code untuk memahami instruksi tugas, membandingkannya dengan kode proyek, dan mengerjakan implementasi secara bertahap (step by step). Saya meninjau setiap perubahan dan melakukan commit sendiri.
