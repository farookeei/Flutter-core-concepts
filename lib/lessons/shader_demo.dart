import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ShaderLessonPage extends StatefulWidget {
  const ShaderLessonPage({super.key});

  @override
  State<ShaderLessonPage> createState() => _ShaderLessonPageState();
}

class _ShaderLessonPageState extends State<ShaderLessonPage>
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
        title: const Text('Fragment Shaders (GLSL)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Learn'),
            Tab(icon: Icon(Icons.gamepad), text: 'Play'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ShaderLearnTab(), ShaderPlayTab()],
      ),
    );
  }
}

class ShaderLearnTab extends StatelessWidget {
  const ShaderLearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'What is a Fragment Shader?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'A Fragment Shader (or Pixel Shader) is a small program that runs on the GPU for every single pixel on the screen. It determines the color of that pixel based on inputs like coordinates, time, and textures.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        const Text(
          'How it works in Flutter:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '1. Write GLSL code (.frag file).\n'
          '2. Declare it in pubspec.yaml.\n'
          '3. Load it using FragmentProgram.fromAsset().\n'
          '4. Pass Uniforms (parameters) like time, resolution, or mouse position.\n'
          '5. Paint it using a CustomPainter.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        const Card(
          color: Colors.black87,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '// Example GLSL\n'
              'uniform float uTime;\n'
              'out vec4 fragColor;\n\n'
              'void main() {\n'
              '  fragColor = vec4(1.0, 0.0, 0.0, 1.0); // Red Pixel\n'
              '}',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.greenAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ShaderPlayTab extends StatefulWidget {
  const ShaderPlayTab({super.key});

  @override
  State<ShaderPlayTab> createState() => _ShaderPlayTabState();
}

class _ShaderPlayTabState extends State<ShaderPlayTab>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker.start();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/fancy_shader.frag',
      );
      setState(() {
        _program = program;
      });
    } catch (e) {
      debugPrint('Error loading shader: \$e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: ShaderPainter(
              shader: _program!.fragmentShader(),
              time: _time,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Time: \${_time.toStringAsFixed(2)}s',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;

  ShaderPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Uniforms must match the order in the GLSL file
    // uniform float uTime;
    // uniform vec2 uResolution;

    shader.setFloat(0, time); // uTime
    shader.setFloat(1, size.width); // uResolution.x
    shader.setFloat(2, size.height); // uResolution.y

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
