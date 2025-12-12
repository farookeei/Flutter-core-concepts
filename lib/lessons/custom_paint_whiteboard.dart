import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

class WhiteboardPage extends StatefulWidget {
  const WhiteboardPage({super.key});

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage> {
  // Store a list of strokes (each stroke is a list of Offset points)
  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'CustomPaint Whiteboard',
      overview:
          'In this lesson, you will learn how to build a performant drawing interface used in apps like whiteboards or signature pads. '
          'We bypass the standard Widget tree for rendering and draw directly onto the canvas.',
      steps: const [
        StepContent(
          title: '1. The GestureDetector',
          description:
              'We use a GestureDetector to capture raw touch events. Specifically, we listen to `onPanStart`, `onPanUpdate`, and `onPanEnd` to track the user\'s finger movement.',
          codeSnippet:
              'GestureDetector(\n  onPanUpdate: (details) {\n    // Add point to current stroke\n  },\n  child: CustomPaint(...)\n)',
        ),
        StepContent(
          title: '2. The CustomPaint Widget',
          description:
              'CustomPaint is a widget that provides a Canvas to a "painter". It essentially says "I will let you draw whatever you want in this box".',
        ),
        StepContent(
          title: '3. The CustomPainter Subclass',
          description:
              'The real magic happens here. You subclass CustomPainter and override the `paint` method. This method gives you a `Canvas` and a `Size`. You can draw lines, circles, paths, and images directly.',
          codeSnippet:
              'class MyPainter extends CustomPainter {\n  @override\n  void paint(Canvas canvas, Size size) {\n    canvas.drawPath(path, paint);\n  }\n}',
        ),
        StepContent(
          title: '4. Optimization',
          description:
              'The `shouldRepaint` method allows you to control performance. If your data hasn\'t changed, you return false to avoid expensive redraws. In this simple example, we always return true because the data changes on every frame of dragging.',
        ),
      ],
      demo: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _strokes.clear();
              _currentStroke = null;
            });
          },
          child: const Icon(Icons.clear),
        ),
        body: GestureDetector(
          onPanStart: (details) {
            setState(() {
              _currentStroke = [details.localPosition];
              _strokes.add(_currentStroke!);
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _currentStroke?.add(details.localPosition);
            });
          },
          onPanEnd: (details) {
            setState(() {
              _currentStroke = null;
            });
          },
          child: CustomPaint(
            painter: WhiteboardPainter(strokes: _strokes),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class WhiteboardPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  WhiteboardPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WhiteboardPainter oldDelegate) {
    return true;
  }
}
