import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

class MarkdownPlaygroundPage extends StatefulWidget {
  const MarkdownPlaygroundPage({super.key});

  @override
  State<MarkdownPlaygroundPage> createState() => _MarkdownPlaygroundPageState();
}

class _MarkdownPlaygroundPageState extends State<MarkdownPlaygroundPage> {
  final TextEditingController _controller = TextEditingController(
    text:
        "Hello *world*!\nThis is a **bold** statement.\nHere is some # colored text.",
  );

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Mini Markdown Editor',
      overview:
          'Building a text editor requires deep control over text rendering. In Flutter, `TextPainter` is the engine behind the `Text` widget. Using it directly allows us to measure, layout, and paint text with pixel-perfect control.',
      steps: const [
        StepContent(
          title: '1. TextSpan Tree',
          description:
              'Flutter represents styled text as a tree of `TextSpan` objects. Each span has its own style. We parse markdown symbols (like **) and convert them into a tree of bold/italic TextSpans.',
          codeSnippet:
              'TextSpan(children: [TextSpan(text: "Hello", style: ...)])',
        ),
        StepContent(
          title: '2. The TextPainter',
          description:
              'This class acts as the layout engine. You give it the TextSpan tree and a text direction. It doesn\'t paint anything yet; it just holds the configuration.',
          codeSnippet:
              'final textPainter = TextPainter(\n  text: span,\n  textDirection: TextDirection.ltr,\n);',
        ),
        StepContent(
          title: '3. Layout Phase',
          description:
              'Before painting, you MUST call `layout()`. This calculates the width and height of the text block based on constraints (e.g., max width of the screen).',
          codeSnippet: 'textPainter.layout(minWidth: 0, maxWidth: width);',
        ),
        StepContent(
          title: '4. Paint Phase',
          description:
              'Finally, you call `paint(canvas, offset)`. This draws the pre-calculated text onto the canvas. This is how you would implement custom highlights, carets, or selection handles.',
          codeSnippet: 'textPainter.paint(canvas, Offset.zero);',
        ),
      ],
      demo: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Raw Text',
                hintText: 'Try using *italic*, **bold**, or #color',
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          const Divider(),
          const Text(
            'Custom TextPainter Preview:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, double.infinity),
                      painter: MarkdownPainter(
                        text: _controller.text,
                        width: constraints.maxWidth,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarkdownPainter extends CustomPainter {
  final String text;
  final double width;

  MarkdownPainter({required this.text, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final TextSpan span = _parseMarkdown(text);

    final TextPainter textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.layout(minWidth: 0, maxWidth: width);

    textPainter.paint(canvas, Offset.zero);
  }

  TextSpan _parseMarkdown(String input) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r"(\*\*.*?\*\*)|(\*.*?\*)|(#.*? )");

    input.splitMapJoin(
      exp,
      onMatch: (Match m) {
        final String match = m[0]!;
        if (match.startsWith("**")) {
          spans.add(
            TextSpan(
              text: match.substring(2, match.length - 2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
        } else if (match.startsWith("*")) {
          spans.add(
            TextSpan(
              text: match.substring(1, match.length - 1),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey,
              ),
            ),
          );
        } else if (match.startsWith("#")) {
          spans.add(
            TextSpan(
              text: match,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return '';
      },
      onNonMatch: (String text) {
        spans.add(
          TextSpan(
            text: text,
            style: const TextStyle(color: Colors.black),
          ),
        );
        return '';
      },
    );

    return TextSpan(children: spans);
  }

  @override
  bool shouldRepaint(covariant MarkdownPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.width != width;
  }
}
