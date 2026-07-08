import 'package:flutter/material.dart';

class TimelineBar extends StatelessWidget {
  final double progress;

  const TimelineBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF173723),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF2ECC71),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '0’',
              style: smallMutedStyle,
            ),
            Text(
              '45’',
              style: smallMutedStyle,
            ),
            Text(
              '90’',
              style: smallMutedStyle,
            ),
          ],
        ),
      ],
    );
  }
}

const smallMutedStyle = TextStyle(
  color: Color(0xFF8FB89C),
  fontSize: 10.5,
  fontWeight: FontWeight.w800,
);
