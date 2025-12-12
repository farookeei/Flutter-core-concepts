import 'package:flutter/material.dart';

class LessonScaffold extends StatelessWidget {
  final String title;
  final String overview;
  final List<StepContent> steps;
  final Widget demo;

  const LessonScaffold({
    super.key,
    required this.title,
    required this.overview,
    required this.steps,
    required this.demo,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Learn'),
              Tab(icon: Icon(Icons.play_circle_filled), text: 'Play'),
            ],
          ),
        ),
        body: TabBarView(
          physics:
              const NeverScrollableScrollPhysics(), // Prevent accidental swipes
          children: [
            // Tab 1: The Educational Content
            _buildGuideTab(context),
            // Tab 2: The Interactive Demo
            demo,
          ],
        ),
      ),
    );
  }

  Widget _buildGuideTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(overview, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        ...steps.map((step) => _buildStepCard(context, step)),
        const SizedBox(height: 40),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text("Go to Demo"),
            onPressed: () {
              DefaultTabController.of(context).animateTo(1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, StepContent step) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(step.description),
            if (step.codeSnippet != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step.codeSnippet!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.lightGreenAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StepContent {
  final String title;
  final String description;
  final String? codeSnippet;

  const StepContent({
    required this.title,
    required this.description,
    this.codeSnippet,
  });
}
