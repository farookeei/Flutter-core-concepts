import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

class AnimationsLessonPage extends StatelessWidget {
  const AnimationsLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Animations',
      overview:
          'Animations bring your app to life. Flutter offers two approaches: Implicit animations (easy, built-in) and Explicit animations (full control). Learn when to use each for production apps.',
      steps: const [
        StepContent(
          title: '1. Animation Fundamentals',
          description:
              'Animations are changes over time. Flutter rebuilds frames at 60 FPS. '
              'Duration controls how long, Curve controls the easing (linear, ease-in, bounce).',
        ),
        StepContent(
          title: '2. Implicit Animations (Easy)',
          description:
              'Built-in widgets that animate automatically when values change. No controller needed. '
              'Perfect for simple property changes.',
          codeSnippet: '''
AnimatedContainer(
  duration: Duration(seconds: 1),
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  color: isExpanded ? Colors.blue : Colors.red,
)''',
        ),
        StepContent(
          title: '3. Common Implicit Widgets',
          description:
              'AnimatedContainer (size, color, padding), AnimatedOpacity (fade), '
              'AnimatedAlign (position), AnimatedPadding, AnimatedRotation, AnimatedScale.',
        ),
        StepContent(
          title: '4. Explicit Animations (Control)',
          description:
              'Full control using AnimationController. Required for complex, chained, or looping animations. '
              'More code but unlimited possibilities.',
          codeSnippet: '''
final controller = AnimationController(
  vsync: this,
  duration: Duration(seconds: 2),
);
final animation = Tween<double>(
  begin: 0,
  end: 1,
).animate(controller);

controller.forward(); // Start''',
        ),
        StepContent(
          title: '5. Animation Curves',
          description:
              'Control the rate of change. Linear (constant speed), easeIn (slow start), '
              'easeOut (slow end), bounceOut (bouncy), elasticOut (spring).',
          codeSnippet: '''
curve: Curves.easeInOut,
curve: Curves.bounceOut,
curve: Curves.elasticOut,''',
        ),
        StepContent(
          title: '6. When to Use Which?',
          description:
              'Implicit: Simple property changes, fire-and-forget.\n'
              'Explicit: Complex sequences, loops, precise control, chaining.',
        ),
      ],
      demo: const AnimationsInteractiveDemo(),
    );
  }
}

// =============================================================================
// INTERACTIVE DEMO
// =============================================================================

class AnimationsInteractiveDemo extends StatefulWidget {
  const AnimationsInteractiveDemo({super.key});

  @override
  State<AnimationsInteractiveDemo> createState() =>
      _AnimationsInteractiveDemoState();
}

class _AnimationsInteractiveDemoState extends State<AnimationsInteractiveDemo> {
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
          _buildTab('Implicit', 0),
          _buildTab('Explicit', 1),
          _buildTab('Comparison', 2),
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
        return const _ImplicitAnimationsDemo();
      case 1:
        return const _ExplicitAnimationsDemo();
      case 2:
        return const _ComparisonDemo();
      default:
        return const SizedBox();
    }
  }
}

// =============================================================================
// IMPLICIT ANIMATIONS DEMO
// =============================================================================

class _ImplicitAnimationsDemo extends StatefulWidget {
  const _ImplicitAnimationsDemo();

  @override
  State<_ImplicitAnimationsDemo> createState() =>
      _ImplicitAnimationsDemoState();
}

class _ImplicitAnimationsDemoState extends State<_ImplicitAnimationsDemo> {
  bool _isExpanded = false;
  bool _isVisible = true;
  bool _isAligned = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Implicit Animations'),
        const _InfoCard(
          'What are Implicit Animations?',
          'Widgets that animate automatically when their properties change. '
              'No controller needed. Just change the value and setState!',
          Icons.auto_awesome,
        ),
        const SizedBox(height: 24),

