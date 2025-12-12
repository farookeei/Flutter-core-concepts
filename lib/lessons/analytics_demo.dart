import 'dart:async';
import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

// =============================================================================
// ANALYTICS ABSTRACTION LAYER
// =============================================================================

/// A production-grade abstraction for analytics.
///
/// In a real app, implementations would wrap Firebase, Amplitude, Mixpanel, etc.
/// This allows you to swap providers without changing your app code.
abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);
  Future<void> setUserProperty(String name, String value);
  Future<void> setCurrentScreen(String screenName);
}

/// A simulated implementation that stores events in memory for the demo.
class InMemoryAnalytics implements AnalyticsService {
  final StreamController<String> _logController = StreamController.broadcast();
  Stream<String> get logStream => _logController.stream;

  final Map<String, int> eventCounts = {};

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    final count = (eventCounts[name] ?? 0) + 1;
    eventCounts[name] = count;

    final paramString = parameters != null ? ' params: $parameters' : '';
    _logController.add('📊 Event: $name$paramString');
    debugPrint('Analytics: $name $paramString');
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    _logController.add('📱 Screen: $screenName');
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    _logController.add('👤 User Property: $name = $value');
  }

  void clear() {
    eventCounts.clear();
    _logController.add('🧹 Analytics cleared');
  }
}

// Global instance for the demo
final demoAnalytics = InMemoryAnalytics();

// =============================================================================
// LESSON PAGE
// =============================================================================

class AnalyticsLessonPage extends StatelessWidget {
  const AnalyticsLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'User Funnels & Analytics',
      overview:
          'Learn how to track user behavior to build optimization funnels. '
          'We use an abstraction layer so you aren\'t tied to one vendor.',
      steps: const [
        StepContent(
          title: '1. Why Abstraction?',
          description:
              'Never call "FirebaseAnalytics.instance.logEvent" directly in your UI code! '
              'Create an `AnalyticsService` interface. This lets you:\n'
              '• Swap providers easily (e.g., Firebase → Amplitude)\n'
              '• Log to multiple providers at once\n'
              '• Mock analytics for testing\n'
              '• Debug events locally',
          codeSnippet: '''
abstract class AnalyticsService {
  void logEvent(String name, Map<String, dynamic> params);
  void setUserProperty(String name, String value);
}''',
        ),
        StepContent(
          title: '2. What is a Funnel?',
          description:
              'A funnel represents a series of steps a user takes to reach a goal (e.g., Purchase). '
              'It helps visualize where users "drop off".',
        ),
        StepContent(
          title: '3. Event Taxonomy',
          description:
              'Use consistent naming. Convention: `object_action` (noun_verb) or `action_object`.\n'
              '• `product_viewed`\n'
              '• `add_to_cart`\n'
              '• `checkout_started`\n'
              '• `purchase_completed`',
        ),
        StepContent(
          title: '4. Parameters & Properties',
          description:
              'Events need context. Don\'t just log "purchase", log "purchase" with parameters `{amount: 99.99, currency: "USD"}`. '
              'User properties track state like `is_premium` or `ltv`.',
        ),
      ],
      demo: const FunnelInteractiveDemo(),
    );
  }
}

// =============================================================================
// INTERACTIVE DEMO
// =============================================================================

class FunnelInteractiveDemo extends StatefulWidget {
  const FunnelInteractiveDemo({super.key});

  @override
  State<FunnelInteractiveDemo> createState() => _FunnelInteractiveDemoState();
}

class _FunnelInteractiveDemoState extends State<FunnelInteractiveDemo> {
  // Funnel Data Model
  static const String eventProductView = 'product_viewed';
  static const String eventAddToCart = 'add_to_cart';
  static const String eventCheckoutStart = 'checkout_started';
  static const String eventPurchase = 'purchase_completed';

  final List<String> _logs = [];
  late StreamSubscription _logSub;

