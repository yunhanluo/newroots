import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/brand_colors.dart';

const kMapMinZoom = 5.0;
const kMapMaxZoom = 18.0;

/// A tappable pin on a [FinderMap]. Taps are resolved on the map itself so
/// the pin widget does not steal pan, pinch, or scroll-zoom.
class FinderMapPin {
  const FinderMapPin({
    required this.point,
    required this.onTap,
    this.selected = false,
  });

  final LatLng point;
  final VoidCallback onTap;
  final bool selected;
}

/// Shared OSM map used by Education, Healthcare, and English Learning.
///
/// Scroll-zoom is handled here (not by flutter_map) so trackpads on web get a
/// usable step size, and so the results list below cannot eat the wheel while
/// the pointer is over the map. +/- buttons are a fallback when gestures miss.
class FinderMap extends StatelessWidget {
  const FinderMap({
    super.key,
    required this.controller,
    required this.center,
    required this.initialZoom,
    required this.badge,
    this.searchCenter,
    this.pins = const [],
  });

  final MapController controller;
  final LatLng center;
  final double initialZoom;
  final String badge;
  final LatLng? searchCenter;
  final List<FinderMapPin> pins;

  static final _interaction = InteractionOptions(
    flags:
        InteractiveFlag.all &
        ~InteractiveFlag.rotate &
        ~InteractiveFlag.scrollWheelZoom,
    cursorKeyboardRotationOptions: CursorKeyboardRotationOptions.disabled(),
  );

  void _zoomBy(double delta, {Offset? cursor}) {
    final camera = controller.camera;
    final newZoom = (camera.zoom + delta).clamp(kMapMinZoom, kMapMaxZoom);
    if (newZoom == camera.zoom) return;
    final newCenter = cursor == null
        ? camera.center
        : camera.focusedZoomCenter(cursor, newZoom);
    controller.move(newCenter, newZoom);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (event.scrollDelta.dy == 0) return;
    // Claim the wheel so a sibling ListView cannot scroll instead.
    GestureBinding.instance.pointerSignalResolver.register(event, (resolved) {
      final scroll = resolved as PointerScrollEvent;
      final dy = scroll.scrollDelta.dy;
      // Mouse wheels send large ticks; Mac trackpads send tiny pixel deltas.
      final velocity = kIsWeb && dy.abs() < 40 ? 0.02 : 0.008;
      _zoomBy(-dy * velocity, cursor: scroll.localPosition);
    });
  }

  void _onMapTap(TapPosition tap, LatLng _) {
    final relative = tap.relative;
    if (relative == null || pins.isEmpty) return;
    final camera = controller.camera;
    FinderMapPin? nearest;
    var bestDistance = 28.0;
    for (final pin in pins) {
      final distance = (camera.getOffsetFromOrigin(pin.point) - relative)
          .distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        nearest = pin;
      }
    }
    nearest?.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: Stack(
        children: [
          FlutterMap(
            mapController: controller,
            options: MapOptions(
              initialCenter: center,
              initialZoom: initialZoom,
              minZoom: kMapMinZoom,
              maxZoom: kMapMaxZoom,
              interactionOptions: _interaction,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'org.newroots.california',
              ),
              MarkerLayer(
                markers: [
                  if (searchCenter != null)
                    Marker(
                      point: searchCenter!,
                      width: 36,
                      height: 36,
                      child: const IgnorePointer(
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                    ),
                  for (final pin in pins)
                    Marker(
                      point: pin.point,
                      width: 40,
                      height: 40,
                      child: IgnorePointer(
                        child: Icon(
                          Icons.location_on,
                          size: 36,
                          color: pin.selected ? Colors.redAccent : kBrandGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBrandGreen.withValues(alpha: 0.25)),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kBrandGreen,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Material(
              color: Colors.white.withValues(alpha: 0.95),
              elevation: 1,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Zoom in',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _zoomBy(1),
                    icon: const Icon(Icons.add, color: kBrandGreen),
                  ),
                  Divider(
                    height: 1,
                    color: kBrandGreen.withValues(alpha: 0.2),
                  ),
                  IconButton(
                    tooltip: 'Zoom out',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _zoomBy(-1),
                    icon: const Icon(Icons.remove, color: kBrandGreen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
