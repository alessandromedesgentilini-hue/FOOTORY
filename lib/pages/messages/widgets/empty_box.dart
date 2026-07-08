import 'package:flutter/material.dart';
import 'package:footory26/core/app_colors.dart';

class EmptyBox extends StatelessWidget {
  final String text;

  const EmptyBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text),
    );
  }
}
