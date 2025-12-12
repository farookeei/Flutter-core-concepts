import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/lesson_scaffold.dart';

class OttPerformanceLessonPage extends StatelessWidget {
  const OttPerformanceLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'OTT Performance & Rendering',
      overview:
          'High-performance scrolling and rendering are critical for OTT apps (Netflix, YouTube), where rich media, autoplay videos, and complex layouts must run at a smooth 60/120 FPS.',
      steps: const [
        StepContent(
          title: '1. The Frame Budget (16ms)',
          description:
              'The Flutter rendering pipeline (Build -> Layout -> Paint) must complete within ~16ms to achieve 60 FPS. Complex widget trees or heavy painting operations in scrollable lists can cause "jank" (dropped frames).',
        ),
        StepContent(
          title: '2. Slivers for Complex Scrolling',
          description:
              'CustomScrollView with Slivers offers granular control for complex layouts. SliverList.builder and SliverGrid.builder lazily build children only when visible, preventing memory bloat.',
          codeSnippet: '''
CustomScrollView(
  slivers: [
    SliverAppBar(...),
    SliverList.builder(...),
    SliverGrid.builder(...),
  ],
)''',
        ),
        StepContent(
          title: '3. RepaintBoundary',
          description:
              'Active elements like progress bars or playing videos trigger frequent repaints. Wrapping them in RepaintBoundary creates a separate display list, preventing unnecessary repaints of parent widgets.',
          codeSnippet: '''
RepaintBoundary(
  child: VideoPlayerWidget(),
)''',
        ),
        StepContent(
          title: '4. Image Optimization',
          description:
              'Use CachedNetworkImage with cacheWidth/cacheHeight to decode images at display size, not original size. This saves memory and CPU.',
          codeSnippet: '''
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 300,
  fit: BoxFit.cover,
)''',
        ),
        StepContent(
          title: '5. Horizontal Lists',
          description:
              'For horizontal scrolling (like Netflix rows), use ListView.builder with horizontal scrollDirection. Keep item count reasonable and use RepaintBoundary for video thumbnails.',
        ),
      ],
      demo: const OttPerformanceDemo(),
    );
  }
}

class OttPerformanceDemo extends StatefulWidget {
  const OttPerformanceDemo({super.key});

  @override
  State<OttPerformanceDemo> createState() => _OttPerformanceDemoState();
}

class _OttPerformanceDemoState extends State<OttPerformanceDemo> {
  bool _useOptimizations = true;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('OTT Feed Demo'),
          floating: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Optimizations', style: TextStyle(fontSize: 12)),
                  Switch(
                    value: _useOptimizations,
                    onChanged: (val) => setState(() => _useOptimizations = val),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Featured Video Section
        SliverToBoxAdapter(
          child: _FeaturedVideoSection(useOptimizations: _useOptimizations),
        ),

        // Trending Now - Horizontal List
        SliverToBoxAdapter(
          child: _HorizontalVideoList(
            title: 'Trending Now',
            useOptimizations: _useOptimizations,
          ),
        ),

        // Continue Watching - Horizontal List with Progress
        SliverToBoxAdapter(
          child: _ContinueWatchingList(useOptimizations: _useOptimizations),
        ),

        // Recommended - Horizontal List
        SliverToBoxAdapter(
          child: _HorizontalVideoList(
            title: 'Recommended for You',
            useOptimizations: _useOptimizations,
          ),
        ),

        // Video Grid Section
        const SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Browse All',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        _useOptimizations
            ? const _OptimizedVideoGrid()
            : const _UnoptimizedVideoGrid(),
      ],
    );
  }
}

// =============================================================================
// FEATURED VIDEO SECTION
// =============================================================================

class _FeaturedVideoSection extends StatefulWidget {
  final bool useOptimizations;

  const _FeaturedVideoSection({required this.useOptimizations});

  @override
  State<_FeaturedVideoSection> createState() => _FeaturedVideoSectionState();
}

