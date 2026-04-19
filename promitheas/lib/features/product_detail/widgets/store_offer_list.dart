import 'package:flutter/material.dart';

import '../models/store_offer.dart';
import 'store_offer_tile.dart';

class StoreOfferList extends StatelessWidget {
  const StoreOfferList({
    super.key,
    required this.offers,
    required this.bestStoreId,
  });

  final List<StoreOffer> offers;
  final int bestStoreId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < offers.length; i++) ...[
          StoreOfferTile(
            offer: offers[i],
            isBestPrice: offers[i].storeId == bestStoreId,
          ),
          if (i != offers.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}