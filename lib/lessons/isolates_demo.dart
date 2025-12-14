import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';
import 'isolates_image_demo.dart';

class IsolatesLessonPage extends StatelessWidget {
  const IsolatesLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Isolates & Concurrency',
      overview:
          'Dart is single-threaded by default. This means heavy calculations can freeze your UI. "Isolates" are Dart\'s way of doing multi-threading. They do not share memory; they pass messages.',
      steps: const [
        StepContent(
          title: '1. Main Thread vs Isolates',
          description:
              'The Main Isolate handles the UI and Event Loop (touches, drawing, timers). If you block it with a loop, the app "janks".',
        ),
        StepContent(
          title: '2. compute()',
          description:
              'The simplest way to run code in the background. It spawns a worker, runs a function, returns the result, and kills the worker automatically.',
          codeSnippet: 'await compute(heavyFunction, args);',
        ),
        StepContent(
          title: '3. Long-Lived Isolates',
          description:
              'For frequent background tasks, spawning/killing is expensive. Instead, spawn an isolate once and establish a 2-way "SendPort" communication.',
          codeSnippet: 'Isolate.spawn(entryPoint, receivePort.sendPort);',
        ),
      ],
      demo: const IsolatesInteractiveDemo(),
    );
  }
}

class IsolatesInteractiveDemo extends StatelessWidget {
  const IsolatesInteractiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // This was formerly the HomeScreen body
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoCard(
          title: 'Welcome!',
          content:
              'Explore the topics below to understand the Main Thread, Event Loop, and how to use Isolates to keep your UI buttery smooth.',
          icon: Icons.school,
        ),
        const SizedBox(height: 24),
        _TopicCard(
          title: '1. The Main Thread',
          subtitle: 'Why heavy tasks freeze your UI',
          icon: Icons.block,
          color: Colors.red.shade100,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MainThreadDemoScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _TopicCard(
          title: '2. Short Tasks (compute)',
          subtitle: 'Offloading one-off calculations',
          icon: Icons.bolt,
          color: Colors.orange.shade100,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComputeDemoScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _TopicCard(
          title: '3. Background Workers',
          subtitle: 'Long-lived isolates with 2-way communication',
          icon: Icons.sync_alt,
          color: Colors.green.shade100,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SpawnDemoScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _TopicCard(
          title: '4. Best Practices',
          subtitle: 'When to use what?',
          icon: Icons.thumb_up,
          color: Colors.blue.shade100,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BestPracticesScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _TopicCard(
          title: '5. Native vs Flutter',
          subtitle: 'Why is Dart "Single Threaded"?',
          icon: Icons.compare_arrows,
          color: Colors.purple.shade100,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NativeComparisonScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _TopicCard(
          title: '6. Real World Example',
          subtitle: 'Image Processing (Heavy CPU)',
          icon: Icons.image,
          color: Colors.pink.shade100,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ImageProcessingIsolateDemo(),
            ),
          ),
        ),
      ],
    );
  }
}

// ... existing code ...

// =============================================================================
// TOPIC 5: NATIVE VS FLUTTER (THEORY)
// =============================================================================

