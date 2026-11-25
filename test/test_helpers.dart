import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

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

/// The full app wired to a fake server. Pass [token] to start logged in.
MyApp testApp({ApiClient? api, String? token}) =>
    MyApp(apiClient: api ?? fakeApi(), initialToken: token);

/// A single [page] with the same providers as the real app, for pages
/// whose drawer needs [AuthState].
Widget testPage(Widget page, {ApiClient? api, String? token}) {
  final client = api ?? fakeApi();
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: client),
      ChangeNotifierProvider<AuthState>(
        create: (_) => AuthState(client, initialToken: token),
      ),
    ],
    child: MaterialApp(home: page),
  );
}

/// The [AuthState] of the app currently on screen.
AuthState authOf(WidgetTester tester) => Provider.of<AuthState>(
  tester.element(find.byType(Navigator)),
  listen: false,
);

/// A fake Django that knows the token, logout and project endpoints.
///
/// Login works with owner / secret and returns [token]. Every request is
/// added to [requests] so tests can check what was sent.
/// [createStatus] is the status code for `POST /api/v1/projects/`.
Future<http.Response> Function(http.Request) fakeDjango({
  required List<http.Request> requests,
  String token = 'abc123',
  int createStatus = 201,
}) {
  return (request) async {
    requests.add(request);
    final path = request.url.path;
    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'owner' && body['password'] == 'secret') {
        return http.Response(jsonEncode({'token': token}), 200);
      }
      return http.Response('{}', 400);
    }
    if (path == '/api/v1/auth/logout/') {
      return http.Response('', 204);
    }
    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (createStatus != 201) return http.Response('{}', createStatus);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({...body, 'id': '99'}), 201);
    }
    return http.Response(jsonEncode(sampleProjects), 200);
  };
}
