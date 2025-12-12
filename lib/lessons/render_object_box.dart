import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/lesson_scaffold.dart';

class RenderObjectPage extends StatelessWidget {
  const RenderObjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'RenderObject Box',
      overview:
          'Widgets are just blueprints. The heavy lifting of layout and painting happens in the Render Tree. In this lesson, we create a custom `RenderBox` implementation, bypassing standard Widgets like `Container`.',
      steps: const [
        StepContent(
          title: '1. The Widget',
          description:
              'We create a subclass of `SingleChildRenderObjectWidget`. This Widget has no "build" method. Instead, it has `createRenderObject` and `updateRenderObject` methods.',
          codeSnippet:
              'class MyWidget extends SingleChildRenderObjectWidget {\n  @override\n  RenderObject createRenderObject(context) => MyRenderBox();\n}',
        ),
        StepContent(
          title: '2. The RenderBox',
          description:
              'This is where the magic happens. We subclass `RenderBox`. We must mix in `RenderObjectWithChildMixin` if we want to manage children easily.',
        ),
        StepContent(
          title: '3. PerformLayout',
          description:
              'Layout flows down. We receive usage `constraints` (min/max width/height) from our parent. We must calculate our own `size` based on these constraints and our child\'s size.',
          codeSnippet:
              '@override\nvoid performLayout() {\n  child?.layout(constraints, parentUsesSize: true);\n  size = Size(...);\n}',
        ),
        StepContent(
          title: '4. Paint',
          description:
              'Painting flows down. We get a `PaintingContext` and an `Offset`. We draw ourselves, and then ask the context to paint our child at a specific offset.',
          codeSnippet:
              '@override\nvoid paint(context, offset) {\n  context.canvas.drawRect(...);\n  context.paintChild(child!, offset + childOffset);\n}',
        ),
      ],
      demo: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'The red box below is NOT a Container.\nIt is a raw RenderObject!',
            ),
            const SizedBox(height: 20),
            CustomRenderBoxWidget(
              color: Colors.red,
              child: const Center(
                child: Text(
                  'I am a child\ninside a RenderBox',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRenderBoxWidget extends SingleChildRenderObjectWidget {
  final Color color;

  const CustomRenderBoxWidget({super.key, required this.color, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomBox(color: color);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderCustomBox renderObject,
  ) {
    renderObject.color = color;
  }
}

class RenderCustomBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  Color _color;

  RenderCustomBox({required Color color}) : _color = color;

  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);

      final double width = (child!.size.width + 50).clamp(
        constraints.minWidth,
        constraints.maxWidth,
      );
      final double height = (child!.size.height + 50).clamp(
        constraints.minHeight,
        constraints.maxHeight,
      );
      size = Size(width, height);

      final BoxParentData childParentData = child!.parentData as BoxParentData;
      childParentData.offset = Offset(
        (size.width - child!.size.width) / 2,
        (size.height - child!.size.height) / 2,
      );
    } else {
      size = Size(
        constraints.constrainWidth(200),
        constraints.constrainHeight(200),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()..color = _color;
    context.canvas.drawRect(offset & size, paint);

    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      context.paintChild(child!, offset + childParentData.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      return result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }
}
