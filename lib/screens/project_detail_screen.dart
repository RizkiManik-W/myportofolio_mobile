import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Shows every field of one project. The image is only shown when the
/// project has an image URL.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (project.projectImageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        project.projectImageUrl,
                        height: 200,
                        fit: BoxFit.cover,
                        // A broken link shows an icon instead of crashing.
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 200,
                              child: Center(
                                child: Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Description', value: project.description),
                  _DetailRow(label: 'Tech Stack', value: project.techStack),
                  _DetailRow(label: 'Project URL', value: project.projectUrl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(value.isEmpty ? '-' : value),
        ],
      ),
    );
  }
}
