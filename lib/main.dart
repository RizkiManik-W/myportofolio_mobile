import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, this.initialToken, super.key});

  /// Shared HTTP client; tests pass one backed by a fake server.
  final ApiClient apiClient;

  /// Lets tests start already logged in. The real app starts logged out.
  final String? initialToken;

  @override
  Widget build(BuildContext context) {
    // MultiProvider puts shared objects (like ApiClient) into the widget tree,
    // so any screen can read them with context.read<ApiClient>().
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        // ChangeNotifierProvider rebuilds widgets that watch AuthState
        // whenever login or logout calls notifyListeners().
        ChangeNotifierProvider<AuthState>(
          create: (_) => AuthState(apiClient, initialToken: initialToken),
        ),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            secondary: Colors.amber[700],
          ),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
