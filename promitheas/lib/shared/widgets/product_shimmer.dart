import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({
    super.key,
    this.width = 170,
    this.imageHeight = 132,
  });

  final double width;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFE5E5EA),
          highlightColor: const Color(0xFFF2F2F7),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  color: const Color(0xFFE5E5EA),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 100, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(height: 18, width: 85, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
