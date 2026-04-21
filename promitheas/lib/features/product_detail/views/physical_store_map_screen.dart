import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/physical_store_location.dart';

class PhysicalStoreMapScreen extends StatefulWidget {
  const PhysicalStoreMapScreen({
    super.key,
    required this.locations,
    required this.productName,
  });

  final List<PhysicalStoreLocation> locations;
  final String productName;

  @override
  State<PhysicalStoreMapScreen> createState() => _PhysicalStoreMapScreenState();
}

class _PhysicalStoreMapScreenState extends State<PhysicalStoreMapScreen> {
  final MapController _mapController = MapController();

  String _selectedStoreFilter = 'All';

  bool _locationEnabled = false;
  bool _locationPermissionGranted = false;

  List<PhysicalStoreLocation> get _filteredLocations {
    return widget.locations.where((location) {
      return _selectedStoreFilter == 'All' ||
          location.storeName == _selectedStoreFilter;
    }).toList();
  }

  List<String> get _storeOptions =>
      ['All', ...{...widget.locations.map((e) => e.storeName)}];

  @override
  void initState() {
    super.initState();
    _checkLocationState();
  }

  Future<void> _checkLocationState() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!mounted) return;

    setState(() {
      _locationEnabled = serviceEnabled;
      _locationPermissionGranted =
          permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse;
    });
  }

  Future<void> _goToMyLocation() async {
    final position = await Geolocator.getCurrentPosition();
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      14,
    );
  }

  Future<void> _openInDeviceMaps(PhysicalStoreLocation location) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _showLocationDetails(PhysicalStoreLocation location) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _LocationDetailsSheet(
        location: location,
        onOpenMaps: () => _openInDeviceMaps(location),
      ),
    );
  }

  LatLng _computeCenter(List<PhysicalStoreLocation> points) {
    if (points.isEmpty) return const LatLng(40.4168, -3.7038);
    if (points.length == 1) {
      return LatLng(points.first.latitude, points.first.longitude);
    }

    final avgLat =
        points.map((e) => e.latitude).reduce((a, b) => a + b) / points.length;
    final avgLng =
        points.map((e) => e.longitude).reduce((a, b) => a + b) / points.length;

    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredLocations = _filteredLocations;
    final center = _computeCenter(
      filteredLocations.isEmpty ? widget.locations : filteredLocations,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _MapTopBar(productName: widget.productName),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      value: _selectedStoreFilter,
                      items: _storeOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedStoreFilter = value);
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom:
                          filteredLocations.length <= 1 ? 13 : 6,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.promitheas.app',
                      ),
                      if (_locationEnabled && _locationPermissionGranted)
                        const CurrentLocationLayer(),
                      MarkerLayer(
                        markers: filteredLocations.map((location) {
                          return Marker(
                            point: LatLng(
                                location.latitude, location.longitude),
                            width: 36,
                            height: 36,
                            child: GestureDetector(
                              onTap: () =>
                                  _showLocationDetails(location),
                              child: _StoreMarker(
                                logoUrl: location.storeLogoUrl,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  if (filteredLocations.isEmpty)
                    Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No stores match the selected filters.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      onPressed: _goToMyLocation,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Store',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
class _MapTopBar extends StatelessWidget {
  const _MapTopBar({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              productName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
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
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: ClipOval(
        child: logoUrl.isEmpty
            ? Icon(
                Icons.storefront_outlined,
                color: theme.colorScheme.primary,
                size: 16,
              )
            : CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class _LocationDetailsSheet extends StatelessWidget {
  const _LocationDetailsSheet({
    required this.location,
    required this.onOpenMaps,
  });

  final PhysicalStoreLocation location;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedule = location.schedule ?? const <String, dynamic>{};

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: theme.colorScheme.surfaceContainerHighest,
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
                    child: Text(
                      location.storeName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _InfoRow(
                icon: Icons.place_outlined,
                label: 'Address',
                value: location.subtitle.isEmpty
                    ? 'Location available'
                    : location.subtitle,
              ),
              if (location.phone.trim().isNotEmpty)
                _InfoRow(
                  icon: Icons.call_outlined,
                  label: 'Phone',
                  value: location.phone,
                ),
              if (location.rating != null)
                _InfoRow(
                  icon: Icons.star_outline,
                  label: 'Rating',
                  value: location.ratingCount == null
                      ? location.rating!.toStringAsFixed(1)
                      : '${location.rating!.toStringAsFixed(1)} (${location.ratingCount} reviews)',
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onOpenMaps,
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('Open in Maps'),
              ),
              const SizedBox(height: 16),
              Text(
                'Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (schedule.isEmpty)
                Text(
                  'No schedule available.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ...schedule.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}