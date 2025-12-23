import 'package:flutter/material.dart';
import 'core/lesson_config.dart';
import 'lessons/custom_paint_whiteboard.dart';
import 'lessons/render_object_box.dart';
import 'lessons/markdown_playground.dart';
import 'lessons/isolates_demo.dart';
import 'lessons/inheritance_demo.dart';
import 'lessons/di_demo.dart';
import 'lessons/ott_performance_demo.dart';
import 'lessons/objectbox/objectbox_demo.dart';
import 'lessons/security_demo.dart';
import 'lessons/testing_demo.dart';
import 'lessons/navigation_demo.dart';
import 'lessons/background_processing_demo.dart';
import 'lessons/animations_demo.dart';
import 'lessons/analytics_demo.dart';
import 'lessons/shader_demo.dart';
import 'lessons/slivers_advanced_demo.dart';
import 'lessons/gesture_arena_demo.dart';
import 'lessons/ffi_demo.dart';
import 'lessons/secure_storage_practical.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Low-Level Mastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  // Data-Driven Configuration for easy expansion
  static const List<Lesson> lessons = [
    Lesson(
      title: '1. CustomPaint Whiteboard',
      subtitle: 'Learn about CustomPainter, Canvas, and Gestures',
      icon: Icons.draw,
      page: WhiteboardPage(),
    ),
    Lesson(
      title: '2. RenderObject Box',
      subtitle: 'Learn about RenderBox, Layout, and Painting protocols',
      icon: Icons.check_box_outline_blank,
      page: RenderObjectPage(),
    ),
    Lesson(
      title: '3. Markdown TextPainter',
      subtitle: 'Learn about TextPainter and manual text rendering',
      icon: Icons.text_fields,
      page: MarkdownPlaygroundPage(),
    ),
    Lesson(
      title: '4. Isolates & Concurrency',
      subtitle: 'Master the Event Loop, compute(), and background workers',
      icon: Icons.memory,
      page: IsolatesLessonPage(),
    ),
    Lesson(
      title: '5. Inheritance (The Interview)',
      subtitle: 'Extends vs Implements vs Mixins',
      icon: Icons.device_hub,
      page: InheritanceLessonPage(),
    ),
    Lesson(
      title: '6. Dependency Injection',
      subtitle: 'Service Locators & Inversion of Control',
      icon: Icons.power,
      page: DiLessonPage(),
    ),
    Lesson(
      title: '7. OTT Performance',
      subtitle: 'Slivers, RepaintBoundaries & Optimization',
      icon: Icons.speed,
      page: OttPerformanceLessonPage(),
    ),
    Lesson(
      title: '8. ObjectBox DB',
      subtitle: 'High-Performance NoSQL Database',
      icon: Icons.storage,
      page: ObjectBoxLessonPage(),
    ),
    Lesson(
      title: '9. Security Best Practices',
      subtitle: 'Obfuscation, Secure Storage & SSL Pinning',
      icon: Icons.security,
      page: SecurityLessonPage(),
    ),
    Lesson(
      title: '10. Testing & QA',
      subtitle: 'Unit, Widget, Integration & Golden Tests',
      icon: Icons.check_circle,
      page: TestingLessonPage(),
    ),
    Lesson(
      title: '11. Navigation & Routing',
      subtitle: 'go_router, Deep Links & Navigation 2.0',
      icon: Icons.navigation,
      page: NavigationLessonPage(),
    ),
    Lesson(
      title: '12. Background Processing',
      subtitle: 'WorkManager, Foreground Services & Isolates',
      icon: Icons.schedule,
      page: BackgroundProcessingLessonPage(),
    ),
    Lesson(
      title: '13. Animations',
      subtitle: 'Implicit vs Explicit Animations',
      icon: Icons.animation,
      page: AnimationsLessonPage(),
    ),
    Lesson(
      title: '14. User Funnels & Analytics',
      subtitle: 'Abstraction, Events & Visualization',
      icon: Icons.bar_chart,
      page: AnalyticsLessonPage(),
    ),
    Lesson(
      title: '15. Fragment Shaders',
      subtitle: 'GLSL, Uniforms & High-Performance UI',
      icon: Icons.gradient,
      page: ShaderLessonPage(),
    ),
    Lesson(
      title: '16. Advanced Slivers',
      subtitle: 'SliverGeometry, RenderSliver & Parallax',
      icon: Icons.view_week,
      page: SliversAdvancedLessonPage(),
    ),
    Lesson(
      title: '17. Gesture Arena',
      subtitle: 'RawGestureDetector, Claims & Victories',
      icon: Icons.sports_mma,
      page: GestureArenaLessonPage(),
    ),
    Lesson(
      title: '18. FFI & Native Code',
      subtitle: 'dart:ffi, C Interop & Blocking UI',
      icon: Icons.electrical_services,
      page: FfiLessonPage(),
    ),
    Lesson(
      title: '19. Secure Storage In-Depth',
      subtitle: 'Production Auth Service & Key Management',
      icon: Icons.vpn_key,
      page: SecureStorageProductionLesson(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Mastery Modules')),
      body: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                lesson.icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                lesson.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(lesson.subtitle),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => lesson.page),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
