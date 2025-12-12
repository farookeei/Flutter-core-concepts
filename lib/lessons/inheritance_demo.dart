import 'package:flutter/material.dart';
import '../core/lesson_scaffold.dart';

// =============================================================================
// DOMAIN LOGIC (THE RPG SYSTEM)
// =============================================================================

// 1. ABSTRACT BASE CLASS
abstract class GameCharacter {
  String get name;
  String attack();
}

// 2. MIXINS (ABILITIES)
mixin Runner {
  String run() => "runs fast!";
}

mixin Swimmer {
  String swim() => "swims efficiently!";
}

mixin Flyer {
  String fly() => "flies high in the sky!";
}

// 3. CONCRETE CLASSES
class Warrior extends GameCharacter with Runner {
  @override
  String get name => "Warrior";

  @override
  String attack() => "swings a giant sword!";
}

class Mage extends GameCharacter with Runner, Flyer {
  @override
  String get name => "Mage";

  @override
  String attack() => "casts a fireball!";
}

// 4. IMPLEMENTS (CONTRACT)
// A Robot is NOT a GameCharacter (biologically), but it implements the interface
class Robot implements GameCharacter {
  @override
  String get name => "Robot";

  @override
  String attack() => "fires laser beams!";

  // Robots can't use biological mixins directly if they required 'GameCharacter',
  // but here our mixins are pure.
  String recharge() => "recharging batteries...";
}

// =============================================================================
// UI MODULE
// =============================================================================

class InheritanceLessonPage extends StatelessWidget {
  const InheritanceLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Dart Inheritance & OOP',
      overview:
          'In Dart interviews, you are often asked the difference between `extends`, `implements`, and `with`. Understanding this is crucial for architecture.',
      steps: const [
        StepContent(
          title: '1. Extends (Is-a)',
          description:
              'Used for class inheritance. A child class inherits behavior and state from ONE parent. Use this when objects share a strict hierarchy.',
          codeSnippet: 'class Warrior extends Character { ... }',
        ),
        StepContent(
          title: '2. Implements (Can-do)',
          description:
              'Treats a class as an Interface. You must override EVERY method. Useful for mocking in tests or enforcing a contract on unrelated objects.',
          codeSnippet: 'class MockService implements ApiService { ... }',
        ),
        StepContent(
          title: '3. With / Mixins (Has-a)',
          description:
              'A way to reuse code across multiple class hierarchies. Think of them as "Abilities" you plug into a class.',
          codeSnippet: 'class Duck extends Animal with Flyer, Swimmer { ... }',
        ),
      ],
      demo: const InheritanceInteractiveDemo(),
    );
  }
}

class InheritanceInteractiveDemo extends StatefulWidget {
  const InheritanceInteractiveDemo({super.key});

  @override
  State<InheritanceInteractiveDemo> createState() =>
      _InheritanceInteractiveDemoState();
}

class _InheritanceInteractiveDemoState
    extends State<InheritanceInteractiveDemo> {
  GameCharacter? _selectedCharacter;
  String _log = "Select a character to see their abilities.";

  void _selectCharacter(GameCharacter char) {
    setState(() {
      _selectedCharacter = char;
      _log = "Selected: ${char.name}\n${char.attack()}";
    });
  }

  void _tryAbility(String abilityName, String Function() action) {
    setState(() {
      _log += "\n> ${abilityName}: ${action()}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CharacterButton(
                label: 'Warrior',
                icon: Icons.shield,
                isSelected: _selectedCharacter is Warrior,
                onTap: () => _selectCharacter(Warrior()),
              ),
              _CharacterButton(
                label: 'Mage',
                icon: Icons.auto_fix_high,
                isSelected: _selectedCharacter is Mage,
                onTap: () => _selectCharacter(Mage()),
              ),
              _CharacterButton(
                label: 'Robot',
                icon: Icons.smart_toy,
                isSelected: _selectedCharacter is Robot,
                onTap: () => _selectCharacter(Robot()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Actions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (_selectedCharacter != null) ...[
            Wrap(
              spacing: 8,
              children: [
                // ATTACK (Base Class / Interface)
                ActionChip(
                  label: const Text("Attack"),
                  avatar: const Icon(Icons.flash_on, size: 16),
                  onPressed: () => _tryAbility(
                    _selectedCharacter!.name,
                    _selectedCharacter!.attack,
                  ),
                ),
                // RUN (Mixin)
                if (_selectedCharacter is Runner)
                  ActionChip(
                    label: const Text("Run"),
                    avatar: const Icon(Icons.directions_run, size: 16),
                    backgroundColor: Colors.blue.shade100,
                    onPressed: () => _tryAbility(
                      "Mixin (Runner)",
                      () => (_selectedCharacter as Runner).run(),
                    ),
                  ),
                // SWIM (Mixin)
                if (_selectedCharacter is Swimmer)
                  ActionChip(
                    label: const Text("Swim"),
                    avatar: const Icon(Icons.pool, size: 16),
                    backgroundColor: Colors.blue.shade100,
                    onPressed: () => _tryAbility(
                      "Mixin (Swimmer)",
                      () => (_selectedCharacter as Swimmer).swim(),
                    ),
                  ),
                // FLY (Mixin)
                if (_selectedCharacter is Flyer)
                  ActionChip(
                    label: const Text("Fly"),
                    avatar: const Icon(Icons.flight, size: 16),
                    backgroundColor: Colors.blue.shade100,
                    onPressed: () => _tryAbility(
                      "Mixin (Flyer)",
                      () => (_selectedCharacter as Flyer).fly(),
                    ),
                  ),
              ],
            ),
          ] else
            const Text(
              "Please select a character first.",
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            "Output Log:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.deepPurple,
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
