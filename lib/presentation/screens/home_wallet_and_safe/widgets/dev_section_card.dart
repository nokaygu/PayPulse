import 'package:flutter/material.dart';

class DevSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  const DevSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

