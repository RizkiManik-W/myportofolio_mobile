import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Form page for adding a new portfolio project.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _description = '';
  String _category = 'Web';
  String _technologies = '';
  String _link = '';

  static const List<String> _categories = [
    'Web',
    'Mobile',
    'Data Science',
    'Game',
    'Lainnya',
  ];

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proyek berhasil disimpan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: $_name'),
              Text('Deskripsi: $_description'),
              Text('Kategori: $_category'),
              Text('Teknologi: $_technologies'),
              Text('Tautan: $_link'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState!.reset();
              setState(() => _category = 'Web');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shared look for every text field on this page.
  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Proyek',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: _decoration('Nama Proyek', 'Contoh: MyPortfolio'),
                onChanged: (value) => setState(() => _name = value),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Nama proyek tidak boleh kosong!'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _decoration(
                  'Deskripsi',
                  'Ceritakan singkat tentang proyek ini',
                ),
                maxLines: 3,
                onChanged: (value) => setState(() => _description = value),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong!';
                  }
                  if (value.trim().length < 10) {
                    return 'Deskripsi minimal 10 karakter!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _decoration('Kategori', 'Pilih kategori'),
                initialValue: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _decoration('Teknologi', 'Contoh: Flutter, Django'),
                onChanged: (value) => setState(() => _technologies = value),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Teknologi tidak boleh kosong!'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _decoration(
                  'Tautan',
                  'https://github.com/username/proyek',
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) => setState(() => _link = value),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tautan tidak boleh kosong!';
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                    return 'Tautan harus berupa URL valid (https://...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Align(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