class NativeComparisonScreen extends StatelessWidget {
  const NativeComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native vs Flutter Concurrency')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ExplanationBox(
            title: 'Is Dart really "Single Threaded"?',
            text:
                'Think of it as two layers:\\n'
                '1. **My Code (Dart)**: Runs on a SINGLE thread (The Main UI Thread). If this handles a heavy loop, the app freezes.\\n'
                '2. **The Engine (C++)**: Runs on MULTIPLE threads managed by Flutter. It handles the heavy lifting (Rasterizing pixels, Network I/O) in the background.\\n\\n'
                'This is why network calls don\'t block (Engine handles them), but heavy math loops DO block (Dart handles them).',
          ),
          const SizedBox(height: 16),
          const _SectionHeader('1. Android (Java/Kotlin)'),
          const _ComparisonCard(
            title: 'Shared Memory Model',
            description:
                'In native Android, you can spawn multiple threads that all access the same variables (Shared Memory). '
                'This is powerful but dangerous. You need "Locks" and "Synchronized" blocks to prevent race conditions.',
            icon: Icons.android,
            color: Colors.green,
            pros: [
              'True parallel execution on same memory',
              'Fine-grained control',
            ],
            cons: [
              'Race conditons (bugs)',
              'Deadlocks',
              'Complex synchronization',
            ],
          ),
          const SizedBox(height: 16),
          const _SectionHeader('2. iOS (Swift/Obj-C)'),
          const _ComparisonCard(
            title: 'GCD \u0026 Main Queue',
            description:
                'iOS uses Grand Central Dispatch (GCD). You dispatch blocks of code to different queues (Main, Background, etc). '
                'Like Android, memory is shared. You must ensure you only touch UI on the Main Queue, or the app crashes.',
            icon: Icons.apple,
            color: Colors.grey,
            pros: [
              'Highly optimized OS scheduling',
              'Grand Central Dispatch is robust',
            ],
            cons: [
              'Memory safety issues',
              'UI updates from background crash app',
            ],
          ),
          const SizedBox(height: 16),
          const _SectionHeader('3. Flutter (Isolates)'),
          const _ComparisonCard(
            title: 'Message Passing Model',
            description:
                'Dart Isolates do NOT share memory. They are like separate "processes" that talk via messages (Ports). '
                'This means you cannot accidentally crash the UI from a background thread because you literally cannot access the UI memory from there.',
            icon: Icons.flutter_dash,
            color: Colors.blue,
            pros: [
              'No race conditions on variables',
              'No explicit locking needed',
              'Garbage Collection is isolated (smoother)',
            ],
            cons: [
              'Message passing has overhead (copying data)',
              'Cannot share large objects easily (requires TransferableTypedData)',
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> pros;
  final List<String> cons;

  const _ComparisonCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.pros,
    required this.cons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const Divider(height: 24),
            const Text(
              'Pros:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            ...pros.map(
              (p) => Text('• $p', style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cons:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            ...cons.map(
              (c) => Text('• $c', style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TOPIC 1: THE MAIN THREAD (BLOCKING DEMO)
// =============================================================================

class MainThreadDemoScreen extends StatefulWidget {
  const MainThreadDemoScreen({super.key});

  @override
  State<MainThreadDemoScreen> createState() => _MainThreadDemoScreenState();
}

class _MainThreadDemoScreenState extends State<MainThreadDemoScreen> {
  String _status = 'Idle';
  int? _result;

  int _heavyTask(int iterations) {
    int sum = 0;
    for (int i = 0; i < iterations; i++) {
      sum += i;
      sqrt(i * i + sum);
    }
    return sum;
  }

  void _runTaskOnMainThread() {
    setState(() {
      _status = 'Running heavy task... (Watch the spinner freeze!)';
      _result = null;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      final stopwatch = Stopwatch()..start();
      final result = _heavyTask(500000000);
      stopwatch.stop();
      setState(() {
        _status = 'Done in ${stopwatch.elapsedMilliseconds}ms';
        _result = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Main Thread')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ExplanationBox(
              title: 'The "Jank" Problem',
              text:
                  'Dart is single-threaded. Your code runs in an "Isolate" (usually the Main Isolate). '
                  'The Main Isolate also handles drawing the UI.\n\n'
                  'If you run a heavy calculation here, the Event Loop gets stuck. '
                  'It cannot process touch events or repaint the screen. The app freezes.',
            ),
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'I am the UI thread.\nIf I stop spinning, the app is frozen!',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const Spacer(),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade50,
                child: Text('Result: $_result', textAlign: TextAlign.center),
              ),
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _status.startsWith('Running')
                  ? null
                  : _runTaskOnMainThread,
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('BLOCK THE UI (Run on Main Thread)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TOPIC 2: COMPUTE (SHORT TASKS)
// =============================================================================

class ComputeDemoScreen extends StatefulWidget {
  const ComputeDemoScreen({super.key});

  @override
  State<ComputeDemoScreen> createState() => _ComputeDemoScreenState();
}

class _ComputeDemoScreenState extends State<ComputeDemoScreen> {
  String _status = 'Idle';
  int? _result;

  static int _heavyTaskStatic(int iterations) {
    int sum = 0;
    for (int i = 0; i < iterations; i++) {
      sum += i;
      sqrt(i * i + sum);
    }
    return sum;
  }

  Future<void> _runTaskWithCompute() async {
    setState(() {
      _status = 'Spawning isolate via compute()...';
      _result = null;
    });

    final stopwatch = Stopwatch()..start();
    final result = await compute(_heavyTaskStatic, 500000000);

    stopwatch.stop();
    setState(() {
      _status =
          'Done in ${stopwatch.elapsedMilliseconds}ms (UI stayed smooth!)';
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Using compute()')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ExplanationBox(
              title: 'The Solution: compute()',
              text:
                  '`compute()` is a helper function provided by Flutter. '
                  'It spawns a NEW Isolate, runs your function on it, returns the result, and then kills the Isolate.\n\n'
                  'Perfect for one-off heavy tasks like parsing large JSON or image processing.',
            ),
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Watch me spin smoothly while the math happens!',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const Spacer(),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.green.shade50,
                child: Text('Result: $_result', textAlign: TextAlign.center),
              ),
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _status.startsWith('Spawning')
                  ? null
                  : _runTaskWithCompute,
              icon: const Icon(Icons.bolt),
              label: const Text('Run in Background (compute)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TOPIC 3: LONG-LIVED ISOLATES (SPAWN)
// =============================================================================

class SpawnDemoScreen extends StatefulWidget {
  const SpawnDemoScreen({super.key});

  @override
  State<SpawnDemoScreen> createState() => _SpawnDemoScreenState();
}

class _SpawnDemoScreenState extends State<SpawnDemoScreen> {
  Isolate? _workerIsolate;
  SendPort? _sendPortToWorker;
  StreamSubscription? _receiveSubscription;

  final List<String> _logs = [];
  bool _isReady = false;

  @override
  void dispose() {
    _killWorker();
    super.dispose();
  }

  Future<void> _spawnWorker() async {
    if (_workerIsolate != null) return;

    setState(() {
      _logs.add('🚀 Spawning worker isolate...');
    });

    final receivePort = ReceivePort();
    _workerIsolate = await Isolate.spawn(
      _workerEntrypoint,
      receivePort.sendPort,
    );

    _receiveSubscription = receivePort.listen((message) {
      if (message is SendPort) {
        setState(() {
          _sendPortToWorker = message;
          _isReady = true;
          _logs.add('✅ Worker ready! Handshake complete.');
        });
      } else {
        setState(() {
          _logs.add('📩 Received: $message');
        });
      }
    });
  }

  static void _workerEntrypoint(SendPort sendPortToMain) {
    final workerReceivePort = ReceivePort();
    sendPortToMain.send(workerReceivePort.sendPort);

    workerReceivePort.listen((message) {
      if (message == 'ping') {
        sleep(const Duration(milliseconds: 500));
        sendPortToMain.send('pong (processed in background)');
      } else if (message is String && message.startsWith('calc')) {
        final num = int.tryParse(message.split(':')[1]) ?? 0;
        final result = num * 2;
        sendPortToMain.send('Result: $result');
      } else {
        sendPortToMain.send('Echo: $message');
      }
    });
  }

  void _sendMessage(String msg) {
    if (_sendPortToWorker == null) return;
    setState(() => _logs.add('📤 Sending: $msg'));
    _sendPortToWorker!.send(msg);
  }

  void _killWorker() {
    if (_workerIsolate != null) {
      _workerIsolate!.kill(priority: Isolate.immediate);
      _workerIsolate = null;
      _sendPortToWorker = null;
      _receiveSubscription?.cancel();
      setState(() {
        _isReady = false;
        _logs.add('💀 Worker killed.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Background Workers')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: _ExplanationBox(
              title: 'Long-lived Isolates',
              text:
                  'For ongoing tasks (like a chat socket, audio processing, or complex state management), '
                  'you don\'t want to spawn/kill isolates constantly (overhead).\n\n'
                  'Instead, spawn once, establish a 2-way communication channel (Ports), and keep it alive.\n\n'
                  'Also known as the "Worker Manager" pattern. You treat the isolate as a dedicated service.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isReady ? null : _spawnWorker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    ),
                    child: const Text('Spawn Worker'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isReady ? _killWorker : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: const Text('Kill Worker'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _sendMessage('ping'),
                      child: const Text('Send "ping"'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _sendMessage('calc:${Random().nextInt(100)}'),
                      child: const Text('Send "calc"'),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Communication Log:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isSend = log.startsWith('📤');
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSend ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log,
                    style: const TextStyle(fontFamily: 'Courier'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TOPIC 4: BEST PRACTICES
// =============================================================================

class BestPracticesScreen extends StatelessWidget {
  const BestPracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Best Practices')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _InfoCard(
            title: 'When to use Isolates?',
            content:
                '• JSON Parsing: If parsing > 10KB of JSON.\n'
                '• Image Processing: Resizing, cropping, filtering.\n'
                '• Encryption/Hashing: Heavy crypto operations.\n'
                '• Complex Math: Large loops, recursive algorithms.',
            icon: Icons.check_circle,
          ),
          SizedBox(height: 16),
          _InfoCard(
            title: 'When NOT to use Isolates?',
            content:
                '• Network Requests: HTTP calls are already async (I/O bound). They don\'t block the UI.\n'
                '• Database Queries: Plugins like sqflite usually run in their own threads natively.\n'
                '• Simple Logic: Spawning an isolate has overhead (memory & time). Don\'t use it for small tasks.',
            icon: Icons.cancel,
          ),
          SizedBox(height: 16),
          _InfoCard(
            title: 'Communication Cost',
            content:
                'Passing data between isolates involves copying memory (unless using transferables). '
                'Passing a huge list of objects can be slow. Pass primitive data or encoded bytes when possible.',
            icon: Icons.speed,
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _ExplanationBox extends StatelessWidget {
  final String title;
  final String text;

  const _ExplanationBox({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.indigo.shade900)),
        ],
      ),
    );
  }
}
