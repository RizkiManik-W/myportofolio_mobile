import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  group('Project JSON', () {
    test('fromJson reads the snake_case keys from Django', () {
      final project = Project.fromJson({
        'id': '7f1c2a3e-0000-4000-8000-000000000001',
        'title': 'MyPortfolio',
        'description': 'Personal portfolio website',
        'tech_stack': 'Django, Flutter',
        'project_url': 'https://example.com',
        'project_image_url': 'https://example.com/cover.png',
        // Extra read-only fields from the serializer are ignored.
        'star_count': 3,
        'is_starred': false,
      });

      expect(project.id, '7f1c2a3e-0000-4000-8000-000000000001');
      expect(project.title, 'MyPortfolio');
      expect(project.description, 'Personal portfolio website');
      expect(project.techStack, 'Django, Flutter');
      expect(project.projectUrl, 'https://example.com');
      expect(project.projectImageUrl, 'https://example.com/cover.png');
    });

    test('missing or null optional fields become empty strings', () {
      final project = Project.fromJson({
        'id': 'abc',
        'title': 'No image',
        'description': 'Project without optional fields',
        'project_image_url': null,
      });

      expect(project.techStack, '');
      expect(project.projectUrl, '');
      expect(project.projectImageUrl, '');
    });

    test('toJson uses snake_case and never sends the id', () {
      const project = Project(
        id: 'should-not-be-sent',
        title: 'New',
        description: 'A new project',
        techStack: 'Flutter',
        projectUrl: 'https://example.com',
      );

      expect(project.toJson(), {
        'title': 'New',
        'description': 'A new project',
        'tech_stack': 'Flutter',
        'project_url': 'https://example.com',
        'project_image_url': '',
      });
    });
  });
}
