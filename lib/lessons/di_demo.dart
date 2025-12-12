import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

// =============================================================================
// 1. DOMAIN LAYER (Interfaces & Pure Logic)
// =============================================================================

/// The interface that our app depends on.
/// The app doesn't care HOW the notification is sent, only that it IS sent.
abstract class NotificationService {
  String sendNotification(String message);
  String get serviceName;
}

// =============================================================================
// 2. INFRASTRUCTURE LAYER (Concrete Implementations)
// =============================================================================

class EmailNotificationService implements NotificationService {
  @override
  String get serviceName => "Email Service";

  @override
  String sendNotification(String message) {
    // In a real app, this would connect to an SMTP server.
    return "📧 Email sent: $message";
  }
}

class SmsNotificationService implements NotificationService {
  @override
  String get serviceName => "SMS Service";

  @override
  String sendNotification(String message) {
    // In a real app, this would hit a Twilio API or similar.
    return "📱 SMS sent: $message";
  }
}

class MockNotificationService implements NotificationService {
  @override
  String get serviceName => "Mock (Test) Service";

  @override
  String sendNotification(String message) {
    // For testing, just log it. Cost-free and fast.
    return "🐛 Mock log: $message";
  }
}

// =============================================================================
// 3. SERVICE LOCATOR (The DI Container)
// =============================================================================

/// A simple, manual implementation of a Service Locator.
/// Libraries like `get_it` do exactly this, just with more features.
class MyServiceLocator {
  // Singleton instance
  static final MyServiceLocator _instance = MyServiceLocator._internal();
  factory MyServiceLocator() => _instance;
  MyServiceLocator._internal();

  // Storage for our registered services.
  // We key them by Type so we can request `get<NotificationService>()`.
  final Map<Type, dynamic> _services = {};

  /// Register a singleton instance of a service.
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Retrieve a registered service.
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception(
        "Service of type $T not found! Did you forget to register it?",
      );
    }
    return service;
  }

  /// Check if a service is registered (helper for UI).
  bool isRegistered<T>() => _services.containsKey(T);

  /// Clear all services (for demo reset purposes).
  void reset() => _services.clear();
}

// =============================================================================
// 4. CLIENT LAYER (The App Logic that uses the Service)
// =============================================================================

class UserRegistrationBackend {
  // The backend doesn't know about Email/SMS/Mock. It only knows `NotificationService`.
  // It asks the ServiceLocator for whatever implementation is currently active.
  String registerUser(String username) {
    try {
      final notificationService = MyServiceLocator().get<NotificationService>();
      return notificationService.sendNotification("Welcome, $username!");
    } catch (e) {
      return "❌ Error: ${e.toString()}";
    }
  }
}

// =============================================================================
// 5. FLUTTER UI (The Lesson & Demo)
// =============================================================================

class DiLessonPage extends StatelessWidget {
  const DiLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Dependency Injection',
      overview:
          'Dependency Injection (DI) is about decoupling your code. Instead of classes creating their own dependencies, they are provided (injected) from the outside.',
      steps: const [
        StepContent(
          title: '1. The Problem: Tight Coupling',
          description:
              'If Class A creates `new Class B()` inside itself, it is tightly coupled. You cannot easily swap Class B for a mock version during testing, or change it to Class C without rewriting Class A.',
          codeSnippet: '''
class UserManager {
  // ❌ Tightly coupled!
  final api = EmailApi(); 
}''',
        ),
        StepContent(
          title: '2. The Solution: Inversion of Control',
          description:
              'We "invert control" by letting someone else provide the dependency. This is usually done via the constructor.',
          codeSnippet: '''
class UserManager {
  final NotificationService service;
  
  // ✅ Constructor Injection
  UserManager(this.service);
}''',
        ),
        StepContent(
          title: '3. Service Locators (GetIt)',
          description:
              'In Flutter, passing dependencies deeply through the widget tree can be messy. A "Service Locator" is a registry where you look up dependencies when needed. Pass the locator or use it globally.',
          codeSnippet: '''
// Register once at startup
locator.register<Api>(RealApi());

// Use anywhere
final api = locator.get<Api>();
''',
        ),
      ],
      demo: const DiInteractiveDemo(),
    );
  }
}

class DiInteractiveDemo extends StatefulWidget {
  const DiInteractiveDemo({super.key});

  @override
  State<DiInteractiveDemo> createState() => _DiInteractiveDemoState();
}

class _DiInteractiveDemoState extends State<DiInteractiveDemo> {
  final locator = MyServiceLocator();
  final backend = UserRegistrationBackend();
  String _log = "System waiting...\nRegister a service to begin.";
  String? _activeServiceName;

  // Setup initial state (optional, can start empty)
  @override
  void initState() {
    super.initState();
    _resetLocator();
  }

  void _resetLocator() {
    locator.reset();
    setState(() {
      _activeServiceName = null;
      _log = "System reset. No services registered.";
    });
  }

  void _registerService(NotificationService service) {
    locator.register<NotificationService>(service);
    setState(() {
      _activeServiceName = service.serviceName;
      _log =
          "✅ Registered: ${service.serviceName}\n\nReady to simulate registration.";
    });
  }

  void _simulateUserRegistration() {
    final result = backend.registerUser("User123");
    setState(() {
      _log += "\n\n> Registration Attempt:\n$result";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "1. Choose Your Infrastructure",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              "Imagine this is your App's `main()` function configuration.",
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ServiceOption(
                  label: "PROD: Email",
                  icon: Icons.email,
                  isSelected: _activeServiceName == "Email Service",
                  onTap: () => _registerService(EmailNotificationService()),
                ),
                _ServiceOption(
                  label: "PROD: SMS",
                  icon: Icons.sms,
                  isSelected: _activeServiceName == "SMS Service",
                  onTap: () => _registerService(SmsNotificationService()),
                ),
                _ServiceOption(
                  label: "TEST: Mock",
                  icon: Icons.bug_report,
                  isSelected: _activeServiceName == "Mock (Test) Service",
                  onTap: () => _registerService(MockNotificationService()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "2. Run Business Logic",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              "The code here doesn't change, but behaves differently based on above choice.",
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _simulateUserRegistration,
              icon: const Icon(Icons.person_add),
              label: const Text("Simulate 'Register User'"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "System Output:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _resetLocator,
                  child: const Text("Reset System"),
                ),
              ],
            ),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  _log,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.greenAccent,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurple : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.deepPurple : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
