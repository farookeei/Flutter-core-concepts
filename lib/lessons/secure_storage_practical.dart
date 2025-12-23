import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/lesson_scaffold.dart';

// -----------------------------------------------------------------------------
// 1. Service Layer: The Production Approach
// -----------------------------------------------------------------------------
// In a real app, this would be in `services/auth_storage_service.dart`.
// We inject this service into your repositories or providers.

class AuthStorageService {
  // Create storage with optimal settings for both platforms.
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // encryptedSharedPreferences: true // Deprecated in v9.0.0+.
      // The plugin now handles encryption automatically with custom ciphers.
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      // unlocked while device is unlocked, stays accessible until restart.
    ),
  );

  static const _keyJwt = 'auth_jwt_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUserEmail = 'user_email_secure';

  /// Saves the user's authentication tokens securely.
  Future<void> saveSession({
    required String jwt,
    required String refreshToken,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _keyJwt, value: jwt),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyUserEmail, value: email),
    ]);
  }

  /// Clears all session data (Logout).
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyJwt),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserEmail),
    ]);
    // Or use _storage.deleteAll() if you are sure you own all keys.
  }

  /// Reads the JWT token. Returns null if not found.
  Future<String?> getJwt() async {
    return await _storage.read(key: _keyJwt);
  }

  /// Reads the user email.
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Debug helper: Read all keys (Don't use in production UI usually)
  Future<Map<String, String>> debugReadAll() async {
    return await _storage.readAll();
  }
}

// -----------------------------------------------------------------------------
// 3. Network Layer: Using the Stored Token
// -----------------------------------------------------------------------------
// Example of an HTTP Client / Interceptor using the storage service.
class AuthenticatedHttpClient {
  final AuthStorageService _authService;

  AuthenticatedHttpClient(this._authService);

  /// Simulates a GET request to a protected endpoint.
  /// Returns a simulating "Response" as a Map.
  Future<Map<String, dynamic>> get(String endpoint) async {
    // 1. READ the token securely just before the request.
    final token = await _authService.getJwt();

    // 2. CONSTRUCT headers
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null) {
      // 3. ATTACH Authorization header
      headers['Authorization'] = 'Bearer $token';
    }

    // -- Network Simulation --
    await Future.delayed(const Duration(milliseconds: 500));

    // 4. CHECK Verification (Simulating server side check)
    if (token == null) {
      return {
        'statusCode': 401,
        'body': 'Unauthorized: No token provided.',
        'headersSent': headers,
      };
    }

    return {
      'statusCode': 200,
      'body': 'Success: Secured data for $endpoint',
      'headersSent': headers,
    };
  }
}

// -----------------------------------------------------------------------------
// 2. UI Layer: The Lesson
// -----------------------------------------------------------------------------

class SecureStorageProductionLesson extends StatelessWidget {
  const SecureStorageProductionLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Secure Storage in Production',
      overview:
          'Learn how to implement a robust, production-ready Authentication Storage Service using `flutter_secure_storage`.\n\nThis lesson covers:\n• Configuring platform-specific options (EncryptedSharedPreferences).\n• Creating a dedicated Service class.\n• detailed usage patterns for Login/Logout flows.',
      steps: const [
        StepContent(
          title: '1. Production Configuration',
          description:
              'Always enable `encryptedSharedPreferences: true` for Android. On iOS, choose the appropriate `KeychainAccessibility`.',
          codeSnippet: '''
final storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(
    // EncryptedSharedPreferences is now default/handled automatically
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);''',
        ),
        StepContent(
          title: '2. Dedicated Service Class',
          description:
              'Don\'t sprinkle `storage.write` calls throughout your UI. Encapsulate them in a Service to ensure consistency and easier testing.',
          codeSnippet: '''
class AuthStorageService {
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }
}''',
        ),
        StepContent(
          title: '3. Use in Network Interceptors',
          description:
              'In production, you don\'t manually read the token in your UI widgets. Instead, use an interceptor (like in Dio) or a custom HTTP wrapper to silently inject the token into headers.',
          codeSnippet: '''
// Inside your HTTP Client / Interceptor
final token = await _storage.read(key: 'jwt'); 
if (token != null) {
  request.headers['Authorization'] = 'Bearer \$token';
}''',
        ),
        StepContent(
          title: '4. Do Not Store Too Much',
          description:
              'Secure Storage is SLOW compared to SharedPreferences or Databases. Store ONLY sensitive secrets (Tokens, Passwords, Keys). Store generic settings (Theme, Locale) in regular SharedPreferences.',
        ),
      ],
      demo: const _SecureStorageDemo(),
    );
  }
}

