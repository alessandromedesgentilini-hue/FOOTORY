import 'package:flutter/material.dart';

class WaitingMatch extends StatelessWidget {
  const WaitingMatch({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2ECC71),
          ),
          SizedBox(height: 16),
          Text(
            'A transmissão está começando...',
            style: TextStyle(
              color: Color(0xFFB7F7CE),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
