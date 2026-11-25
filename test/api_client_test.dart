import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const baseUrl = 'http://test.local';

/// Builds an [ApiClient] whose requests are answered by [handler]
/// instead of a real server.
ApiClient clientWith(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(client: MockClient(handler), baseUrl: baseUrl);

http.Response json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('getProjects', () {
    test('GETs the project list and parses every project', () async {
      late http.Request sent;
      final api = clientWith((request) async {
        sent = request;
        return json([
          {
            'id': '1',
            'title': 'MyPortfolio',
            'description': 'Website',
            'tech_stack': 'Django',
            'project_url': 'https://example.com',
            'project_image_url': '',
          },
          {'id': '2', 'title': 'Mobile', 'description': 'Flutter app'},
        ], 200);
      });

      final projects = await api.getProjects();

      expect(sent.method, 'GET');
      expect(sent.url.toString(), '$baseUrl/api/v1/projects/');
      expect(projects.map((p) => p.title), ['MyPortfolio', 'Mobile']);
      expect(projects.first.techStack, 'Django');
    });

    test('throws ApiException with the status code on a server error', () {
      final api = clientWith((_) async => http.Response('boom', 500));

      expect(
        api.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('createProject', () {
    test('POSTs JSON with the token and returns the created project', () async {
      late http.Request sent;
      final api = clientWith((request) async {
        sent = request;
        return json({
          'id': 'new-uuid',
          ...jsonDecode(request.body) as Map<String, dynamic>,
        }, 201);
      });

      final created = await api.createProject(
        const Project(
          title: 'New',
          description: 'A new project',
          techStack: 'Flutter',
          projectUrl: 'https://example.com',
        ),
        token: 'abc123',
      );

      expect(sent.method, 'POST');
      expect(sent.url.toString(), '$baseUrl/api/v1/projects/');
      expect(sent.headers['Authorization'], 'Token abc123');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), {
        'title': 'New',
        'description': 'A new project',
        'tech_stack': 'Flutter',
        'project_url': 'https://example.com',
        'project_image_url': '',
      });
      expect(created.id, 'new-uuid');
    });

    test('throws ApiException 401 when the token is rejected', () {
      final api = clientWith(
        (_) async => json({'detail': 'Invalid token.'}, 401),
      );

      expect(
        api.createProject(
          const Project(
            title: 'x',
            description: 'y',
            techStack: '',
            projectUrl: '',
          ),
          token: 'old',
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });

  group('auth', () {
    test('obtainToken sends the credentials and returns the token', () async {
      late http.Request sent;
      final api = clientWith((request) async {
        sent = request;
        return json({'token': 'abc123'}, 200);
      });

      final token = await api.obtainToken('owner', 'secret');

      expect(sent.url.toString(), '$baseUrl/api/v1/auth/token/');
      expect(jsonDecode(sent.body), {
        'username': 'owner',
        'password': 'secret',
      });
      expect(token, 'abc123');
    });

    test('obtainToken throws ApiException 400 on wrong credentials', () {
      final api = clientWith(
        (_) async => json({
          'non_field_errors': ['Unable to log in.'],
        }, 400),
      );

      expect(
        api.obtainToken('owner', 'wrong'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('logout POSTs with the token and accepts 204', () async {
      late http.Request sent;
      final api = clientWith((request) async {
        sent = request;
        return http.Response('', 204);
      });

      await api.logout(token: 'abc123');

      expect(sent.method, 'POST');
      expect(sent.url.toString(), '$baseUrl/api/v1/auth/logout/');
      expect(sent.headers['Authorization'], 'Token abc123');
    });
  });
}