class _SecureStorageDemo extends StatefulWidget {
  const _SecureStorageDemo();

  @override
  State<_SecureStorageDemo> createState() => _SecureStorageDemoState();
}

class _SecureStorageDemoState extends State<_SecureStorageDemo> {
  final _service = AuthStorageService();
  late final _httpClient = AuthenticatedHttpClient(
    _service,
  ); // Dependency Injection

  String? _displayToken;
  String? _displayEmail;
  bool _isLoading = false;
  Map<String, String> _debugData = {};
  String _apiResult = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Read real data from device secure storage
    final token = await _service.getJwt();
    final email = await _service.getUserEmail();
    final allData = await _service.debugReadAll();

    if (!mounted) return;
    setState(() {
      _displayToken = token;
      _displayEmail = email;
      _debugData = allData;
      _isLoading = false;
      _apiResult = ''; // Clear previous API result on refresh
    });
  }

  Future<void> _makeAuthenticatedCall() async {
    setState(() => _isLoading = true);

    // Use our custom client which handles the secure storage access internally
    final response = await _httpClient.get('/api/v1/user/profile');

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      final headers = response['headersSent'] as Map<String, String>;
      final authHeader = headers['Authorization'] ?? 'None';

      _apiResult =
          '''
Status: ${response['statusCode']}
Body: ${response['body']}

[Internal Headers Sent]
Authorization: $authHeader
''';
    });
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final fakeJwt =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.simulated_token_${DateTime.now().millisecondsSinceEpoch}';
    final fakeRefresh = 'def_456_refresh_secure';

    await _service.saveSession(
      jwt: fakeJwt,
      refreshToken: fakeRefresh,
      email: 'user_${DateTime.now().second}@example.com',
    );

    await _refreshData();
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    await _service.clearSession();
    await _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _displayToken != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Status Card
          Card(
            color: isLoggedIn ? Colors.green.shade50 : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    isLoggedIn ? Icons.lock_open : Icons.lock,
                    size: 48,
                    color: isLoggedIn ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLoggedIn ? 'Authenticated' : 'Logged Out',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (isLoggedIn) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email (Secure)'),
                      subtitle: Text(_displayEmail ?? 'Unknown'),
                      dense: true,
                    ),
                    ListTile(
                      leading: const Icon(Icons.key),
                      title: const Text('JWT (Secure)'),
                      subtitle: Text(
                        _displayToken ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      dense: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Actions
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoggedIn ? null : _login,
                    icon: const Icon(Icons.login),
                    label: const Text('Simulate Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoggedIn ? _logout : null,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout (Clear)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),

          // 3. API Simulation
          const SizedBox(height: 24),
          const Text(
            'Production Usage Simulation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Simulate Fetching User Profile'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _makeAuthenticatedCall,
                    icon: const Icon(Icons.cloud_sync),
                    label: const Text('Call API (GET /profile)'),
                  ),
                  if (_apiResult.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.black12,
                      child: Text(
                        _apiResult,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 4. Debug Inspection
          const SizedBox(height: 32),

          const Text(
            'Storage Inspector (Debug Only)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey),
            ),
            child: _debugData.isEmpty
                ? const Text(
                    'Storage is empty.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _debugData.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '${e.key}: ',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                ),
                              ),
                              TextSpan(
                                text: e.value,
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Note: On Android, this uses EncryptedSharedPreferences. On iOS, it uses Keychain. This is NOT saved in plain text xml/plist.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
