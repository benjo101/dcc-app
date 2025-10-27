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
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: const Color(0xFF1C1C1C),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                Text('/ $target',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isKcal ? cs.primary : const Color(0xFFFFD347),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

