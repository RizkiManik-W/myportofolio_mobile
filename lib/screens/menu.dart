import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = '2506621900';
  final String nama = 'Putu Rizki Manik Widiadnyana';
  final String kelas = 'PBP B';

  final List<ItemHomepage> items = const [
    ItemHomepage('Lihat Proyek', Icons.folder, Colors.blue),
    ItemHomepage('Tambah Proyek', Icons.add_circle, Colors.green),
    ItemHomepage('Tambah Pengalaman', Icons.work, Colors.teal),
    ItemHomepage('Lihat Skills', Icons.psychology, Colors.purple),
    ItemHomepage('Logout', Icons.logout, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InfoCard(title: 'NPM', content: npm),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Name', content: nama),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Class', content: kelas),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Selamat datang di MyPortfolio Mobile!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  // Phones get 2 columns, wider screens put all cards in one row.
                  LayoutBuilder(
                    builder: (context, constraints) => GridView.count(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      crossAxisCount: constraints.maxWidth < 600
                          ? 2
                          : items.length,
                      mainAxisExtent: 160,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: items.map((item) => ItemCard(item)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
