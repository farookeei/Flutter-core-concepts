import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliversAdvancedLessonPage extends StatefulWidget {
  const SliversAdvancedLessonPage({super.key});

  @override
  State<SliversAdvancedLessonPage> createState() =>
      _SliversAdvancedLessonPageState();
}

class _SliversAdvancedLessonPageState extends State<SliversAdvancedLessonPage>
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
        title: const Text('Advanced Slivers & Geometry'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Learn'),
            Tab(icon: Icon(Icons.play_circle), text: 'Play'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [SliversLearnTab(), SliversPlayTab()],
      ),
    );
  }
}

class SliversLearnTab extends StatelessWidget {
  const SliversLearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Understanding SliverGeometry',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Slivers are not just "scrollable widgets"; they are fragments of a viewport. Their layout protocol is different from RenderBox.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Constraints (SliverConstraints)',
          'Incoming data: axisDirection, growthDirection, userScrollDirection, scrollOffset, remainingPaintExtent, crossAxisExtent.',
        ),
        _buildInfoCard(
          'Geometry (SliverGeometry)',
          'Output data: scrollExtent (total size), paintExtent (visible size), paintOrigin (offset), layoutExtent (space taken).',
        ),
        const SizedBox(height: 24),
        const Text(
          'Custom RenderSliver',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'To create effects like parallax, sticky headers, or collapsing elements manually, we must extend RenderSliver (or RenderSliverSingleBoxAdapter) and override performLayout().',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class SliversPlayTab extends StatelessWidget {
  const SliversPlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('Standard SliverAppBar'),
          floating: true,
          pinned: true,
          expandedHeight: 120,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(title: Text('List Item \$index')),
            childCount: 15,
          ),
        ),
        // Our Custom Parallax Sliver
        SliverParallax(
          height: 200,
          child: Container(
            color: Colors.blueAccent,
            child: Center(
              child: const Text(
                'I am a Parallax Sliver!\nI scroll slower than the list.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                ListTile(title: Text('List Item \${index + 15}')),
            childCount: 20,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 1. The Widget
// ---------------------------------------------------------------------------
class SliverParallax extends SingleChildRenderObjectWidget {
  final double height;
  final double parallaxFactor; // 0.5 means half speed

  const SliverParallax({
    super.key,
    required super.child,
    this.height = 200,
    this.parallaxFactor = 0.5,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallaxSliver(height: height, parallaxFactor: parallaxFactor);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderParallaxSliver renderObject,
  ) {
    renderObject
      ..height = height
      ..parallaxFactor = parallaxFactor;
  }
}

// ---------------------------------------------------------------------------
// 2. The RenderObject (The Core Magic)
// ---------------------------------------------------------------------------
class RenderParallaxSliver extends RenderSliverSingleBoxAdapter {
  RenderParallaxSliver({required double height, required double parallaxFactor})
    : _height = height,
      _parallaxFactor = parallaxFactor;

  double _height;
  double get height => _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  double _parallaxFactor;
  double get parallaxFactor => _parallaxFactor;
  set parallaxFactor(double value) {
    if (_parallaxFactor == value) return;
    _parallaxFactor = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    // 1. We always want to force the child to be the specific height
    //    and fill the cross axis.
    child!.layout(
      constraints.asBoxConstraints(minExtent: _height, maxExtent: _height),
      parentUsesSize: true,
    );

    // 2. Calculate paintExtent (how much of us is visible on screen)
    //    Usually this is: min(remainingPaintExtent, maxExtent)
    final double extent = _height;
    final double paintedChildSize = calculatePaintOffset(
      constraints,
      from: 0.0,
      to: extent,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: 0.0,
      to: extent,
    );

    // 3. THE MAGIC: Calculate parallax offset.
    //    constraints.scrollOffset is how much the viewport has scrolled past our top.
    //    We want to shift painting by a fraction of that to create the lag.

    // HOWEVER, RenderSliverSingleBoxAdapter automatically applies a paint offset
    // based on geometry.paintOrigin.

    // To implement parallax efficiently in a Sliver, we usually manipulate the
    // `paintOrigin` or we apply a TransformLayer during paint.
    // Manipulating paintOrigin in geometry can be tricky because it affects
    // layout validation.

    // A simpler approach for "inside the sliver flow" parallax:
    // We lie about our layout? No, that breaks lists.
    // We just paint at a different offset? Yes.

    // Note: RenderSliverSingleBoxAdapter's paint method handles basic clipping.
    // We will override paint to apply the translation.

    assert(
      constraints.axisDirection == AxisDirection.down,
      'This demo only supports vertical scrolling down.',
    );

    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: extent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow:
          (paintedChildSize < extent), // visible part < total part
    );

    // Standard setChildParentData is handled by mixin
    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      // Calculate parallax delta
      // constraints.scrollOffset is > 0 when the top of the sliver is above the viewport top.
      // We want to "push" the child down slightly as we scroll down, so it stays in view longer.

      final double scrollOffset = constraints.scrollOffset;
      final double parallaxOffset = scrollOffset * _parallaxFactor;

      // When scrollOffset increases, we move the child DOWN by (scrollOffset * 0.5)
      // relative to the sliver's top.
      // BUT, the sliver's top itself is moving UP in the viewport.

      // Effective position in viewport = (Sliver Top) + (Parallax Offset)
      // Sliver Top relative to viewport = [handled by parent ScrollView, we just paint at 'offset']
      // 'offset' passed to paint is where the top of the sliver *should* be painted.
      // If we add to 'offset.dy', we shift the child down.

      final Offset parallaxAdjustedOffset = offset + Offset(0, parallaxOffset);

      // We must clip because we might paint outside our allotted slot if we move it
      context.pushClipRect(
        needsCompositing,
        offset, // Clip based on the sliver's ACTUAL position
        Rect.fromLTWH(0, 0, constraints.crossAxisExtent, geometry!.paintExtent),
        (context, offset) {
          context.paintChild(child!, parallaxAdjustedOffset);
        },
      );
    }
  }
}
