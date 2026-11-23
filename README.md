# Portfolio Mobile Project

Nama : PUTU RIZKI MANIK WIDIADNYANA

NPM : 2506621900

Kelas : B

## About
Proyek ini adalah versi mobile dari website portofolio pribadi saya ([myportofolio](https://github.com/RizkiManik-W/myportofolio)) yang dibuat dengan Flutter. Proyek ini saya buat untuk belajar pengembangan aplikasi mobile multiplatform dan, kedepannya, akan terhubung dengan backend Django portofolio saya.

## Tech Stack
- Dart
- Flutter (Material 3)
- material_ui (Material widgets, pengganti import `package:flutter/material.dart`)
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
│   ├── main.dart                # bootstrap aplikasi (MyApp, MaterialApp, tema)
│   ├── screens/
│   │   ├── menu.dart            # halaman utama (MyHomePage, InfoCard)
│   │   ├── project_form.dart    # form tambah proyek (ProjectFormPage)
│   │   └── experience_form.dart # add experience form (ExperienceFormPage)
│   └── widgets/
│       ├── left_drawer.dart     # menu drawer (LeftDrawer)
│       └── project_card.dart    # tombol menu (ItemHomepage, ItemCard)
├── test/
│   ├── widget_test.dart         # widget tests untuk halaman utama
│   ├── navigation_form_test.dart # drawer, navigation, and project form validation tests
│   └── experience_form_test.dart # experience form navigation and validation tests
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

## Tutorial 09
Di tutorial ini, saya menambahkan navigasi, layout, dan form ke aplikasi:
- Mengganti import `package:flutter/material.dart` dengan package `material_ui`.
- Membuat `LeftDrawer` dengan header dan dua menu: **Home** dan **Add Project**. Keduanya memakai `Navigator.pushReplacement` agar halaman tidak menumpuk di stack.
- Membuat `ProjectFormPage` (`StatefulWidget`) dengan `Form` dan `GlobalKey<FormState>`. Field-nya: Nama Proyek, Deskripsi, Kategori (dropdown), Teknologi, dan Tautan. Setiap field memiliki validator (tidak boleh kosong, deskripsi minimal 10 karakter, tautan harus URL valid).
- Tombol **Save** memvalidasi form, lalu menampilkan `AlertDialog` berisi data yang diinput. Menekan **OK** menutup dialog dan me-reset form.
- Tombol **Tambah Proyek** di halaman utama membuka form dengan `Navigator.push`, sehingga halaman utama tetap ada di bawahnya dan bisa kembali dengan tombol/gesture back.
- Refactor struktur file: halaman ke `lib/screens/`, widget reusable ke `lib/widgets/`.
- Menambahkan widget tests untuk drawer, navigasi, validasi form, dan dialog.

## Notes
This is a learning project, so feel free to explore, modify, and improve it, hehe~.

## AI Disclosure
Saya menggunakan Claude Code (Anthropic) di VS Code untuk memahami instruksi tugas, membandingkannya dengan kode proyek, dan mengerjakan implementasi secara bertahap (step by step). Saya meninjau setiap perubahan dan melakukan commit sendiri.

Saya melakukan prompt pada claude untuk membuatkan step by step guide lengkap dengan penjelasan detil mengenai step yang dilakukan.

### Tugas 8
- **Tools:** Claude Code (Anthropic) di VS Code.
- **Strategi prompt:** Saya memberikan brief mengenai tugas dan meminta step by step untuk menyelesaikannya dan meminta penjelasan mengenai apa yang dilakukan di setiap step, sehingga saya paham jelas apa yang terjadi.
- **Parts yang dibantu AI :**
  - memilih **Experience** section dengan cara membaca `Experience` model di Django backend saya, lalu mencocokkan form fields (title, description, category, thumbnail, start date, end date) dan validasinya.
  - Membuat test `experience_form_test.dart`.
  - Drafting reflection yang nanti akan saya tulis sendiri.
- **Limitasi AI:** AI tidak dapat menjalankan appnya jadi saya harus mengekceknya sendiri melalui chrome.

## Progress Tugas

### Tugas 7
Identitas pada info card, mengganti color di ItemHomepage, button tambahan untuk skills, grid yang beradaptasi pada lebar screen dan tes.

### Tugas 8
- Membuat **Tambah Pengalaman** form (`ExperienceFormPage`) di `lib/screens/experience_form.dart`, yang berbasis django `Experience` model: Judul (title), Deskripsi (description), Kategori (category dropdown), Thumbnail (optional), Tanggal Mulai (start date), and Tanggal Selesai (optional end date), dengan tanggal dipilih melalui `showDatePicker()`.
- Validation: field yang diminta tidak boleh kosng atau hanya space, tittle paling panjang 255 karakter, deskripsi minimal 10 karakter, thumbnail harus `http`/`https` URL, dan end date tidak boleh sebelum start date.
- **Simpan** button menunjukkan summary dari input di sebuah `AlertDialog`; **OK** button menutup dialgod dan mereset form.
- menambahkan **Tambah Pengalaman** card (`Navigator.push`)di homepage dan sebuah **Add Experience** option (`Navigator.pushReplacement`) di drawer. Grid menunjukkan 2 columns di handphone dan semua cards di satu row di screen yang lebar.
- menambahkan 10 widget test (27 tests dan lulus), dan `flutter analyze` mereport tidak ad isu.

## Assignment Reflection

### Tugas 7

1. widget tree merupakan hirarki widgets yang mendeskripsikan Flutter UI. Setiap widget merupakah sebuah node, dan kebanyakan widgets meliputi satu child atau beberpa children. Di ap ini tree dimulai dari `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold`, lalu branch menjadi 'AppBar' dan body (`SafeArea` → `SingleChildScrollView` → `Column` → a `Row` of `InfoCard`s and a `GridView` of `ItemCard`s). Parent Child relationship bekerja dalam dua arah: parent melakukan pass constraint ke bawah (contohnya, `Expanded` mmeberi tahu `InfoCard` seberapa besar dirinya, dan `ConstrainedBox` mlimit page menjadi 960px), setiap child memilih size didalam constraint tersebut dan melakuka report  ke atas, lalu parent meletakannya. Parent juga melakukan pass **data** kebawah melalui constructor paramaters, seperti `InfoCard(title: 'NPM', content: npm)` dan `ItemCard(item)`. Ketika widget melaukan rebuilds, hanya subtreenya yang di rebuilt. 

2. Widget yang digunakan dalam proyek ini:
   - `MaterialApp`: root dari aplikasi; menyediakan tema Material, navigasi, dan judul aplikasi.
   - `MyApp` / `MyHomePage` (custom `StatelessWidget`): bootstrap aplikasi dan halaman utama.
   - `Scaffold`: layout dasar halaman dengan slot untuk app bar dan body, serta tempat munculnya SnackBar.
   - `AppBar`: bar di bagian atas yang menampilkan judul "MyPortfolio".
   - `SafeArea`: menjaga konten agar tidak tertutup notch dan system bar.
   - `SingleChildScrollView`: membuat halaman dapat di-scroll pada layar pendek sehingga tidak terjadi overflow.
   - `Center`: memposisikan konten di tengah secara horizontal pada layar lebar.
   - `ConstrainedBox`: membatasi lebar konten maksimal 960 px pada desktop.
   - `Column`: menyusun info card, teks sambutan, dan grid secara vertikal.
   - `Row`: menempatkan tiga `InfoCard` secara berdampingan.
   - `Expanded`: memberikan lebar yang sama untuk setiap `InfoCard` di dalam row.
   - `InfoCard` (custom): menampilkan satu informasi profil (NPM, Name, Class).
   - `Card`: permukaan Material dengan elevasi di dalam `InfoCard`.
   - `Padding`: memberikan jarak di sekitar konten.
   - `Text`: menampilkan teks (judul, label, dan pesan sambutan).
   - `SizedBox`: memberikan jarak vertikal yang tetap antar widget.
   - `LayoutBuilder`: membaca lebar yang tersedia sehingga grid dapat menampilkan 2 kolom di ponsel dan 4 kolom di layar yang lebih lebar.
   - `GridView.count`: menyusun tombol-tombol aksi dalam bentuk grid.
   - `ItemCard` (custom): satu tombol aksi berwarna yang dibuat dari model `ItemHomepage` (nama, ikon, warna).
   - `Material`: memberikan warna latar (`item.color`) dan sudut membulat pada setiap `ItemCard`.
   - `InkWell`: membuat kartu dapat ditekan dan menampilkan efek ripple.
   - `Icon`: menampilkan ikon dari setiap aksi.
   - `ScaffoldMessenger` dan `SnackBar`: menampilkan pesan "Kamu telah menekan tombol [nama]!" di bagian bawah layar.

3. `MaterialApp` melakukan set up pada app yang diperlukan oleh Material app: seperti tema, navigasi page, home page, dan `ScaffoldMessenger` yang digunakan oleh SnackBars. Ini digunakan sebagai root widget karena widgets yang berada dibawahnya akan melihat ke attaus melalui `BuildContext` (seperti `Theme.of(context)`); tanpa ini `Scaffold`, `AppBar`, dab `SnackBar` tidak akan memiliki theme atau navigator untuk digunakan.

4. `StatelessWidget` tidak memiliki state, ia hanya menampilkan data yang diterima, jadi hanya melakukan rebuild hanya ketika parent melakukan pass input baru. `StatefulWidget` menyimpan `State` object dan dapat memanggil `setState()` untuk redraw ketika data diubah. Saya disin menggunakan `StatelessWidget` untuk `MyHomePage`, `InfoCard`, dan `ItemCard` karena mereka hanya mendisplay fixed data, `StatefulWidget` dibutuhkan untuk forms, toggles, counters  atau list loaded dari Django API.

5. `BuildContext` merupakan sebuah widget location di dalam widget tree, di pass ke semua setiap `build` method. Ini memungkinkan widget untuk mencari ancestor dari node dan service yang diberikan. Di app ini, `Theme.of(context)` mendapatkan theme oclor untuk `AppBar`, dan `ScaffoldMessenger.of(context)` menampilkan SnackBar ketika `ItemCard` di tap.

6. **Hot reload** (`r`) memasukkan perubahan code ke app yang sedang berjalan dan melakukan rebuild UI tanpa menghilangkan state, sehingga perubahan visual langsung terlihat hampir seketika. **Hot restart** (`R`) juga memuat code baru tetapi me-reset semua state dan menjalankan app kembali dari `main()`. Hot restart diperlukan ketika perubahan mempengaruhi code yang hanya dijalankan sekali, seperti `main()`, `initState()`, atau variabel global/static, atau ketika mengubah widget dari stateless menjadi stateful. Full restart (stop lalu run ulang) diperlukan untuk perubahan di luar code Dart, seperti menambah package di `pubspec.yaml`, native code Android/iOS, atau assets.

### Tugas 8

1. `Navigato.push()` menambahkan page baru diatas stack, jadi page sebelumnya tetap berada dibawah dan use dapat kembali kesana dengan menggunakan back button. `Navigator.pushReplacement()` mereplace top page dengan yang baru, yang membuat old page di remove that tidak dapat kembali kesana. `Navigator.pop()` meremove top page dan mereturn page dibawahnya. **Tambah Pengalaman** car menggunakan `Navigator.push()`, jadi hompage tetpa berada di bawah form that user dapat kembali kesana dengan back button. **Home** option di drawer menggunakan `Navigator.pushReplacement()` to `MyHomePage`: form page diganti dengan new home page, jadi stack tidak terus berkembang setiap kali user berpindah dengan drawer. 

2. `Scaffold` memberikan stiap page frame yang sama: sebuah `appBar` slot di atas, sebuah `drawer` di samping, dan `body` untuk content. `AppBar` menunjukkan page tittle bersamma menu button yang membukan drawer, dan `Drawer` (`LeftDrawer`) merupakan satu widget yang digunakan pada homepage, the project forn, dan experience form, jadi navigation menu selalu sama. Contoh untuk theme color: the `AppBar` pada `MyHomePage`, `ProjectFormPage`, dan `ExperienceFormPage` semua menggunakan `Theme.of(context).colorScheme.primary` (indigo, dari `seedColorr` di `main.dart`). JIka theme color dirubah di satu tempat, semua juda akan terubah.

3. Form di susun sebagai single `column` dengan field yang mengisi width (`CrossAxisAlignment.stretch`), karena top-to-bottom order yang paling mudah untuk disi di phonescreen. `SizedBox` digunakan untuk spacing antara fields (16 px) dan sebelum button (24 px), jadi labels, error messages, dan input tidak saling bertumpuk. `padding` menambahkan space di screen edges, dan `ConstrainedBox` melimit form menjadi 600 px wide yang membuatnya tetap readable di desktop/chrome.  `SingleChildScrollView` membuat semuanya bisa discroll, jadi ketika sccreen pendek atau keyboard muncul, setiap field dan **Simpan** button tetap reachable tanpa overflowing. `SafeArea` memastikan konten tidak tertutup oleh notch atau system bars.

4. `GlobalKey<FormState>` merupakan kunci yang menghubungkan `Form` widget dengan statenya, jadi **Simpan** button dapat memanggil `_formKey.currentState!.validate()`. `validate()` menjalankan `validator` untuk setiap field, sebuah validator mereturn error message ketika input tidak valid, atau `null` ketika ia valid. `validate()` mereturn `true` hanya ketika setiap field valid, dan ketika itu summary dialog ditunjukkan. Contoh dari value yang di tolak: thumbnail `ftp://gambar`, Field menggunakan `TextInputType.url`, tetapi URL keyboard hanya menambahkan keys seperti  `/` and `.com`, user masih dapat mengetik atau paste text apapun, termasuk space atau sceheme selain `http`/`https`. Begitu juga, judul yang hanya berisi spasi tetap bisa diketik dengan keyboard biasa. Jadi input type dan keyboard hanya membantu user saat mengetik, sedangkan `validator` yang benar-benar memastikan input sesuai dengan aturan model.