import 'package:flutter/material.dart';

class MyfinModule {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final List<String> keywords;

  const MyfinModule({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.keywords = const [],
  });
}
