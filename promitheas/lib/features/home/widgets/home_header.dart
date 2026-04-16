import 'package:flutter/material.dart';
import 'package:promitheas/shared/models/product_summary.dart';
import 'package:promitheas/shared/widgets/product_card.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader();

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
              color: const Color(0xFFE8651A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'PROMITHEAS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }
}
