import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';

import '../models/evacuation_route.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/error_state_view.dart';
import '../widgets/empty_state_view.dart';

/// Tab Rute Evakuasi — Professional Edition with OpenStreetMap.
class EvacuationScreen extends ConsumerStatefulWidget {
  const EvacuationScreen({super.key});

  @override
  ConsumerState<EvacuationScreen> createState() => _EvacuationScreenState();
}

class _EvacuationScreenState extends ConsumerState<EvacuationScreen>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  bool _showRouteSteps = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animateToLocation(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 13.5);
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(evacuationRoutesProvider);
    final selectedIndex = ref.watch(selectedEvacuationIndexProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.ewsColors.statusAwas.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.ewsColors.statusAwas.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.emergency_rounded,
                  size: 18,
                  color: context.ewsColors.statusAwas,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rute Evakuasi',
                    style: context.headingSmall.copyWith(
                      fontSize: 15,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Pilih lokasi & lihat rute',
                    style: context.caption.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: routesAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: context.ewsColors.accent),
          ),
          error: (error, _) => ErrorStateView(
            error: error,
            onRetry: () => ref.invalidate(evacuationRoutesProvider),
          ),
          data: (routes) {
            if (routes.isEmpty) {
              return const EmptyStateView(
                icon: Icons.directions_off_rounded,
                title: 'Belum Ada Rute Evakuasi',
                subtitle: 'Data rute evakuasi belum tersedia saat ini.',
              );
            }

            final safeIndex = selectedIndex.clamp(0, routes.length - 1);
            final currentRoute = routes[safeIndex];

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(evacuationRoutesProvider);
              },
              color: context.ewsColors.accent,
              backgroundColor: context.ewsColors.bgCard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Banner Darurat ---
                    _EmergencyBanner(),

                    const SizedBox(height: 16),

                    // --- Location Selector ---
                    _LocationSelector(
                      routes: routes,
                      selectedIndex: safeIndex,
                      onSelected: (index) {
                        ref.read(selectedEvacuationIndexProvider.notifier).state = index;
                        _animateToLocation(
                          routes[index].latitude,
                          routes[index].longitude,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // --- Peta OpenStreetMap ---
                    _MapSection(
                      route: currentRoute,
                      mapController: _mapController,
                    ),

                    const SizedBox(height: 16),

                    // --- Destination Info Card ---
                    _DestinationCard(route: currentRoute),

                    const SizedBox(height: 16),

                    // --- Route Steps Toggle ---
                    _RouteStepsSection(
                      route: currentRoute,
                      isExpanded: _showRouteSteps,
                      onToggle: () {
                        setState(() => _showRouteSteps = !_showRouteSteps);
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- Section Header Kontak ---
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: context.ewsColors.statusAwas,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('KONTAK DARURAT', style: context.label),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // --- Kontak Darurat List ---
                    ...currentRoute.emergencyContacts
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ContactCard(
                                contact: entry.value,
                                index: entry.key,
                              ),
                            )),

                    const SizedBox(height: 20),

                    // --- Tombol Navigasi ---
                    _NavigationButton(route: currentRoute),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// LOCATION SELECTOR — Horizontal Scroll Chips
// =============================================================================

class _LocationSelector extends StatelessWidget {
  final List<EvacuationRoute> routes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _LocationSelector({
    required this.routes,
    required this.selectedIndex,
    required this.onSelected,
  });

  IconData _iconForType(LocationType type) {
    switch (type) {
      case LocationType.lapangan:
        return Icons.sports_soccer_rounded;
      case LocationType.balaiDesa:
        return Icons.account_balance_rounded;
      case LocationType.sekolah:
        return Icons.school_rounded;
      case LocationType.puskesmas:
        return Icons.local_hospital_rounded;
      case LocationType.posko:
        return Icons.emergency_rounded;
      case LocationType.masjid:
        return Icons.mosque_rounded;
      case LocationType.gedung:
        return Icons.business_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: context.ewsColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text('PILIH LOKASI EVAKUASI', style: context.label),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.ewsColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.ewsColors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '${routes.length} lokasi',
                style: context.caption.copyWith(
                  fontSize: 9,
                  color: context.ewsColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: routes.length,
            separatorBuilder: (context, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final route = routes[index];
              final isSelected = index == selectedIndex;

              return GestureDetector(
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.ewsColors.accent.withValues(alpha: 0.12)
                        : context.ewsColors.glassBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: isSelected
                          ? context.ewsColors.accent.withValues(alpha: 0.5)
                          : context.ewsColors.glassBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: context.ewsColors.accent.withValues(alpha: 0.15),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.ewsColors.accent.withValues(alpha: 0.2)
                                  : context.ewsColors.textTertiary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _iconForType(route.locationType),
                              size: 16,
                              color: isSelected
                                  ? context.ewsColors.accent
                                  : context.ewsColors.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: context.ewsColors.accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.ewsColors.accent.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.destination,
                            style: context.bodyMedium.copyWith(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? context.ewsColors.textPrimary
                                  : context.ewsColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            route.distance,
                            style: context.caption.copyWith(
                              fontSize: 9,
                              color: isSelected
                                  ? context.ewsColors.accent
                                  : context.ewsColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MAP SECTION — OpenStreetMap with flutter_map
// =============================================================================

class _MapSection extends ConsumerWidget {
  final EvacuationRoute route;
  final MapController mapController;

  const _MapSection({
    required this.route,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocationAsync = ref.watch(userLocationProvider);
    final routePoints = route.routeCoordinates
        .map((c) => LatLng(c[0], c[1]))
        .toList();

    final destinationLatLng = LatLng(route.latitude, route.longitude);
    
    LatLng? userLatLng;
    userLocationAsync.whenData((position) {
      userLatLng = LatLng(position.latitude, position.longitude);
    });

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Map Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 16,
                  color: context.ewsColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'PETA RUTE EVAKUASI',
                  style: context.label.copyWith(
                    color: context.ewsColors.accent.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.ewsColors.statusNormal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: context.ewsColors.statusNormal.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: context.ewsColors.statusNormal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'OpenStreetMap',
                        style: context.caption.copyWith(
                          fontSize: 8,
                          color: context.ewsColors.statusNormal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Map Widget
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.radiusM),
              bottomRight: Radius.circular(AppTheme.radiusM),
            ),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: userLatLng ?? destinationLatLng,
                  initialZoom: userLatLng != null ? 14.0 : 13.0,
                  minZoom: 10,
                  maxZoom: 18,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  backgroundColor: context.ewsColors.bgDark,
                ),
                children: [
                  // Light tile layer (CartoDB Light)
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.ews.semeru',
                    maxZoom: 20,
                    retinaMode: true,
                  ),

                  // Route polyline
                  if (routePoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          color: context.ewsColors.accent.withValues(alpha: 0.8),
                          strokeWidth: 4.0,
                          borderColor: context.ewsColors.accent.withValues(alpha: 0.3),
                          borderStrokeWidth: 2.0,
                        ),
                      ],
                    ),

                  // Markers
                  MarkerLayer(
                    markers: [
                      // User position marker
                      if (userLatLng != null)
                        Marker(
                          point: userLatLng!,
                          width: 40,
                          height: 40,
                          child: _UserMarker(),
                        ),

                      // Destination marker
                      Marker(
                        point: destinationLatLng,
                        width: 44,
                        height: 52,
                        child: _DestinationMarker(
                          type: route.locationType,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Location Button Panel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.ewsColors.bgDark.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(color: context.ewsColors.glassBorder, width: 1),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusM),
                bottomRight: Radius.circular(AppTheme.radiusM),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: userLocationAsync.when(
                    data: (position) => Text(
                      'Lokasi Anda Akurat (${position.accuracy.toStringAsFixed(0)}m)',
                      style: context.caption.copyWith(
                        color: context.ewsColors.secondary,
                        fontSize: 11,
                      ),
                    ),
                    loading: () => Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            color: context.ewsColors.secondary,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mencari sinyal GPS...',
                          style: context.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    error: (error, _) => Text(
                      error.toString().replaceAll('Exception: ', ''),
                      style: context.caption.copyWith(
                        color: const Color(0xFFFF6B6B),
                        fontSize: 10,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.invalidate(userLocationProvider);
                    if (userLatLng != null) {
                      mapController.move(userLatLng!, 14.0);
                    }
                  },
                  icon: Icon(
                    Icons.my_location_rounded,
                    size: 14,
                    color: context.ewsColors.secondary,
                  ),
                  label: Text(
                    'Lacak Saya',
                    style: context.label.copyWith(
                      color: context.ewsColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: context.ewsColors.secondary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Marker posisi user di peta.
class _UserMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse ring
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.ewsColors.secondary.withValues(alpha: 0.15),
            border: Border.all(
              color: context.ewsColors.secondary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        // Inner dot
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.ewsColors.secondary,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: context.ewsColors.secondary.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Marker titik kumpul di peta.
class _DestinationMarker extends StatelessWidget {
  final LocationType type;

  const _DestinationMarker({required this.type});

  IconData _iconForType(LocationType type) {
    switch (type) {
      case LocationType.lapangan:
        return Icons.sports_soccer_rounded;
      case LocationType.balaiDesa:
        return Icons.account_balance_rounded;
      case LocationType.sekolah:
        return Icons.school_rounded;
      case LocationType.puskesmas:
        return Icons.local_hospital_rounded;
      case LocationType.posko:
        return Icons.emergency_rounded;
      case LocationType.masjid:
        return Icons.mosque_rounded;
      case LocationType.gedung:
        return Icons.business_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: context.ewsColors.statusNormal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: context.ewsColors.statusNormal.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            _iconForType(type),
            size: 18,
            color: Colors.white,
          ),
        ),
        // Pin triangle
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTrianglePainter(color: context.ewsColors.statusNormal),
        ),
      ],
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  _PinTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// EMERGENCY BANNER
// =============================================================================

/// Banner peringatan darurat di bagian atas.
class _EmergencyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.ewsColors.statusAwas.withValues(alpha: 0.15),
            context.ewsColors.statusSiaga.withValues(alpha: 0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: context.ewsColors.statusAwas.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.ewsColors.statusAwas.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 22,
              color: context.ewsColors.statusAwas,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ikuti Instruksi Petugas',
                  style: context.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.ewsColors.statusAwas,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Segera menuju titik kumpul jika status level 4 atau AWAS.',
                  style: context.bodyMedium.copyWith(
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DESTINATION CARD
// =============================================================================

/// Card titik kumpul utama dengan info lengkap.
class _DestinationCard extends StatelessWidget {
  final EvacuationRoute route;

  const _DestinationCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Baris atas: icon + label
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.ewsColors.statusNormal.withValues(alpha: 0.3),
                      context.ewsColors.statusNormal.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.ewsColors.statusNormal.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 28,
                  color: context.ewsColors.statusNormal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TITIK KUMPUL',
                          style: context.label.copyWith(
                            color: context.ewsColors.statusNormal.withValues(alpha: 0.7),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: context.ewsColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            route.locationType.displayName,
                            style: context.caption.copyWith(
                              fontSize: 8,
                              color: context.ewsColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route.destination,
                      style: context.headingMedium.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Deskripsi
          if (route.description.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.ewsColors.bgMid.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                route.description,
                style: context.bodyMedium.copyWith(
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Divider
          Container(
            height: 1,
            color: context.ewsColors.divider,
          ),

          const SizedBox(height: 14),

          // Jarak, estimasi & kapasitas
          Row(
            children: [
              Expanded(
                child: _MetricChip(
                  icon: Icons.route_rounded,
                  label: 'Jarak',
                  value: route.distance,
                  color: context.ewsColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricChip(
                  icon: Icons.access_time_rounded,
                  label: 'Estimasi',
                  value: route.estimate,
                  color: context.ewsColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricChip(
                  icon: Icons.people_rounded,
                  label: 'Kapasitas',
                  value: '${route.capacity} org',
                  color: const Color(0xFF8B7CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ROUTE STEPS SECTION
// =============================================================================

class _RouteStepsSection extends StatelessWidget {
  final EvacuationRoute route;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _RouteStepsSection({
    required this.route,
    required this.isExpanded,
    required this.onToggle,
  });

  IconData _directionIcon(StepDirection direction) {
    switch (direction) {
      case StepDirection.straight:
        return Icons.arrow_upward_rounded;
      case StepDirection.left:
        return Icons.turn_left_rounded;
      case StepDirection.right:
        return Icons.turn_right_rounded;
      case StepDirection.slightLeft:
        return Icons.turn_slight_left_rounded;
      case StepDirection.slightRight:
        return Icons.turn_slight_right_rounded;
      case StepDirection.destination:
        return Icons.flag_rounded;
    }
  }

  Color _directionColor(BuildContext context, StepDirection direction) {
    switch (direction) {
      case StepDirection.destination:
        return context.ewsColors.statusNormal;
      case StepDirection.left:
      case StepDirection.slightLeft:
        return context.ewsColors.secondary;
      case StepDirection.right:
      case StepDirection.slightRight:
        return const Color(0xFFFFA726);
      case StepDirection.straight:
        return context.ewsColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (route.routeSteps.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Toggle header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.ewsColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_rounded,
                      size: 18,
                      color: context.ewsColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Langkah Navigasi',
                          style: context.bodyLarge.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${route.routeSteps.length} langkah',
                          style: context.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.ewsColors.textTertiary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Steps list (animated)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: route.routeSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == route.routeSteps.length - 1;
                  final color = _directionColor(context, step.direction);

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline column
                        SizedBox(
                          width: 36,
                          child: Column(
                            children: [
                              // Circle icon
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  _directionIcon(step.direction),
                                  size: 14,
                                  color: color,
                                ),
                              ),
                              // Connecting line
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.ewsColors.divider,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: isLast ? 0 : 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.instruction,
                                  style: context.bodyMedium.copyWith(
                                    fontSize: 12,
                                    color: isLast
                                        ? context.ewsColors.statusNormal
                                        : context.ewsColors.textPrimary,
                                    fontWeight: isLast
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (step.distance != '0 m') ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    step.distance,
                                    style: context.caption.copyWith(
                                      fontSize: 10,
                                      color: color.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// METRIC CHIP
// =============================================================================

/// Chip metrik kecil.
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: context.caption.copyWith(
              fontSize: 9,
              color: context.ewsColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.bodyMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CONTACT CARD
// =============================================================================

/// Card kontak darurat.
class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final int index;

  const _ContactCard({required this.contact, required this.index});

  static const _colors = [
    Color(0xFF4A9EFF),
    Color(0xFF00D4AA),
    Color(0xFFFF8C42),
    Color(0xFF8B7CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      blurSigma: 6,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(Icons.phone_rounded, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: context.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  contact.phone,
                  style: context.bodyMedium.copyWith(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Panggil button
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse('tel:${contact.phone}');
              try {
                await launchUrl(uri);
              } catch (e) {
                debugPrint('Could not launch phone dialer: $e');
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.call_rounded,
                size: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NAVIGATION BUTTON
// =============================================================================

/// Tombol buka peta navigasi (Google Maps / OSM).
class _NavigationButton extends StatelessWidget {
  final EvacuationRoute route;

  const _NavigationButton({required this.route});

  Future<void> _openNavigation(BuildContext context) async {
    // Coba buka Google Maps terlebih dahulu
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${route.latitude},${route.longitude}'
      '&travelmode=walking',
    );

    // Fallback: OpenStreetMap
    final osmUrl = Uri.parse(
      'https://www.openstreetmap.org/directions?'
      'engine=fossgis_osrm_foot'
      '&route=-8.2150,112.9350;${route.latitude},${route.longitude}',
    );

    final success = await launchUrl(
      googleMapsUrl, 
      mode: LaunchMode.externalApplication,
    );
    
    if (!success) {
      await launchUrl(
        osmUrl, 
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.ewsColors.accent,
            context.ewsColors.accentDim,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: context.accentGlowShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openNavigation(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Buka Navigasi ke ${route.destination}',
                  style: context.bodyLarge.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
