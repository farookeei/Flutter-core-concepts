import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

class BackgroundProcessingLessonPage extends StatelessWidget {
  const BackgroundProcessingLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Background Processing',
      overview:
          'Learn how to run tasks when your app is in the background or closed. Master WorkManager for scheduled tasks, foreground services for long-running operations, and background isolates for heavy processing.',
      steps: const [
        StepContent(
          title: '1. Background Processing Types',
          description:
              'WorkManager: Scheduled tasks that run even when app is closed (data sync, cleanup).\n'
              'Foreground Services: Long-running tasks with user notification (music player, GPS tracking).\n'
              'Background Isolates: Heavy CPU work without blocking UI (image processing, encryption).',
        ),
        StepContent(
          title: '2. WorkManager Basics',
          description:
              'WorkManager guarantees execution. Android uses JobScheduler/AlarmManager. iOS uses BackgroundFetch. '
              'Perfect for periodic tasks (sync every 15 minutes) or one-time tasks (process upload queue).',
          codeSnippet: '''
Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: true,
);

Workmanager().registerPeriodicTask(
  "sync-data",
  "syncDataTask",
  frequency: Duration(minutes: 15),
);''',
        ),
        StepContent(
          title: '3. Callback Dispatcher',
          description:
              'Top-level function that WorkManager calls in the background. Must be top-level or static.',
          codeSnippet: '''
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, data) {
    print("Running: \$task");
    // Do background work here
    return Future.value(true);
  });
}''',
        ),
        StepContent(
          title: '4. Periodic Tasks',
          description:
              'Run repeatedly at intervals. Minimum 15 minutes. Android may delay to save battery.',
          codeSnippet: '''
registerPeriodicTask(
  "uniqueName",
  "taskName",
  frequency: Duration(minutes: 15),
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
);''',
        ),
        StepContent(
          title: '5. One-Time Tasks',
          description:
              'Run once, even if app is closed. Can be delayed. Perfect for upload queues or cleanup.',
          codeSnippet: '''
registerOneOffTask(
  "upload-task",
  "uploadTask",
  initialDelay: Duration(seconds: 10),
);''',
        ),
        StepContent(
          title: '6. Foreground Services',
          description:
              'Long-running tasks that show a notification. Android requires permission. '
              'Use for GPS tracking, music playback, file downloads.',
        ),
        StepContent(
          title: '7. Background Isolates',
          description:
              'Run heavy CPU work in separate thread without blocking UI. Different from WorkManager - runs while app is open.',
          codeSnippet: '''
final result = await compute(
  heavyFunction,
  data,
);

// Or spawn long-lived isolate
await Isolate.spawn(
  workerEntrypoint,
  sendPort,
);''',
        ),
      ],
      demo: const BackgroundProcessingDemo(),
    );
  }
}

// =============================================================================
// INTERACTIVE DEMO
// =============================================================================

class BackgroundProcessingDemo extends StatefulWidget {
  const BackgroundProcessingDemo({super.key});

  @override
  State<BackgroundProcessingDemo> createState() =>
      _BackgroundProcessingDemoState();
}

class _BackgroundProcessingDemoState extends State<BackgroundProcessingDemo> {
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
          _buildTab('WorkManager', 0),
          _buildTab('Isolates', 1),
          _buildTab('Setup', 2),
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
        return const _WorkManagerExample();
      case 1:
        return const _IsolateExample();
      case 2:
        return const _SetupInstructions();
      default:
        return const SizedBox();
    }
  }
}

// =============================================================================
// WORKMANAGER EXAMPLE
// =============================================================================

class _WorkManagerExample extends StatefulWidget {
  const _WorkManagerExample();

  @override
  State<_WorkManagerExample> createState() => _WorkManagerExampleState();
}

class _WorkManagerExampleState extends State<_WorkManagerExample> {
  final List<String> _logs = [];
  bool _isInitialized = false;

  Future<void> _initializeWorkManager() async {
    setState(() {
      _logs.add('⏳ Initializing WorkManager...');
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isInitialized = true;
      _logs.add('✅ WorkManager initialized');
      _logs.add('📝 Note: Requires native setup to actually run');
    });
  }

  void _registerPeriodicTask() {
    if (!_isInitialized) {
      setState(() => _logs.add('❌ Initialize WorkManager first'));
      return;
    }

    setState(() {
      _logs.add('📅 Registering periodic task: sync-data');
      _logs.add('   Frequency: Every 15 minutes');
      _logs.add('   Constraint: Network connected');
      _logs.add('✅ Task registered successfully');
    });
  }

  void _registerOneTimeTask() {
    if (!_isInitialized) {
      setState(() => _logs.add('❌ Initialize WorkManager first'));
      return;
    }

    setState(() {
      _logs.add('🔨 Registering one-time task: upload-queue');
      _logs.add('   Initial delay: 10 seconds');
      _logs.add('✅ Task will run once when conditions are met');
    });
  }

