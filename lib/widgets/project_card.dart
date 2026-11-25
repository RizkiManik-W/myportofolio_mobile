import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthState>();
    if (!auth.isLoggedIn) {
      _showMessage(context, 'You are not logged in.');
      return;
    }
    await auth.logout();
    if (!context.mounted) return;
    _showMessage(context, 'Logged out. See you again!');
  }

  Future<void> _onTap(BuildContext context) async {
    if (item.name == 'Logout') {
      await _logout(context);
      return;
    }

    _showMessage(context, 'Kamu telah menekan tombol ${item.name}!');

    // Adding a project needs a token, so ask for login first.
    if (item.name == 'Tambah Proyek') {
      final loggedIn = await ensureLoggedIn(context);
      if (!loggedIn || !context.mounted) return;
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context),
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
