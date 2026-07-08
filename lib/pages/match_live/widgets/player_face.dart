import 'package:flutter/material.dart';

class PlayerFace extends StatelessWidget {
  final String assetPath;
  final double size;

  const PlayerFace({
    super.key,
    required this.assetPath,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.26),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF183824),
              borderRadius: BorderRadius.circular(size * 0.26),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFFB7F7CE),
            ),
          );
        },
      ),
    );
  }
}
