// lib/pages/training_page.dart
import 'package:flutter/material.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Training (coming soon)', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
