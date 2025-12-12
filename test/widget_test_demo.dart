import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// WIDGET TEST EXAMPLES
// These demonstrate testing UI components and interactions
// =============================================================================

void main() {
  group('Counter Widget', () {
    testWidgets('displays initial count of 0', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('increments count when add button is tapped', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('decrements count when remove button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CounterWidget()));

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('-1'), findsOneWidget);
    });
  });

  group('Login Form', () {
    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginForm()));

      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginForm()));

      await tester.enterText(find.byKey(const Key('email_field')), 'invalid');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('calls onLogin when form is valid', (tester) async {
      bool loginCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoginForm(
            onLogin: (email, password) {
              loginCalled = true;
            },
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(loginCalled, isTrue);
    });
  });
}

// =============================================================================
// WIDGETS UNDER TEST
// =============================================================================

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_counter', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => _counter--),
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: () => setState(() => _counter++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final Function(String email, String password)? onLogin;

  const LoginForm({super.key, this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                key: const Key('email_field'),
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('password_field'),
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onLogin?.call(
                      _emailController.text,
                      _passwordController.text,
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
