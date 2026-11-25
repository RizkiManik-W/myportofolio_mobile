import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Two projects returned by the fake `GET /api/v1/projects/`.
final sampleProjects = [
  {
    'id': '1',
    'title': 'MyPortfolio Web',
    'description': 'Personal portfolio built with Django',
    'tech_stack': 'Django, Tailwind',
    'project_url': 'https://example.com/web',
    'project_image_url': '',
  },
  {
    'id': '2',
    'title': 'MyPortfolio Mobile',
    'description': 'Flutter version of the portfolio',
    'tech_stack': 'Flutter',
    'project_url': 'https://example.com/mobile',
    'project_image_url': '',
  },
];

/// An [ApiClient] backed by a fake server instead of real Django.
ApiClient fakeApi({
  Future<http.Response> Function(http.Request request)? handler,
}) => ApiClient(
  baseUrl: 'http://test.local',
  client: MockClient(
    handler ??
        (request) async => http.Response(
          jsonEncode(sampleProjects),
          200,
          headers: {'content-type': 'application/json'},
        ),
  ),
);

/// The full app wired to a fake server.
MyApp testApp({ApiClient? api}) => MyApp(apiClient: api ?? fakeApi());
