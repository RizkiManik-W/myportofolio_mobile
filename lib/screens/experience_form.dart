import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Form page for adding a work or organisation experience.
///
/// The fields follow the `Experience` model of the Django portfolio:
/// title, description, category, thumbnail, started_at, and ended_at.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const String _defaultCategory = 'Full-Time';
  static const List<String> _categories = [
    'Internship',
    'Research',
    'Volunteer',
    'Part-Time',
    'Full-Time',
    'Freelance',
  ];

  /// Same limit as `CharField(max_length=255)` in the Django model.
  static const int _titleMaxLength = 255;

  String _title = '';
  String _description = '';
  String _category = _defaultCategory;
  String _thumbnail = '';
  DateTime? _startDate;
  DateTime? _endDate;

  // The date fields are read-only text fields, so their text is set
  // through controllers after the user picks a date.
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  /// Formats a date as dd/mm/yyyy without needing the intl package.
  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Pilih tanggal mulai',
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      _startController.text = _formatDate(picked);
    });
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final first = _startDate ?? DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (now.isBefore(first) ? first : now),
      firstDate: first,
      lastDate: now.isBefore(first) ? first : now,
      helpText: 'Pilih tanggal selesai',
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _endController.text = _formatDate(picked);
    });
  }

  void _clearEndDate() {
    setState(() {
      _endDate = null;
      _endController.clear();
    });
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _title = '';
      _description = '';
      _category = _defaultCategory;
      _thumbnail = '';
      _startDate = null;
      _endDate = null;
      _startController.clear();
      _endController.clear();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengalaman berhasil disimpan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Judul: ${_title.trim()}'),
              Text('Deskripsi: ${_description.trim()}'),
              Text('Kategori: $_category'),
              Text(
                'Thumbnail: ${_thumbnail.trim().isEmpty ? '-' : _thumbnail.trim()}',
              ),
              Text('Mulai: ${_formatDate(_startDate!)}'),
              Text(
                'Selesai: ${_endDate == null ? 'Masih berlangsung' : _formatDate(_endDate!)}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shared look for every field on this page.
  InputDecoration _decoration(String label, String hint, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Pengalaman',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          // Scrolls when the screen is short or the keyboard is open,
          // so every field and the Simpan button stay reachable.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                // Keeps fields a readable width on desktop and Chrome.
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: _decoration(
                        'Judul',
                        'Contoh: Asisten Dosen PBP',
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => setState(() => _title = value),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tidak boleh kosong!';
                        }
                        if (value.trim().length > _titleMaxLength) {
                          return 'Judul maksimal $_titleMaxLength karakter!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _decoration(
                        'Deskripsi',
                        'Ceritakan peran dan kontribusimu',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) =>
                          setState(() => _description = value),
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
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _category = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _decoration(
                        'Thumbnail (opsional)',
                        'https://contoh.com/gambar.png',
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (value) => setState(() => _thumbnail = value),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        // Thumbnail is optional, like blank=True in Django.
                        if (text.isEmpty) return null;
                        final uri = Uri.tryParse(text);
                        if (uri == null ||
                            !(uri.scheme == 'http' || uri.scheme == 'https') ||
                            !uri.hasAuthority) {
                          return 'Thumbnail harus berupa URL valid (https://...)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startController,
                      readOnly: true,
                      decoration: _decoration(
                        'Tanggal Mulai',
                        'Pilih tanggal',
                        suffix: const Icon(Icons.calendar_today),
                      ),
                      onTap: _pickStartDate,
                      validator: (_) => _startDate == null
                          ? 'Tanggal mulai tidak boleh kosong!'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _endController,
                      readOnly: true,
                      decoration: _decoration(
                        'Tanggal Selesai (opsional)',
                        'Kosongkan jika masih berlangsung',
                        suffix: _endDate == null
                            ? const Icon(Icons.event)
                            : IconButton(
                                tooltip: 'Hapus tanggal selesai',
                                icon: const Icon(Icons.clear),
                                onPressed: _clearEndDate,
                              ),
                      ),
                      onTap: _pickEndDate,
                      validator: (_) {
                        if (_endDate != null &&
                            _startDate != null &&
                            _endDate!.isBefore(_startDate!)) {
                          return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Align(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _save,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
