import 'package:flutter/material.dart';

class SoundLevelVisualizer extends StatelessWidget {
  final double level; // 0.0 - 1.0 arasında normalize edilmiş ses seviyesi

  const SoundLevelVisualizer({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(level.clamp(0.0, 1.0)),
      ),
      child: Center(
        child: Text('${(level * 100).toInt()}%', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
