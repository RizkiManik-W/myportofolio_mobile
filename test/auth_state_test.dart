import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'test_helpers.dart';

void main() {
  group('AuthState', () {
    test('starts logged out', () {
      final auth = AuthState(fakeApi());
      expect(auth.isLoggedIn, isFalse);
      expect(auth.token, isNull);
    });

    test('login stores the token and notifies listeners', () async {
      final auth = AuthState(
        fakeApi(
          handler: (_) async =>
              http.Response(jsonEncode({'token': 'abc123'}), 200),
        ),
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.login('owner', 'secret');

      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, 'abc123');
      expect(notified, 1);
    });

    test('wrong credentials throw and stay logged out', () async {
      final auth = AuthState(
        fakeApi(handler: (_) async => http.Response('{}', 400)),
      );

      await expectLater(
        auth.login('owner', 'wrong'),
        throwsA(isA<ApiException>()),
      );
      expect(auth.isLoggedIn, isFalse);
    });

    test('logout revokes the token on the server and clears it', () async {
      final requests = <http.Request>[];
      final auth = AuthState(
        fakeApi(
          handler: (request) async {
            requests.add(request);
            return http.Response('', 204);
          },
        ),
        initialToken: 'abc123',
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.logout();

      expect(requests.single.url.path, '/api/v1/auth/logout/');
      expect(requests.single.headers['Authorization'], 'Token abc123');
      expect(auth.isLoggedIn, isFalse);
      expect(notified, 1);
    });

    test('logout still clears the token when the server fails', () async {
      final auth = AuthState(
        fakeApi(handler: (_) async => http.Response('expired', 401)),
        initialToken: 'old',
      );

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
    });

    test('logout when already logged out does nothing', () async {
      var calls = 0;
      final auth = AuthState(
        fakeApi(
          handler: (_) async {
            calls++;
            return http.Response('', 204);
          },
        ),
      );

      await auth.logout();

      expect(calls, 0);
    });
  });
}