  @override
  void initState() {
    super.initState();
    _logSub = demoAnalytics.logStream.listen((log) {
      if (mounted) {
        setState(() {
          _logs.insert(0, log);
          if (_logs.length > 20) _logs.removeLast();
        });
      }
    });

    // Initial mock data to make the chart look interesting
    // Simulate typical drop-off
    demoAnalytics.eventCounts[eventProductView] = 100;
    demoAnalytics.eventCounts[eventAddToCart] = 60;
    demoAnalytics.eventCounts[eventCheckoutStart] = 30;
    demoAnalytics.eventCounts[eventPurchase] = 15;
  }

  @override
  void dispose() {
    _logSub.cancel();
    super.dispose();
  }

  void _simulateProductView() {
    demoAnalytics.logEvent(eventProductView, {
      'product_id': 'flutter_course_1',
    });
  }

  void _simulateAddToCart() {
    demoAnalytics.logEvent(eventAddToCart, {'quantity': 1});
  }

  void _simulateCheckout() {
    demoAnalytics.logEvent(eventCheckoutStart);
  }

  void _simulatePurchase() {
    demoAnalytics.logEvent(eventPurchase, {'revenue': 49.99});
  }

  void _resetMetrics() {
    setState(() {
      demoAnalytics.clear();
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'E-Commerce Conversion Funnel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Interact with the simulated app below to trigger analytics events. '
            'The chart visualizes the "drop-off" at each stage.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // VISUALIZATION
          _buildFunnelChart(),

          const SizedBox(height: 32),

          // SIMULATOR CONTROLS
          const Text(
            'User Actions Simulator',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildActionButton(
                '1. View Product',
                Icons.visibility,
                Colors.blue,
                _simulateProductView,
              ),
              _buildActionButton(
                '2. Add to Cart',
                Icons.shopping_cart,
                Colors.orange,
                _simulateAddToCart,
              ),
              _buildActionButton(
                '3. Checkout',
                Icons.payment,
                Colors.purple,
                _simulateCheckout,
              ),
              _buildActionButton(
                '4. Purchase',
                Icons.check_circle,
                Colors.green,
                _simulatePurchase,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: _resetMetrics,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Metrics'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),

          const SizedBox(height: 24),

          // LOGS
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics Log (Debug Console)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Divider(color: Colors.white24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.greenAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildFunnelChart() {
    // Get current counts or 0
    final views = demoAnalytics.eventCounts[eventProductView] ?? 0;
    final carts = demoAnalytics.eventCounts[eventAddToCart] ?? 0;
    final checkouts = demoAnalytics.eventCounts[eventCheckoutStart] ?? 0;
    final purchases = demoAnalytics.eventCounts[eventPurchase] ?? 0;

    // Calculate max to normalize bar width
    int maxVal = views;
    if (carts > maxVal) maxVal = carts;
    if (checkouts > maxVal) maxVal = checkouts;
    if (purchases > maxVal) maxVal = purchases;
    if (maxVal == 0) maxVal = 1; // avoid div by zero

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFunnelRow('Product View', views, maxVal, Colors.blue, null),
            _buildConnector(),
            _buildFunnelRow('Add to Cart', carts, maxVal, Colors.orange, views),
            _buildConnector(),
            _buildFunnelRow(
              'Checkout',
              checkouts,
              maxVal,
              Colors.purple,
              carts,
            ),
            _buildConnector(),
            _buildFunnelRow(
              'Purchase',
              purchases,
              maxVal,
              Colors.green,
              checkouts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      height: 12,
      width: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(vertical: 2),
    );
  }

  Widget _buildFunnelRow(
    String label,
    int count,
    int total,
    Color color,
    int? previousCount,
  ) {
    // Width represents volume relative to the start (or max)
    final double percentage = count / total;

    // Conversion rate from previous step
    String conversionText = '';
    if (previousCount != null && previousCount > 0) {
      final rate = ((count / previousCount) * 100).toStringAsFixed(1);
      conversionText = '$rate% conv.';
    }

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background bar
              Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Conversion rate text (floating right)
              if (conversionText.isNotEmpty)
                Positioned(
                  right: 8,
                  child: Text(
                    conversionText,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              // Filled bar
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 500),
                widthFactor: percentage.clamp(
                  0.01,
                  1.0,
                ), // ensure minimal visibility
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
