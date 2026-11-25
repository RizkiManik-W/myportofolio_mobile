import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Holds the in-memory authentication token for the current session.
///
/// Widgets that `watch` this object rebuild when the user logs in or out.
/// The token is only kept in memory, so restarting the app logs the user out.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Exchanges username + password for a token. Throws [ApiException] when
  /// the credentials are wrong, and then stays logged out.
  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  /// Revokes the token on the server, then forgets it locally.
  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // The token may already be invalid on the server (for example 401);
      // the user is logged out locally either way.
    } finally {
      // Always clear the token, even if the server request failed.
      _token = null;
      notifyListeners();
    }
  }
}
