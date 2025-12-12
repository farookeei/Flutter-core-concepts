import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/lesson_scaffold.dart';

class NavigationLessonPage extends StatelessWidget {
  const NavigationLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Navigation & Routing',
      overview:
          'Modern Flutter navigation with go_router and Navigator 2.0. Learn declarative routing, nested navigation, route guards, deep linking, and state-based routing for production apps.',
      steps: const [
        StepContent(
          title: '1. Navigator 1.0 vs 2.0',
          description:
              'Navigator 1.0 uses imperative push/pop. Navigator 2.0 (declarative) treats navigation as state. '
              'go_router builds on Navigator 2.0, making it easy to use.',
        ),
        StepContent(
          title: '2. Declarative Routing',
          description:
              'Define all routes upfront. The router automatically handles the navigation stack based on the current URL/path.',
          codeSnippet: '''
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfilePage(),
    ),
  ],
);''',
        ),
        StepContent(
          title: '3. Path Parameters',
          description:
              'Extract dynamic values from the URL using :paramName syntax.',
          codeSnippet: '''
GoRoute(
  path: '/user/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId'];
    return UserPage(id: userId);
  },
),''',
        ),
        StepContent(
          title: '4. Nested Navigation (ShellRoute)',
          description:
              'ShellRoute wraps child routes with a persistent UI (like bottom nav). Perfect for tab-based apps.',
          codeSnippet: '''
ShellRoute(
  builder: (context, state, child) {
    return ScaffoldWithNavBar(child: child);
  },
  routes: [
    GoRoute(path: '/home', ...),
    GoRoute(path: '/profile', ...),
  ],
)''',
        ),
        StepContent(
          title: '5. Route Guards & Redirects',
          description:
              'Control access to routes based on auth state. Redirect unauthorized users to login.',
          codeSnippet: '''
GoRouter(
  redirect: (context, state) {
    final isLoggedIn = auth.isLoggedIn;
    if (!isLoggedIn && state.path != '/login') {
      return '/login';
    }
    return null; // No redirect
  },
)''',
        ),
        StepContent(
          title: '6. Deep Linking',
          description:
              'Handle URLs from outside the app (web links, push notifications). go_router automatically parses the path.',
        ),
        StepContent(
          title: '7. Navigation from Code',
          description:
              'Use context.go(), context.push(), context.pop() for programmatic navigation.',
          codeSnippet: '''
// Navigate (replace stack)
context.go('/profile');

// Push (add to stack)
context.push('/settings');

// Pop
context.pop();

// With parameters
context.go('/user/123?tab=posts');''',
        ),
      ],
      demo: const NavigationInteractiveDemo(),
    );
  }
}

// =============================================================================
// INTERACTIVE DEMO
// =============================================================================

class NavigationInteractiveDemo extends StatelessWidget {
  const NavigationInteractiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.navigation, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Launch Demo App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'The demo app showcases:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildFeature(Icons.tab, 'Bottom Navigation with ShellRoute'),
              _buildFeature(Icons.link, 'Deep Linking Examples'),
              _buildFeature(Icons.security, 'Route Guards & Auth'),
              _buildFeature(Icons.storage, 'URL Parameters'),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NavigationDemoApp(),
                    ),
                  );
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Launch Demo App'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

// =============================================================================
// DEMO APP WITH GO_ROUTER
// =============================================================================

class NavigationDemoApp extends StatefulWidget {
  const NavigationDemoApp({super.key});

  @override
  State<NavigationDemoApp> createState() => _NavigationDemoAppState();
}

class _NavigationDemoAppState extends State<NavigationDemoApp> {
  late final GoRouter _router;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/home',
      redirect: (context, state) {
        // Auth Guard
        if (!_isLoggedIn && state.path != '/login') {
          return '/login';
        }
        if (_isLoggedIn && state.path == '/login') {
          return '/home';
        }
        return null;
      },
      routes: [
        // Login Route (no shell)
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(
            onLogin: () {
              setState(() => _isLoggedIn = true);
              context.go('/home');
            },
          ),
        ),

        // Shell Route (with bottom nav)
        ShellRoute(
          builder: (context, state, child) {
            return ScaffoldWithBottomNav(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DemoHomePage(),
            ),
            GoRoute(
              path: '/explore',
              builder: (context, state) => const DemoExplorePage(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => DemoProfilePage(
                onLogout: () {
                  setState(() => _isLoggedIn = false);
                  context.go('/login');
                },
              ),
            ),
          ],
        ),

        // Detail Route (with path parameter)
        GoRoute(
          path: '/item/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '0';
            final name = state.uri.queryParameters['name'] ?? 'Unknown';
            return DemoDetailPage(id: id, name: name);
          },
        ),

        // Settings Route (nested)
        GoRoute(
          path: '/settings',
          builder: (context, state) => const DemoSettingsPage(),
          routes: [
            GoRoute(
              path: 'account',
              builder: (context, state) => const DemoAccountSettingsPage(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Navigation Demo',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}

// =============================================================================
// SCAFFOLD WITH BOTTOM NAV
// =============================================================================

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int selectedIndex = location.startsWith('/explore')
        ? 1
        : location.startsWith('/profile')
        ? 2
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('go_router Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/explore');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// =============================================================================
// DEMO PAGES
// =============================================================================

class LoginPage extends StatelessWidget {
  final VoidCallback onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'You must login to continue',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login),
                label: const Text('Login (Demo)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '💡 This demonstrates route guards\nUnauthorized users are redirected here',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Home Feed'),
        _buildItem(context, '1', 'Flutter Tutorial'),
        _buildItem(context, '2', 'Dart Basics'),
        _buildItem(context, '3', 'State Management'),
        const SizedBox(height: 24),
        _buildInfoCard(
          'Current Route',
          '/home',
          'This is the home page inside a ShellRoute',
          Icons.info,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Deep Link Example',
          '/item/42?name=Example',
          'Tap any item to see path parameters in action',
          Icons.link,
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String id, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(id)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push('/item/$id?name=$title'),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String subtitle,
    String desc,
    IconData icon,
  ) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoExplorePage extends StatelessWidget {
  const DemoExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Explore Categories'),
        _buildCategory('📱 Mobile Development'),
        _buildCategory('🌐 Web Development'),
        _buildCategory('🎨 UI/UX Design'),
        _buildCategory('⚙️  Backend Engineering'),
        const SizedBox(height: 24),
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Navigation Tip',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The bottom nav persists across Home, Explore, and Profile '
                  'thanks to ShellRoute. Try switching tabs - the state is preserved!',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategory(String name) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class DemoProfilePage extends StatelessWidget {
  final VoidCallback onLogout;

  const DemoProfilePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Profile'),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('user@example.com', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Actions'),
        _buildAction(
          context,
          'Settings',
          Icons.settings,
          () => context.push('/settings'),
        ),
        _buildAction(
          context,
          'Logout',
          Icons.logout,
          onLogout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAction(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : null),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : null),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class DemoDetailPage extends StatelessWidget {
  final String id;
  final String name;

  const DemoDetailPage({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔗 Path Parameters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildParam('Route', '/item/:id'),
                  _buildParam('Path Param (id)', id),
                  _buildParam('Query Param (name)', name),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'This page demonstrates extracting parameters from the URL. '
            'The ID comes from the path (/item/42) and the name comes from '
            'the query string (?name=Example).',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildParam(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}

class DemoSettingsPage extends StatelessWidget {
  const DemoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/account'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class DemoAccountSettingsPage extends StatelessWidget {
  const DemoAccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Nested Route Example',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'This page is at /settings/account',
                style: TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demonstrates nested routes in go_router',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
