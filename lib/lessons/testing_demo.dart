import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

class TestingLessonPage extends StatelessWidget {
  const TestingLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Testing & Quality Assurance',
      overview:
          'Testing is crucial for production apps. Flutter provides a comprehensive testing framework covering unit tests, widget tests, integration tests, and golden tests. Learn how to write maintainable, reliable tests.',
      steps: const [
        StepContent(
          title: '1. The Testing Pyramid',
          description:
              'Unit Tests (fast, many) → Widget Tests (medium speed, some) → Integration Tests (slow, few). '
              'Most of your tests should be unit tests. They test pure logic in isolation.',
        ),
        StepContent(
          title: '2. Unit Testing',
          description:
              'Unit tests verify individual functions, classes, or methods. They are fast and test business logic without UI.',
          codeSnippet: '''
test('Calculator adds numbers correctly', () {
  final calculator = Calculator();
  expect(calculator.add(2, 3), equals(5));
});''',
        ),
        StepContent(
          title: '3. Widget Testing',
          description:
              'Widget tests verify UI components. You can find widgets, simulate interactions (tap, enter text), and verify the result.',
          codeSnippet: '''
testWidgets('Counter increments', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('0'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});''',
        ),
        StepContent(
          title: '4. Mocking Dependencies',
          description:
              'Use mockito or mocktail to create fake versions of classes for testing. This isolates the code under test.',
          codeSnippet: '''
class MockApi extends Mock implements ApiService {}

test('Login calls API', () async {
  final mockApi = MockApi();
  when(() => mockApi.login(any(), any()))
    .thenAnswer((_) async => User());
  // Test your code with mockApi
});''',
        ),
        StepContent(
          title: '5. Golden Tests',
          description:
              'Golden tests capture screenshots of widgets and compare them to reference images. Perfect for catching visual regressions.',
          codeSnippet: '''
testWidgets('Button golden test', (tester) async {
  await tester.pumpWidget(MyButton());
  await expectLater(
    find.byType(MyButton),
    matchesGoldenFile('button.png'),
  );
});''',
        ),
        StepContent(
          title: '6. Integration Testing',
          description:
              'Integration tests run the full app and test complete user flows. They are slower but catch real-world issues.',
          codeSnippet: '''
void main() {
  IntegrationTestWidgetsFlutterBinding
    .ensureInitialized();
  
  testWidgets('Complete login flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    // Test full flow
  });
}''',
        ),
        StepContent(
          title: '7. Code Coverage',
          description:
              'Measure what percentage of your code is tested. Run: flutter test --coverage',
        ),
      ],
      demo: const TestingInteractiveDemo(),
    );
  }
}

class TestingInteractiveDemo extends StatefulWidget {
  const TestingInteractiveDemo({super.key});

  @override
  State<TestingInteractiveDemo> createState() => _TestingInteractiveDemoState();
}

class _TestingInteractiveDemoState extends State<TestingInteractiveDemo> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade100,
      child: Row(
        children: [
          _buildTab('Unit', 0),
          _buildTab('Widget', 1),
          _buildTab('Mock', 2),
          _buildTab('Coverage', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const _UnitTestExample();
      case 1:
        return const _WidgetTestExample();
      case 2:
        return const _MockExample();
      case 3:
        return const _CoverageExample();
      default:
        return const SizedBox();
    }
  }
}

// =============================================================================
// UNIT TEST EXAMPLE
// =============================================================================

class _UnitTestExample extends StatefulWidget {
  const _UnitTestExample();

  @override
  State<_UnitTestExample> createState() => _UnitTestExampleState();
}

class _UnitTestExampleState extends State<_UnitTestExample> {
  final _numController1 = TextEditingController(text: '5');
  final _numController2 = TextEditingController(text: '3');
  String _result = '';
  final _calculator = Calculator();