  void _cancelAllTasks() {
    setState(() {
      _logs.add('🗑️  Canceling all tasks...');
      _logs.add('✅ All tasks canceled');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('WorkManager Demo'),
        const _InfoCard(
          'Simulated Behavior',
          'This demo simulates WorkManager. In a real app with native setup,'
              ' tasks will run even when the app is closed.',
          Icons.info,
          Colors.blue,
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Actions'),
        _buildButton(
          'Initialize WorkManager',
          Icons.power_settings_new,
          _isInitialized ? null : _initializeWorkManager,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildButton(
          'Register Periodic Task (15 min)',
          Icons.schedule,
          _isInitialized ? _registerPeriodicTask : null,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildButton(
          'Register One-Time Task',
          Icons.play_arrow,
          _isInitialized ? _registerOneTimeTask : null,
          Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildButton(
          'Cancel All Tasks',
          Icons.cancel,
          _isInitialized ? _cancelAllTasks : null,
          Colors.red,
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Event Log'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _logs.isEmpty
                ? [
                    const Text(
                      'No events yet...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]
                : _logs
                      .map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
          ),
        ),
        const SizedBox(height: 24),
        _buildCodeExample(),
      ],
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    VoidCallback? onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? Colors.grey : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildCodeExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Code Example'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''// Initialize
Workmanager().initialize(
  callbackDispatcher,
  isInDebugMode: true,
);

// Register periodic task
Workmanager().registerPeriodicTask(
  "sync-data",
  "syncDataTask",
  frequency: Duration(minutes: 15),
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
);

// Callback (top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, data) {
    if (task == "syncDataTask") {
      // Sync your data here
      return Future.value(true);
    }
    return Future.value(false);
  });
}''',
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.lightGreenAccent,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// BACKGROUND ISOLATE EXAMPLE
// =============================================================================

class _IsolateExample extends StatefulWidget {
  const _IsolateExample();

  @override
  State<_IsolateExample> createState() => _IsolateExampleState();
}

class _IsolateExampleState extends State<_IsolateExample> {
  bool _isProcessing = false;
  String _result = '';

  Future<void> _runBackgroundTask() async {
    setState(() {
      _isProcessing = true;
      _result = 'Processing...';
    });

    // Simulate heavy computation in background isolate
    final stopwatch = Stopwatch()..start();
    final receivePort = ReceivePort();

    await Isolate.spawn(_heavyComputation, receivePort.sendPort);

    final result = await receivePort.first as int;
    stopwatch.stop();

    setState(() {
      _isProcessing = false;
      _result =
          'Computed: $result\nTime: ${stopwatch.elapsedMilliseconds}ms\n'
          'UI remained responsive!';
    });
  }

  static void _heavyComputation(SendPort sendPort) {
    // Simulate heavy work
    int sum = 0;
    for (int i = 0; i < 1000000000; i++) {
      sum += i ~/ 1000000;
    }
    sendPort.send(sum);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Background Isolates'),
        const _InfoCard(
          'Purpose',
          'Run CPU-intensive work in a separate thread without blocking the UI.'
              ' Unlike WorkManager, this runs while the app is open.',
          Icons.memory,
          Colors.purple,
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Demo: Heavy Computation'),
        const Text(
          'This will spawn an isolate to perform a billion iterations.'
          ' Watch the spinner - it will keep spinning smoothly!',
        ),
        const SizedBox(height: 16),
        if (_isProcessing)
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('UI is still responsive! 🚀'),
              ],
            ),
          ),
        if (_result.isNotEmpty && !_isProcessing)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              _result,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _runBackgroundTask,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Run Heavy Computation'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Code'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''// Spawn isolate
final receivePort = ReceivePort();
await Isolate.spawn(
  heavyComputation,
  receivePort.sendPort,
);

// Wait for result
final result = await receivePort.first;

// Worker function (top-level)
void heavyComputation(SendPort port) {
  // Do heavy work
  final result = expensiveOperation();
  port.send(result);
}''',
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.lightGreenAccent,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SETUP INSTRUCTIONS
// =============================================================================

class _SetupInstructions extends StatelessWidget {
  const _SetupInstructions();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Native Setup Required'),
        const _InfoCard(
          'Important',
          'WorkManager requires native configuration on Android and iOS.'
              ' Without this setup, tasks won\'t run in the background.',
          Icons.warning,
          Colors.orange,
        ),
        const SizedBox(height: 24),
        _buildPlatformSection(
          '📱 Android Setup',
          '''1. Add to android/app/src/main/AndroidManifest.xml:

<manifest>
  <application>
    <service
      android:name="androidx.work.impl.background.systemalarm.SystemAlarmService"
      android:directBootAware="false"
      android:enabled="@bool/enable_system_alarm_service"
      android:exported="false" />
    
    <service
      android:name="androidx.work.impl.background.systemjob.SystemJobService"
      android:directBootAware="false"
      android:enabled="@bool/enable_system_job_service"
      android:exported="true"
      android:permission="android.permission.BIND_JOB_SERVICE" />
  </application>
</manifest>

2. Permissions (if needed):
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>''',
        ),
        const SizedBox(height: 16),
        _buildPlatformSection(
          '🍎 iOS Setup',
          '''1. Enable Background Modes in Xcode:
   - Open ios/Runner.xcworkspace
   - Select Runner target
   - Go to Signing & Capabilities
   - Add Background Modes capability
   - Enable "Background fetch"

2. Add to Info.plist:
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>dev.fluttercommunity.workmanager.iOSBackgroundProcessingTask</string>
  <string>dev.fluttercommunity.workmanager.iOSPeriodicBackgroundTask</string>
</array>

3. iOS limits:
   - Minimum 15 minute intervals
   - System controls exact timing
   - May be delayed to save battery''',
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Best Practices'),
        _buildTip(
          '⚡ Battery Optimization',
          'Use constraints (WiFi only, charging) to preserve battery',
        ),
        _buildTip(
          '⏱️  Task Duration',
          'Keep tasks under 10 minutes. System may kill long tasks.',
        ),
        _buildTip(
          '🔄 Idempotency',
          'Tasks may run multiple times. Make them idempotent.',
        ),
        _buildTip('📶 Network', 'Check connectivity before network operations'),
        _buildTip(
          '💾 Data',
          'Save progress incrementally. Don\'t assume task completes.',
        ),
      ],
    );
  }

  Widget _buildPlatformSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.lightGreenAccent,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(content, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _InfoCard(this.title, this.content, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color.withOpacity(0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(color: color.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
