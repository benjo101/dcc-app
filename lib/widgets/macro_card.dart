// lib/widgets/macro_card.dart
import 'package:flutter/material.dart';

class MacroCard extends StatelessWidget {
  final String title;
  final String value;
  final String target;
  final double progress;
  final bool isKcal;

  const MacroCard({
    super.key,
    required this.title,
    required this.value,
    required this.target,
    required this.progress,
    this.isKcal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(target,
                style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFD347),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