class _FeaturedVideoSectionState extends State<_FeaturedVideoSection> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'dQw4w9WgXcQ', // Sample YouTube video
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // OPTIMIZATION: RepaintBoundary isolates video repaints
          widget.useOptimizations ? RepaintBoundary(child: player) : player,
          const SizedBox(height: 8),
          const Text(
            'Sample Video Title',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Text(
            '1.2M views • 2 days ago',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HORIZONTAL VIDEO LIST
// =============================================================================

class _HorizontalVideoList extends StatelessWidget {
  final String title;
  final bool useOptimizations;

  const _HorizontalVideoList({
    required this.title,
    required this.useOptimizations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              return _VideoThumbnailCard(
                index: index,
                useOptimizations: useOptimizations,
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CONTINUE WATCHING LIST
// =============================================================================

class _ContinueWatchingList extends StatelessWidget {
  final bool useOptimizations;

  const _ContinueWatchingList({required this.useOptimizations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Continue Watching',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              return _ContinueWatchingCard(
                index: index,
                progress: (index + 1) * 0.1,
                useOptimizations: useOptimizations,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueWatchingCard extends StatefulWidget {
  final int index;
  final double progress;
  final bool useOptimizations;

  const _ContinueWatchingCard({
    required this.index,
    required this.progress,
    required this.useOptimizations,
  });

  @override
  State<_ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<_ContinueWatchingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = _buildThumbnail();
    final progressBar = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: widget.progress,
          backgroundColor: Colors.grey.shade800,
          valueColor: const AlwaysStoppedAnimation(Colors.red),
        );
      },
    );

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                thumbnail,
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  // OPTIMIZATION: RepaintBoundary on animated progress
                  child: widget.useOptimizations
                      ? RepaintBoundary(child: progressBar)
                      : progressBar,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Video Title ${widget.index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${(widget.progress * 100).toInt()}% watched',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    final imageUrl = 'https://picsum.photos/seed/${widget.index + 100}/280/160';

    if (widget.useOptimizations) {
      // OPTIMIZATION: CachedNetworkImage with memory cache size
      return CachedNetworkImage(
        imageUrl: imageUrl,
        memCacheWidth: 280,
        memCacheHeight: 160,
        height: 160,
        width: 280,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade800,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
      // UNOPTIMIZED: Regular Image.network without cache size
      return Image.network(
        imageUrl,
        height: 160,
        width: 280,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade800,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }
  }
}

// =============================================================================
// VIDEO THUMBNAIL CARD
// =============================================================================

class _VideoThumbnailCard extends StatelessWidget {
  final int index;
  final bool useOptimizations;

  const _VideoThumbnailCard({
    required this.index,
    required this.useOptimizations,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://picsum.photos/seed/$index/240/135';

    Widget thumbnail;
    if (useOptimizations) {
      // OPTIMIZATION: CachedNetworkImage with cache dimensions
      thumbnail = CachedNetworkImage(
        imageUrl: imageUrl,
        memCacheWidth: 240,
        memCacheHeight: 135,
        height: 135,
        width: 240,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade800,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    } else {
      // UNOPTIMIZED: No cache size specified
      thumbnail = Image.network(
        imageUrl,
        height: 135,
        width: 240,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // OPTIMIZATION: RepaintBoundary on thumbnail
            child: useOptimizations
                ? RepaintBoundary(child: thumbnail)
                : thumbnail,
          ),
          const SizedBox(height: 8),
          Text(
            'Video Title ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Text(
            '1.2M views • 3 days ago',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// OPTIMIZED VIDEO GRID
// =============================================================================

class _OptimizedVideoGrid extends StatelessWidget {
  const _OptimizedVideoGrid();

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: SliverGrid.builder for lazy loading
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 16 / 12,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 50,
        itemBuilder: (context, index) {
          return _OptimizedGridItem(index: index);
        },
      ),
    );
  }
}

class _OptimizedGridItem extends StatelessWidget {
  final int index;

  const _OptimizedGridItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://picsum.photos/seed/${index + 200}/320/180';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // OPTIMIZATION: RepaintBoundary + CachedNetworkImage
            child: RepaintBoundary(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                memCacheWidth: 320,
                memCacheHeight: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Grid Video ${index + 1}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Text(
          '500K views',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

// =============================================================================
// UNOPTIMIZED VIDEO GRID
// =============================================================================

class _UnoptimizedVideoGrid extends StatelessWidget {
  const _UnoptimizedVideoGrid();

  @override
  Widget build(BuildContext context) {
    // MISTAKE: Building all items at once instead of lazy loading
    final items = List.generate(50, (index) {
      return _UnoptimizedGridItem(index: index);
    });

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(spacing: 12, runSpacing: 12, children: items),
      ),
    );
  }
}

class _UnoptimizedGridItem extends StatelessWidget {
  final int index;

  const _UnoptimizedGridItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://picsum.photos/seed/${index + 200}/320/180';
    final width = (MediaQuery.of(context).size.width - 44) / 2;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // MISTAKE: No RepaintBoundary, no cache size
            child: Image.network(
              imageUrl,
              height: width * 9 / 16,
              width: width,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Grid Video ${index + 1}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Text(
            '500K views',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
