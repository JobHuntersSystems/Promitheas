import 'package:flutter/material.dart';
import 'package:promitheas/core/theme/app_colors.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconAsset,
  }) : assert(icon != null || iconAsset != null, 'Debe proporcionar icon o iconAsset');

  final String title;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconAsset != null ? Colors.transparent : AppColors.primaryFire,
              borderRadius: BorderRadius.circular(6),
            ),
            child: iconAsset != null
                ? Image.asset(iconAsset!, width: 28, height: 28)
                : Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