        // AnimatedContainer
        const _SubHeader('1. AnimatedContainer'),
        const Text('Animates size, color, padding, border, etc.'),
        const SizedBox(height: 12),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _isExpanded ? 200 : 100,
            height: _isExpanded ? 200 : 100,
            decoration: BoxDecoration(
              color: _isExpanded ? Colors.blue : Colors.red,
              borderRadius: BorderRadius.circular(_isExpanded ? 100 : 20),
            ),
            child: const Center(
              child: Icon(Icons.star, color: Colors.white, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(_isExpanded ? 'Shrink' : 'Expand'),
        ),
        const SizedBox(height: 24),

        // AnimatedOpacity
        const _SubHeader('2. AnimatedOpacity'),
        const Text('Fade in/out effect'),
        const SizedBox(height: 12),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _isVisible ? 1.0 : 0.0,
            child: Container(
              width: 150,
              height: 150,
              color: Colors.green,
              child: const Center(
                child: Text(
                  'Hello!',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => setState(() => _isVisible = !_isVisible),
          child: Text(_isVisible ? 'Fade Out' : 'Fade In'),
        ),
        const SizedBox(height: 24),

        // AnimatedAlign
        const _SubHeader('3. AnimatedAlign'),
        const Text('Smoothly move widget position'),
        const SizedBox(height: 12),
        Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: _isAligned
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => setState(() => _isAligned = !_isAligned),
          child: Text(_isAligned ? 'Move Left' : 'Move Right'),
        ),
        const SizedBox(height: 24),

        _buildCodeExample(),
      ],
    );
  }

  Widget _buildCodeExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubHeader('Code Example'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''// Just change values and call setState!
bool isExpanded = false;

AnimatedContainer(
  duration: Duration(milliseconds: 500),
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  color: isExpanded ? Colors.blue : Colors.red,
)

// Trigger animation
setState(() => isExpanded = !isExpanded);''',
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
// EXPLICIT ANIMATIONS DEMO
// =============================================================================

class _ExplicitAnimationsDemo extends StatefulWidget {
  const _ExplicitAnimationsDemo();

  @override
  State<_ExplicitAnimationsDemo> createState() =>
      _ExplicitAnimationsDemoState();
}

class _ExplicitAnimationsDemoState extends State<_ExplicitAnimationsDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _sizeAnimation = Tween<double>(
      begin: 50,
      end: 150,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.purple,
      end: Colors.pink,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Explicit Animations'),
        const _InfoCard(
          'What are Explicit Animations?',
          'Full control using AnimationController. Required for complex animations, '
              'loops, sequences, or when you need precise timing.',
          Icons.tune,
        ),
        const SizedBox(height: 24),
        const _SubHeader('AnimationController Demo'),
        const Text('Multiple properties animated together'),
        const SizedBox(height: 24),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159,
                child: Container(
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite, color: Colors.white, size: 40),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _controller.forward(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Forward'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _controller.reverse(),
              icon: const Icon(Icons.replay),
              label: const Text('Reverse'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _controller.repeat(reverse: true),
          icon: const Icon(Icons.loop),
          label: const Text('Loop'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _controller.stop(),
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
        ),
        const SizedBox(height: 24),
        _buildCodeExample(),
      ],
    );
  }

  Widget _buildCodeExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubHeader('Code Example'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''// Setup AnimationController
late AnimationController controller;

@override
void initState() {
  controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  );
  
  final animation = Tween<double>(
    begin: 50,
    end: 150,
  ).animate(controller);
}

// Use in build
AnimatedBuilder(
  animation: controller,
  builder: (context, child) {
    return Container(
      width: animation.value,
      height: animation.value,
    );
  },
)

// Control
controller.forward();  // Start
controller.reverse();  // Backward
controller.repeat();   // Loop''',
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
// COMPARISON DEMO
// =============================================================================

class _ComparisonDemo extends StatelessWidget {
  const _ComparisonDemo();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Implicit vs Explicit'),
        _buildComparisonTable(),
        const SizedBox(height: 24),
        _buildWhenToUse('Implicit', [
          'Simple property changes',
          'Fire-and-forget animations',
          'Quick prototypes',
          'Most UI transitions',
        ], Colors.green),
        const SizedBox(height: 16),
        _buildWhenToUse('Explicit', [
          'Complex sequences',
          'Looping animations',
          'Chained animations',
          'Precise control needed',
          'Gaming, custom interactions',
        ], Colors.blue),
        const SizedBox(height: 24),
        const _SubHeader('Animation Curves'),
        _buildCurvesExample(),
      ],
    );
  }

  Widget _buildComparisonTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: const [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Feature',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Implicit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Explicit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        _buildTableRow('Ease of Use', '✅ Easy', '❌ More Code'),
        _buildTableRow('Control', '❌ Limited', '✅ Full'),
        _buildTableRow('Looping', '❌ No', '✅ Yes'),
        _buildTableRow('Chaining', '❌ No', '✅ Yes'),
        _buildTableRow('Performance', '✅ Optimized', '✅ Optimized'),
      ],
    );
  }

  TableRow _buildTableRow(String feature, String implicit, String explicit) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            feature,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8), child: Text(implicit)),
        Padding(padding: const EdgeInsets.all(8), child: Text(explicit)),
      ],
    );
  }

  Widget _buildWhenToUse(String type, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When to use $type:',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvesExample() {
    return Column(
      children: [
        _buildCurveItem('linear', 'Constant speed'),
        _buildCurveItem('easeIn', 'Slow start, fast end'),
        _buildCurveItem('easeOut', 'Fast start, slow end'),
        _buildCurveItem('easeInOut', 'Slow start and end'),
        _buildCurveItem('bounceOut', 'Bouncy end'),
        _buildCurveItem('elasticOut', 'Spring effect'),
      ],
    );
  }

  Widget _buildCurveItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Curves.$name',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 12)),
          ),
        ],
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
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String title;

  const _SubHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoCard(this.title, this.content, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade700),
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
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
