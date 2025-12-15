import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GestureArenaLessonPage extends StatefulWidget {
  const GestureArenaLessonPage({super.key});

  @override
  State<GestureArenaLessonPage> createState() => _GestureArenaLessonPageState();
}

class _GestureArenaLessonPageState extends State<GestureArenaLessonPage>
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
        title: const Text('The Gesture Arena'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Learn'),
            Tab(icon: Icon(Icons.sports_mma), text: 'Battle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [GestureLearnTab(), GestureBattleTab()],
      ),
    );
  }
}

class GestureLearnTab extends StatelessWidget {
  const GestureLearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Who wins the touch?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'When you touch the screen, Flutter doesn\'t know which widget you intend to interact with. Multiple widgets might be listening for the same gesture (nested scrollables, buttons inside lists).\n\nThis is where the **Gesture Arena** comes in.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildStep(
          '1. Hit Test',
          'Flutter finds all RenderObjects at the touch location.',
        ),
        _buildStep(
          '2. Dispatch',
          'Events (PointerDown) are sent to these objects.',
        ),
        _buildStep(
          '3. Arena Open',
          'Widgets add their "GestureRecognizers" to the Arena.',
        ),
        _buildStep(
          '4. Battle',
          'Recognizers track the pointer. If they think it\'s their gesture, they try to claim victory.',
        ),
        _buildStep(
          '5. Victory/Defeat',
          'If a recognizer declares victory (acceptGesture), all others are rejected (rejectGesture).',
        ),
      ],
    );
  }

  Widget _buildStep(String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}

class GestureBattleTab extends StatefulWidget {
  const GestureBattleTab({super.key});

  @override
  State<GestureBattleTab> createState() => _GestureBattleTabState();
}

class _GestureBattleTabState extends State<GestureBattleTab> {
  final List<String> _logs = [];
  bool _isChildAggressive = false;

  void _log(String message) {
    setState(() {
      _logs.insert(0, "\${DateTime.now().second}s: \$message");
      if (_logs.length > 20) _logs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Child Aggressive Mode'),
          subtitle: const Text(
            'If ON, Child claims victory immediately on touch.',
          ),
          value: _isChildAggressive,
          onChanged: (val) {
            setState(() {
              _isChildAggressive = val;
              _logs.clear();
            });
          },
        ),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Parent Widget
                GestureDetector(
                  onTap: () => _log('Parent Tapped!'),
                  // Standard Behavior: Parent waits.
                  onHorizontalDragStart: (_) => _log('Parent Drag START'),
                  onHorizontalDragUpdate: (_) {},
                  onHorizontalDragEnd: (_) => _log('Parent Drag END (Victory)'),
                  child: Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300],
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(8),
                    child: const Text('Parent (Standard GestureDetector)'),
                  ),
                ),

                // Child Widget (The Challenger)
                Positioned(
                  child: RawGestureDetector(
                    gestures: {
                      if (_isChildAggressive)
                        AggressiveGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                              AggressiveGestureRecognizer
                            >(() => AggressiveGestureRecognizer(), (
                              AggressiveGestureRecognizer instance,
                            ) {
                              instance.onTap = () =>
                                  _log('Child AGGRESSIVE Tap!');
                            })
                      else
                        TapGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                              TapGestureRecognizer
                            >(() => TapGestureRecognizer(), (
                              TapGestureRecognizer instance,
                            ) {
                              instance.onTap = () => _log('Child Standard Tap');
                            }),
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      color: _isChildAggressive
                          ? Colors.redAccent
                          : Colors.blueAccent,
                      alignment: Alignment.center,
                      child: Text(
                        _isChildAggressive
                            ? 'AGGRESSIVE CHILD'
                            : 'Standard Child',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        const Text('Arena Logs', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 150,
          child: ListView.builder(
            itemCount: _logs.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(_logs[index], style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Recognizer
// ---------------------------------------------------------------------------
class AggressiveGestureRecognizer extends TapGestureRecognizer {
  @override
  String get debugDescription => 'Aggressive';

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // Standard behavior: register and wait for arena to close or timeout.
    super.addAllowedPointer(event);

    // NUCLEAR OPTION
    // We declare victory immediately upon touch down!
    // This effectively bypasses the arena logic for anyone else who wanted this pointer.
    // See: lib/lessons/gesture_arena_deep_dive.md for full explanation
    resolve(GestureDisposition.accepted);
  }
}
