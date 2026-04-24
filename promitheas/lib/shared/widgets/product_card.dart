import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:promitheas/shared/models/product_summary.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width = 170,
    this.imageHeight = 132,
    this.showSectionTag = false,
  });

  final ProductSummary product;
  final VoidCallback onTap;
  final double width;
  final double imageHeight;
  final bool showSectionTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7E7EC)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductCardImage(
                  imageUrl: product.imageUrl,
                  imageHeight: imageHeight,
                  discountPercent: product.discountPercent,
                  sectionTag: showSectionTag ? product.sectionTag : null,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: const Color(0xFF17171A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (product.storeName != null &&
                          product.storeName!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            product.storeName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: const Color.fromARGB(255, 101, 101, 104),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                     Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.currentPrice.toStringAsFixed(2)} €',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),

                        if (product.hasDiscount) ...[
                          const SizedBox(height: 2),
                          Text(  
                            '${product.previousPrice!.toStringAsFixed(2)} €',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF8E8E93),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: const Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ],
                    )
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

class _ProductCardImage extends StatelessWidget {
  const _ProductCardImage({
    required this.imageUrl,
    required this.imageHeight,
    required this.discountPercent,
    required this.sectionTag,
  });

  final String imageUrl;
  final double imageHeight;
  final double? discountPercent;
  final String? sectionTag;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          Container(
            height: imageHeight,
            width: double.infinity,
            color: const Color.fromARGB(255, 255, 255, 255),
            child: imageUrl.trim().isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 30,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: const Color(0xFFE5E5EA),
                      highlightColor: const Color(0xFFF2F2F7),
                      child: Container(
                        height: imageHeight,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 30,
                      ),
                    ),
                  ),
          ),
          if (discountPercent != null)
            Positioned(
              top: 10,
              left: 10,
              child: _Pill(
                label: '-${discountPercent!.round()}%',
                backgroundColor: const Color(0xFFDC2626),
                textColor: Colors.white,
              ),
            ),
          if (sectionTag != null && sectionTag!.trim().isNotEmpty)
            Positioned(
              top: 10,
              right: 10,
              child: _Pill(
                label: sectionTag!,
                backgroundColor: Colors.white,
                textColor: const Color(0xFF111827),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
