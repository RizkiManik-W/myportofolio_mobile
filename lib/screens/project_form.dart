import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form page that creates a new project in Django with
/// `POST /api/v1/projects/` (only the superuser may do this).
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  /// Returns an error message when [value] is not an http(s) URL.
  static String? _urlError(String value) {
    final uri = Uri.tryParse(value);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isWebUrl ? null : 'Must be a valid URL (https://...)';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // The page is already guarded, but the token can be gone by now
    // (for example after Logout in the drawer), so check again.
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    final newProject = Project(
      title: _title.trim(),
      description: _description.trim(),
      techStack: _techStack.trim(),
      projectUrl: _projectUrl.trim(),
      projectImageUrl: _projectImageUrl.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await api.createProject(newProject, token: auth.token!);
      if (!mounted) return;
      // Not awaited: the finally block below must stop the spinner now,
      // not after the dialog is closed.
      _showSuccess(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Django no longer accepts this token: forget it and ask again.
        await auth.logout();
        _showError('Your session has expired. Please log in again.');
      } else if (e.statusCode == 403) {
        _showError('Only the portfolio owner can add projects (403).');
      } else {
        _showError('Failed to save project (${e.statusCode}).');
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Cannot reach the server. Is Django running?');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccess(Project created) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project saved!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${created.title}'),
              Text('Description: ${created.description}'),
              Text('Tech Stack: ${created.techStack}'),
              Text('Project URL: ${created.projectUrl}'),
              if (created.projectImageUrl.isNotEmpty)
                Text('Image URL: ${created.projectImageUrl}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState!.reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                decoration: _decoration('Title', 'Example: MyPortfolio'),
                maxLength: 255,
                onChanged: (value) => _title = value,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Title cannot be empty!'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _decoration(
                  'Description',
                  'A short story about this project',
                ),
                maxLines: 3,
                onChanged: (value) => _description = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description cannot be empty!';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _decoration(
                  'Tech Stack',
                  'Example: Flutter, Django',
                ),
                maxLength: 255,
                onChanged: (value) => _techStack = value,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Tech stack cannot be empty!'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _decoration(
                  'Project URL',
                  'https://github.com/username/project',
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) => _projectUrl = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project URL cannot be empty!';
                  }
                  return _urlError(value.trim());
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _decoration(
                  'Project Image URL (optional)',
                  'https://example.com/screenshot.png',
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) => _projectImageUrl = value,
                validator: (value) {
                  // Optional: an empty field is fine, anything else must be
                  // a URL because Django uses a URLField.
                  if (value == null || value.trim().isEmpty) return null;
                  return _urlError(value.trim());
                },
              ),
              const SizedBox(height: 24),
              Align(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  // Disabled while waiting, so the project isn't sent twice.
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
