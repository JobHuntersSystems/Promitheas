import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../views/physical_store_map_screen.dart';
import '../models/physical_store_location.dart';

class PhysicalStoreMapCard extends StatelessWidget {
  const PhysicalStoreMapCard({
    super.key,
    required this.locations,
  });

  final List<PhysicalStoreLocation> locations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (locations.isEmpty) {
      return _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physical stores',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This product has no associated physical stores.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final center = _computeCenter(locations);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stores',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: locations.length == 1 ? 13 : 6,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.promitheas.app',
                  ),
                  MarkerLayer(
                    markers: locations.map((location) {
                      return Marker(
                        point: LatLng(location.latitude, location.longitude),
                        width: 44,
                        height: 44,
                        child: _StoreMarker(
                          logoUrl: location.storeLogoUrl,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PhysicalStoreMapScreen(
                      locations: locations,
                      productName: 'Stores',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_full),
              label: const Text('Expand map'),
            ),
          ),
          Column(
            children: [
              for (int i = 0; i < locations.length; i++) ...[
                _StoreLocationTile(location: locations[i]),
                if (i != locations.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ],
      ),
    );
  }

  LatLng _computeCenter(List<PhysicalStoreLocation> points) {
    if (points.length == 1) {
      return LatLng(points.first.latitude, points.first.longitude);
    }

    final avgLat =
        points.map((e) => e.latitude).reduce((a, b) => a + b) / points.length;
    final avgLng =
        points.map((e) => e.longitude).reduce((a, b) => a + b) / points.length;

    return LatLng(avgLat, avgLng);
  }
}

class _StoreMarker extends StatelessWidget {
  const _StoreMarker({
    required this.logoUrl,
  });

  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipOval(
        child: logoUrl.isEmpty
            ? Icon(
                Icons.storefront_outlined,
                color: theme.colorScheme.primary,
                size: 18,
              )
            : CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class _StoreLocationTile extends StatelessWidget {
  const _StoreLocationTile({
    required this.location,
  });

  final PhysicalStoreLocation location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              color: theme.colorScheme.surface,
              child: location.storeLogoUrl.isEmpty
                  ? const Icon(Icons.storefront_outlined)
                  : CachedNetworkImage(
                      imageUrl: location.storeLogoUrl,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.storeName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location.subtitle.isEmpty
                      ? 'Store location available'
                      : location.subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}