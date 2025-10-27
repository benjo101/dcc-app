// lib/widgets/macro_card.dart
import 'package:flutter/material.dart';

class MacroCard extends StatelessWidget {
  final String title;     // Protein / Carbs / Fat / KCAL
  final String value;     // t.ex. "90g" / "1200"
  final String target;    // t.ex. "180g" / "2400"
  final double progress;  // 0..1
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Text('/ $target',
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 10,
                backgroundColor: const Color(0xFFEFF1F6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isKcal ? cs.primary : cs.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
