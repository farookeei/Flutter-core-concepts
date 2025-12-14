import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img; // The pure Dart image library
import 'package:flutter/foundation.dart'; // For compute

class ImageProcessingIsolateDemo extends StatefulWidget {
  const ImageProcessingIsolateDemo({super.key});

  @override
  State<ImageProcessingIsolateDemo> createState() =>
      _ImageProcessingIsolateDemoState();
}

class _ImageProcessingIsolateDemoState
    extends State<ImageProcessingIsolateDemo> {
  Uint8List? _originalImageBytes;
  Uint8List? _processedImageBytes;
  bool _isProcessing = false;
  String _status = 'Ready to process';

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Load from assets
      final data = await rootBundle.load('assets/image.jpg');
      setState(() {
        _originalImageBytes = data.buffer.asUint8List();
        _status =
            'Image loaded (${(_originalImageBytes!.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB)';
      });
    } catch (e) {
      setState(() => _status = 'Error loading image: $e');
    }
  }

  // --- THE HEAVY LOGIC ---

  // This function must be static or top-level to be used with compute()
  static Uint8List _applyHeavyFilter(Uint8List inputBytes) {
    // 1. Decode the image (CPU intensive)
    final image = img.decodeImage(inputBytes);
    if (image == null) return inputBytes;

    // 2. Apply a heavy filter (e.g., Pixelate + Sepia + Gaussian Blur simulation)
    // We chain multiple effects to make it truly heavy for the CPU

    // Pixelate
    var processed = img.pixelate(image, size: 10);

    // Sepia
    processed = img.sepia(processed);

    // 3. Encode back to JPEG (CPU intensive)
    return Uint8List.fromList(img.encodeJpg(processed));
  }

  // --- ACTIONS ---

  void _runOnMainThread() {
    if (_originalImageBytes == null) return;

    setState(() {
      _isProcessing = true;
      _status = 'Running on MAIN THREAD... (UI will freeze!)';
    });

    // We use a slight delay so the UI has a chance to update the status text before freezing
    Future.delayed(const Duration(milliseconds: 100), () {
      final stopwatch = Stopwatch()..start();

      // BLOCKING CALL
      final result = _applyHeavyFilter(_originalImageBytes!);

      stopwatch.stop();
      setState(() {
        _isProcessing = false;
        _processedImageBytes = result;
        _status =
            'Main Thread: Done in ${stopwatch.elapsedMilliseconds}ms (Did it freeze?)';
      });
    });
  }

  Future<void> _runOnIsolate() async {
    if (_originalImageBytes == null) return;

    setState(() {
      _isProcessing = true;
      _status = 'Spawning Isolate... (UI remains smooth)';
      _processedImageBytes = null;
    });

    final stopwatch = Stopwatch()..start();

    // NON-BLOCKING CALL (Runs in background)
    final result = await compute(_applyHeavyFilter, _originalImageBytes!);

    stopwatch.stop();
    setState(() {
      _isProcessing = false;
      _processedImageBytes = result;
      _status = 'Isolate: Done in ${stopwatch.elapsedMilliseconds}ms (Smooth!)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Processing (Real World)')),
      body: Column(
        children: [
          // 1. Status Area
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey.shade50,
            width: double.infinity,
            child: Column(
              children: [
                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(),
                  ),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Try scrolling or tapping - you can\'t if frozen!',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _runOnMainThread,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: const Text(
                      'Main Thread\n(Freeze)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _runOnIsolate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    ),
                    child: const Text(
                      'Background Isolate\n(Smooth)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Image Preview
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_processedImageBytes != null) ...[
                    const Text(
                      'Processed Result:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.memory(_processedImageBytes!, height: 300),
                  ] else if (_originalImageBytes != null) ...[
                    const Text(
                      'Original:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.memory(_originalImageBytes!, height: 300),
                  ] else
                    const SizedBox(
                      height: 100,
                      child: Center(child: Text('Loading asset...')),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
