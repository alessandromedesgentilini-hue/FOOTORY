import 'package:flutter/material.dart';

class MomentumBar extends StatelessWidget {
  final String homeClubName;
  final String awayClubName;
  final double homeMomentum;

  const MomentumBar({
    super.key,
    required this.homeClubName,
    required this.awayClubName,
    required this.homeMomentum,
  });

  @override
  Widget build(BuildContext context) {
    final homeValue = homeMomentum.clamp(0.18, 0.82);
    final awayValue = 1 - homeValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MOMENTUM DA PARTIDA',
          style: TextStyle(
            color: Color(0xFFB7F7CE),
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: (homeValue * 100).round(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF2ECC71),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(999),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: (awayValue * 100).round(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF244B35),
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
