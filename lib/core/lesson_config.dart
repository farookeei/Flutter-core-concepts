import 'package:flutter/material.dart';

class Lesson {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;

  const Lesson({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });
}
