import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.color);

  final String name;
  final IconData icon;

  /// Background color of this item's card, so each action is visually distinct.
  final Color color;
}

class ItemCard extends StatelessWidget {
  const ItemCard(this.item, {super.key});

  final ItemHomepage item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Kamu telah menekan tombol ${item.name}!'),
              ),
            );

          // Kartu yang punya halaman tujuan dibuka dengan push, sehingga
          // halaman utama tetap di bawahnya dan tombol back bisa dipakai.
          final Widget? destination = switch (item.name) {
            'Lihat Proyek' => const ProjectListScreen(),
            'Tambah Proyek' => const ProjectFormPage(),
            'Tambah Pengalaman' => const ExperienceFormPage(),
            _ => null,
          };
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 30),
              const SizedBox(height: 6),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
