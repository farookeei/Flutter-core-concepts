import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

class SecurityLessonPage extends StatelessWidget {
  const SecurityLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Security Best Practices',
      overview:
          'Security is critical for production apps. Flutter apps are not secure by default against reverse engineering or data theft. This module covers essential defense strategies.',
      steps: const [
        StepContent(
          title: '1. Code Obfuscation',
          description:
              'Obfuscation makes your compiled Dart code hard for humans to understand. It hides function names, class names, and file paths in release builds.',
          codeSnippet:
              'flutter build apk --obfuscate --split-debug-info=/<path>',
        ),
        StepContent(
          title: '2. Secure Storage',
          description:
              'Never store sensitive data (tokens, passwords) in SharedPreferences or local databases in plain text. Use platform-specific secure encryption (Keychain on iOS, Keystore on Android).',
          codeSnippet:
              'final storage = FlutterSecureStorage();\nawait storage.write(key: "jwt", value: "token");',
        ),
        StepContent(
          title: '3. API Key Protection',
          description:
              'Do not hardcode API keys in your code. They can be extracted by decompiling the app. Use environment variables or compile-time configurations.',
          codeSnippet: 'const apiKey = String.fromEnvironment("API_KEY");',
        ),
        StepContent(
          title: '4. SSL Pinning',
          description:
              'Prevents Man-in-the-Middle (MITM) attacks by hardcoding the expected server certificate or public key hash in the app. This ensures the app only talks to your legitimate server.',
        ),
        StepContent(
          title: '5. Root/Jailbreak Detection',
          description:
              'Compromised devices bypass OS security features. Using packages like `flutter_jailbreak_detection` can help restrict app functionality on such devices.',
        ),
      ],
      demo: const SecurityInteractiveDemo(),
    );
  }
}

class SecurityInteractiveDemo extends StatefulWidget {
  const SecurityInteractiveDemo({super.key});

  @override
  State<SecurityInteractiveDemo> createState() =>
      _SecurityInteractiveDemoState();
}

class _SecurityInteractiveDemoState extends State<SecurityInteractiveDemo> {
  // Demo State
  final _textController = TextEditingController();
  String _savedValue = 'No value saved';
  bool _isSecureStorage = true;
  bool _isObfuscated = false; // Simulated state

  void _saveData() {
    final value = _textController.text;
    if (value.isEmpty) return;

    setState(() {
      // Simulation of what happens
      if (_isSecureStorage) {
        _savedValue = 'Encrypted(***${value.hashCode}***)';
      } else {
        _savedValue = value; // Plain text
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSecureStorage
              ? 'Saved to Secure Storage (Keychain/Keystore)'
              : 'Saved to SharedPreferences (Plain XML/PLIST)',
        ),
        backgroundColor: _isSecureStorage ? Colors.green : Colors.orange,
      ),
    );
  }

  void _simulateAttack() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hacker View 🕵️‍♂️'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attemping to read local storage file...'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black87,
              width: double.infinity,
              child: Text(
                _isSecureStorage
                    ? 'Error: Data is encrypted. Cannot read without key.'
                    : '<string name="user_secret">$_savedValue</string>',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!_isSecureStorage)
              const Text(
                '⚠️ DATA LEAKED! Plain text storage is unsafe.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                '✅ DATA SECURE. OS-level encryption protected the secret.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SecurityInfoCard(
          title: 'Storage Simulation',
          content:
              'Enter a secret (like a password) and see how it looks to a hacker based on your storage choice.',
          icon: Icons.lock,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '1. Choose Storage Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: const Text('Use Secure Storage'),
                  subtitle: const Text('Encrypts data using OS Keystore'),
                  value: _isSecureStorage,
                  onChanged: (val) => setState(() {
                    _isSecureStorage = val;
                    _savedValue = 'No value saved';
                  }),
                ),
                const SizedBox(height: 16),
                const Text(
                  '2. Enter Secret Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Secret (e.g., API Key, Password)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _saveData,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Data'),
                ),
                const Divider(height: 32),
                const Text(
                  '3. Simulate Hack',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _simulateAttack,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('View Application Files (Root Access)'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _SecurityInfoCard(
          title: 'Obfuscation Check',
          content:
              'In a real release build with obfuscation, stack traces are unreadable. In debug mode, they are clear.',
          icon: Icons.visibility_off,
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Stack Trace Simulation'),
            subtitle: Text(
              _isObfuscated
                  ? 'Function names hidden: a.b.c() -> void'
                  : 'Function names visible: _SecurityInteractiveDemoState._saveData()',
            ),
            trailing: Switch(
              value: _isObfuscated,
              onChanged: (val) => setState(() => _isObfuscated = val),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _SecurityInfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blueGrey.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
