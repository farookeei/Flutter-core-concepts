import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:flutter/material.dart';

// FFI Bindings definition
// C signature: int32_t native_add(int32_t x, int32_t y)
typedef NativeAddC = ffi.Int32 Function(ffi.Int32 x, ffi.Int32 y);
typedef NativeAddDart = int Function(int x, int y);

// C signature: int32_t heavy_computation(int32_t iterations)
typedef HeavyComputationC = ffi.Int32 Function(ffi.Int32 iterations);
typedef HeavyComputationDart = int Function(int iterations);

class FfiLessonPage extends StatefulWidget {
  const FfiLessonPage({super.key});

  @override
  State<FfiLessonPage> createState() => _FfiLessonPageState();
}

class _FfiLessonPageState extends State<FfiLessonPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dart:ffi (Native Code)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Learn'),
            Tab(icon: Icon(Icons.terminal), text: 'Play'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [FfiLearnTab(), FfiPlayTab()],
      ),
    );
  }
}

class FfiLearnTab extends StatelessWidget {
  const FfiLearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Foreign Function Interface (FFI)',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'dart:ffi allows Dart code to call C functions synchronously. This is extremely fast because there is no message serialization (unlike MethodChannels).',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          'DynamicLibrary',
          'Represents a shared object (like .dylib, .so, .dll). You open it using DynamicLibrary.open(path).',
        ),
        _buildInfoCard(
          'Lookup',
          'You look up symbols (function names) in the library. e.g., library.lookupFunction<NativeType, DartType>("function_name").',
        ),
        _buildInfoCard(
          'Memory Management',
          'You can allocate native memory using malloc/calloc and must free it manually.',
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }
}

class FfiPlayTab extends StatefulWidget {
  const FfiPlayTab({super.key});

  @override
  State<FfiPlayTab> createState() => _FfiPlayTabState();
}

class _FfiPlayTabState extends State<FfiPlayTab> {
  ffi.DynamicLibrary? _lib;
  NativeAddDart? _nativeAdd;
  HeavyComputationDart? _heavyComputation;

  String _status = 'Library not loaded.';
  String _result = '';

  final TextEditingController _valA = TextEditingController(text: '10');
  final TextEditingController _valB = TextEditingController(text: '20');

  void _loadLibrary() {
    try {
      // For this demo, we assume the dylib is in the project root/native during development
      // or built into the app bundle.
      // In a real app, you'd use 'libnative_add.so' or included in Frameworks.
      // Here, we hardcode the absolute path for this specific dev environment as a fallback
      // or try relative path if possible.

      // Attempting to find it relative to current working directory of the process
      String path = 'native/libnative_add.dylib';
      if (!File(path).existsSync()) {
        // Fallback to absolute path known from user environment
        path =
            '/Users/farook/Documents/flutter_low/low_level/native/libnative_add.dylib';
      }

      final library = ffi.DynamicLibrary.open(path);

      setState(() {
        _lib = library;
        _nativeAdd = library.lookupFunction<NativeAddC, NativeAddDart>(
          'native_add',
        );
        _heavyComputation = library
            .lookupFunction<HeavyComputationC, HeavyComputationDart>(
              'heavy_computation',
            );
        _status = 'Library loaded! Ready to call C.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading library: \$e';
      });
    }
  }

  void _callAdd() {
    if (_nativeAdd == null) return;
    final int a = int.tryParse(_valA.text) ?? 0;
    final int b = int.tryParse(_valB.text) ?? 0;

    final int sum = _nativeAdd!(a, b);

    setState(() {
      _result = 'C returned: \$sum';
    });
  }

  void _callHeavy() async {
    if (_heavyComputation == null) return;

    setState(() {
      _result = 'Running heavy task (Main thread will FREEZE)...';
    });

    // We yield to let the UI update show the message above before freezing
    await Future.delayed(const Duration(milliseconds: 100));

    // This call is SYNCHRONOUS. It happens on the UI thread!
    // The C function sleeps for 2 seconds. The text field animation will stop.
    final int res = _heavyComputation!(1000);

    setState(() {
      _result = 'Heavy task done. Result: \$res';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: _lib == null ? Colors.red[100] : Colors.green[100],
            child: Text(_status),
          ),
          const SizedBox(height: 20),
          if (_lib == null)
            ElevatedButton(
              onPressed: _loadLibrary,
              child: const Text('Load Native Library'),
            ),

          if (_lib != null) ...[
            const Text(
              'Native Addition',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valA,
                    decoration: const InputDecoration(labelText: 'A'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _valB,
                    decoration: const InputDecoration(labelText: 'B'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _callAdd,
              child: const Text('Call native_add(A, B)'),
            ),

            const Divider(height: 40),

            const Text(
              'Blocking the UI Thread',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Calling C functions on the main thread blocks Flutter! watch the CircularProgressIndicator freeze.',
            ),
            const SizedBox(height: 10),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: _callHeavy,
              child: const Text('Run Heavy C Task (2 seconds)'),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            _result,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