  void _runTest() {
    setState(() {
      final a = int.tryParse(_numController1.text) ?? 0;
      final b = int.tryParse(_numController2.text) ?? 0;

      final addResult = _calculator.add(a, b);
      final multiplyResult = _calculator.multiply(a, b);
      final divideResult = _calculator.divide(a, b);

      _result =
          '''
✅ Unit Tests Passed:

test('add $a + $b') → Expected: ${a + b}, Got: $addResult ${addResult == a + b ? '✓' : '✗'}
test('multiply $a × $b') → Expected: ${a * b}, Got: $multiplyResult ${multiplyResult == a * b ? '✓' : '✗'}
test('divide $a ÷ $b') → Expected: ${b != 0 ? a / b : 'Error'}, Got: ${divideResult ?? 'Error'} ${(b != 0 && divideResult == a / b) || (b == 0 && divideResult == null) ? '✓' : '✗'}

Class Under Test: Calculator
Test Framework: flutter_test
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoCard(
          title: 'Unit Testing',
          subtitle: 'Testing pure business logic',
          icon: Icons.functions,
        ),
        const SizedBox(height: 16),
        const Text(
          'Calculator Class',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''class Calculator {
  int add(int a, int b) => a + b;
  int multiply(int a, int b) => a * b;
  double? divide(int a, int b) {
    if (b == 0) return null;
    return a / b;
  }
}''',
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.lightGreenAccent,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _numController1,
                decoration: const InputDecoration(
                  labelText: 'Number A',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _numController2,
                decoration: const InputDecoration(
                  labelText: 'Number B',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _runTest,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Run Unit Tests'),
        ),
        if (_result.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _result,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}

// Calculator class for testing
class Calculator {
  int add(int a, int b) => a + b;
  int multiply(int a, int b) => a * b;
  double? divide(int a, int b) {
    if (b == 0) return null;
    return a / b;
  }
}

// =============================================================================
// WIDGET TEST EXAMPLE
// =============================================================================

class _WidgetTestExample extends StatelessWidget {
  const _WidgetTestExample();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoCard(
          title: 'Widget Testing',
          subtitle: 'Testing UI components',
          icon: Icons.widgets,
        ),
        const SizedBox(height: 16),
        const Text(
          'Testable Counter Widget',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(padding: EdgeInsets.all(16), child: _CounterWidget()),
        ),
        const SizedBox(height: 24),
        const Text(
          'Widget Test Code',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''testWidgets('Counter increments', (tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(home: CounterWidget())
  );
  
  // Assert initial state
  expect(find.text('0'), findsOneWidget);
  expect(find.text('1'), findsNothing);
  
  // Act
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  
  // Assert
  expect(find.text('1'), findsOneWidget);
  expect(find.text('0'), findsNothing);
});''',
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.lightGreenAccent,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTip(
          'Key Finders',
          '• find.text("Hello")\n'
              '• find.byType(MyWidget)\n'
              '• find.byIcon(Icons.add)\n'
              '• find.byKey(Key("myKey"))',
        ),
        const SizedBox(height: 12),
        _buildTip(
          'Common Actions',
          '• await tester.tap(finder)\n'
              '• await tester.enterText(finder, "text")\n'
              '• await tester.drag(finder, offset)\n'
              '• await tester.pump() // Rebuild widget',
        ),
      ],
    );
  }

  Widget _buildTip(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CounterWidget extends StatefulWidget {
  const _CounterWidget();

  @override
  State<_CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<_CounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$_counter',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: () => setState(() => _counter--),
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              onPressed: () => setState(() => _counter++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// MOCK EXAMPLE
// =============================================================================

class _MockExample extends StatefulWidget {
  const _MockExample();

  @override
  State<_MockExample> createState() => _MockExampleState();
}

class _MockExampleState extends State<_MockExample> {
  String _testResult = '';
  bool _isLoading = false;

  Future<void> _runMockTest() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate a test with a mock
    final mockResult = '''
✅ Mock Test Passed:

Test: UserRepository fetches user data

1. Created MockApiService
2. Configured mock response:
   when(mockApi.getUser(123))
     .thenAnswer((_) async => User(id: 123, name: "John"))

3. injected mock into UserRepository
4. Called repository.fetchUser(123)
5. Verified mock was called once
6. Verified correct user returned

Result: ✓ PASS
Mock verified: getUser(123) called 1 time
''';

    setState(() {
      _testResult = mockResult;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoCard(
          title: 'Mocking',
          subtitle: 'Isolating code with fake dependencies',
          icon: Icons.swap_horiz,
        ),
        const SizedBox(height: 16),
        const Text(
          'Why Mock?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildReason('🚀 Speed', 'No real network calls or database queries'),
        _buildReason('🎯 Isolation', 'Test only the code you care about'),
        _buildReason('🔧 Control', 'Simulate errors, edge cases easily'),
        const SizedBox(height: 24),
        const Text(
          'Mock Example',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''// Using Mocktail
class MockApiService extends Mock 
    implements ApiService {}

test('Repository handles errors', () async {
  final mockApi = MockApiService();
  
  // Simulate error
  when(() => mockApi.getUser(any()))
    .thenThrow(Exception('Network error'));
  
  final repo = UserRepository(mockApi);
  
  expect(
    () => repo.fetchUser(123),
    throwsException,
  );
  
  verify(() => mockApi.getUser(123))
    .called(1);
});''',
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.lightGreenAccent,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _runMockTest,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
          label: const Text('Run Mock Test'),
        ),
        if (_testResult.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _testResult,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReason(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// =============================================================================
// COVERAGE EXAMPLE
// =============================================================================

class _CoverageExample extends StatelessWidget {
  const _CoverageExample();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoCard(
          title: 'Code Coverage',
          subtitle: 'Measuring test completeness',
          icon: Icons.assessment,
        ),
        const SizedBox(height: 16),
        const Text(
          'What is Code Coverage?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Code coverage measures what percentage of your code is executed during tests. '
          'It helps identify untested code paths.',
        ),
        const SizedBox(height: 24),
        const Text(
          'Running Coverage',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildCommand('flutter test --coverage'),
        const SizedBox(height: 8),
        const Text(
          'This generates coverage/lcov.info file',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sample Coverage Report',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildCoverageBar('calculator.dart', 0.95),
        _buildCoverageBar('user_repository.dart', 0.78),
        _buildCoverageBar('api_service.dart', 0.62),
        _buildCoverageBar('utils.dart', 0.45),
        const SizedBox(height: 16),
        _buildCoverageBar('Overall Coverage', 0.70, isTotal: true),
        const SizedBox(height: 24),
        _buildTip(
          '💡 Coverage Guidelines',
          '• Aim for 80%+ in production apps\n'
              '• 100% is unrealistic (UI code, etc.)\n'
              '• Focus on critical business logic\n'
              '• Don\'t game the system - quality > quantity',
        ),
        const SizedBox(height: 16),
        _buildTip(
          '📊 Viewing HTML Reports',
          '# Install lcov (macOS)\nbrew install lcov\n\n'
              '# Generate HTML\ngenhtml coverage/lcov.info -o coverage/html\n\n'
              '# Open in browser\nopen coverage/html/index.html',
        ),
      ],
    );
  }

  Widget _buildCommand(String command) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text(
            '\$ ',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            command,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageBar(
    String filename,
    double coverage, {
    bool isTotal = false,
  }) {
    final percentage = (coverage * 100).toInt();
    final color = coverage >= 0.8
        ? Colors.green
        : coverage >= 0.6
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                filename,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 16 : 14,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: isTotal ? 16 : 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: coverage,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: isTotal ? 12 : 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue.shade700),
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
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.blue.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
