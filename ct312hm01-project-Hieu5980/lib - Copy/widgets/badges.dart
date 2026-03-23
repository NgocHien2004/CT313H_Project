import 'package:flutter/material.dart';
import '../Themes/app_colors.dart';

class Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color color;

  const Badge({
    super.key,
    required this.text,
    required this.bg,
    required this.color,
  });

  factory Badge.success(String text) => Badge(
    text: text,
    bg: AppColors.badgeSuccessBg,
    color: AppColors.badgeSuccessText,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ).copyWith(color: color),
      ),
    );
  }
}
