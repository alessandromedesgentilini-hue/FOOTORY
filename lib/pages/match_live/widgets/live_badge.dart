import 'package:flutter/material.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: Color(0xFF2ECC71),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        const Text(
          'AO VIVO',
          style: TextStyle(
            color: Color(0xFFB7F7CE),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
