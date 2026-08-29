import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/health_center.dart';
import '../../../core/services/health_center_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../core/widgets/finder_controls.dart';
import '../../../core/widgets/finder_map.dart';

/// Map + list of nearby HRSA community health centers.
class FindClinicsScreen extends ConsumerStatefulWidget {
  const FindClinicsScreen({super.key});

  @override
  ConsumerState<FindClinicsScreen> createState() => _FindClinicsScreenState();
}

class _FindClinicsScreenState extends ConsumerState<FindClinicsScreen> {
  final _locationController = TextEditingController();
  final _mapController = MapController();
  bool _loading = false;
  bool _didAutofillFromSurvey = false;
  String? _error;
  String? _resolvedLabel;
  LatLng? _searchCenter;
  List<HealthCenter> _centers = const [];
  HealthCenter? _selected;
  double _mapHeight = kDefaultMapHeight;
  bool _searchExpanded = true;

  static const _defaultCenter = LatLng(36.7783, -119.4179);

  @override
  void dispose() {
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _tryAutofillFromSurvey(UserProfileData? profile) {
    if (_didAutofillFromSurvey) return;
    final location = profile?.location.trim() ?? '';
    if (location.isEmpty) return;
    if (_locationController.text.trim().isNotEmpty) {
      _didAutofillFromSurvey = true;
      return;
    }
    _didAutofillFromSurvey = true;
    _locationController.text = location;
  }

  Future<void> _search() async {
    final locationText = _locationController.text.trim();
    if (locationText.isEmpty) {
      setState(
        () => _error = 'Enter a city or ZIP code to find nearby clinics.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _selected = null;
    });

    try {
      final result = await ref
          .read(healthCenterServiceProvider)
          .findNearby(location: locationText);

      if (!mounted) return;
      final center = LatLng(result.latitude, result.longitude);
      setState(() {
        _resolvedLabel = result.locationLabel;
        _searchCenter = center;
        _centers = result.centers;
        // Give results the screen once a search succeeds; the summary bar
        // keeps the current location visible.
        if (result.centers.isNotEmpty) _searchExpanded = false;
        if (result.centers.isEmpty) {
          _error =
              'No community health centers found nearby. Try another California city or ZIP, or widen your search later.';
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fitMap(center, result.centers);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _describeError(error);
        _centers = const [];
        _resolvedLabel = null;
        _searchCenter = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fitMap(LatLng center, List<HealthCenter> centers) {
    if (centers.isEmpty) {
      _mapController.move(center, 11);
      return;
    }
    final points = <LatLng>[
      center,
      ...centers.map((c) => LatLng(c.latitude, c.longitude)),
    ];
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(36),
        maxZoom: 13,
      ),
    );
  }

  String _describeError(Object error) {
    if (error is FirebaseFunctionsException) {
      return error.message ?? 'Could not load clinics. Try again shortly.';
    }
    return 'Could not load clinics. Try again shortly.';
  }

  Future<void> _callPhone(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: digits));
  }

  Future<void> _openUrl(String url) async {
    var value = url.trim();
    if (value.isEmpty) return;
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _resizeMap(double delta, double maxMapHeight) {
    setState(
      () =>
          _mapHeight = (_mapHeight + delta).clamp(kMinMapHeight, maxMapHeight),
    );
  }

  void _selectCenter(HealthCenter center) {
    setState(() => _selected = center);
    _mapController.move(LatLng(center.latitude, center.longitude), 14);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    ref.listen<AsyncValue<UserProfileData?>>(userProfileProvider, (_, next) {
      _tryAutofillFromSurvey(next.value);
    });
    _tryAutofillFromSurvey(profile);

    final mapCenter = _searchCenter ?? _defaultCenter;

    return BrandScaffold(
      title: 'Find a clinic',
      body: Column(
        children: [
          if (!_searchExpanded)
            CollapsedSearchBar(
              location: _resolvedLabel ?? _locationController.text.trim(),
              emptyLocationHint: 'Set a city or ZIP code',
              detail: 'HRSA community health centers',
              loading: _loading,
              onExpand: () => setState(() => _searchExpanded = true),
            ),
          if (_searchExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Search HRSA community health centers near a California '
                          'city or ZIP. Pins are from the official federal '
                          'directory.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      CollapsePanelButton(
                        onPressed: () =>
                            setState(() => _searchExpanded = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      labelText: 'City or ZIP code',
                      hintText: 'e.g. Oakland or 94102',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _loading ? null : _search,
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _loading ? null : _search,
                    style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Find nearby clinics'),
                  ),
                  if (_resolvedLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Near: $_resolvedLabel',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxMapHeight = maxMapHeightFor(constraints.maxHeight);
                final mapHeight = _mapHeight.clamp(kMinMapHeight, maxMapHeight);
                return Column(
                  children: [
                    SizedBox(
                      height: mapHeight,
                      child: FinderMap(
                        controller: _mapController,
                        center: mapCenter,
                        initialZoom: _searchCenter == null ? 6 : 11,
                        searchCenter: _searchCenter,
                        badge: 'HRSA community health centers',
                        pins: [
                          for (final center in _centers)
                            FinderMapPin(
                              point: LatLng(
                                center.latitude,
                                center.longitude,
                              ),
                              selected: _selected?.id == center.id,
                              onTap: () => _selectCenter(center),
                            ),
                        ],
                      ),
                    ),
                    MapResizeHandle(
                      onDrag: (delta) => _resizeMap(delta, maxMapHeight),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _centers.length,
                        itemBuilder: (context, index) {
                          final center = _centers[index];
                          return _ClinicCard(
                            center: center,
                            selected: _selected?.id == center.id,
                            onTap: () => _selectCenter(center),
                            onCall: center.phone.isEmpty
                                ? null
                                : () => _callPhone(center.phone),
                            onOpenWebsite: center.website.isEmpty
                                ? null
                                : () => _openUrl(center.website),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    required this.center,
    required this.selected,
    required this.onTap,
    this.onCall,
    this.onOpenWebsite,
  });

  final HealthCenter center;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final VoidCallback? onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    final distance = center.distanceKm;
    final distanceLabel = distance == null
        ? null
        : distance < 10
        ? '${distance.toStringAsFixed(1)} km away'
        : '${distance.round()} km away';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? kBrandGreen : kBrandGreen.withValues(alpha: 0.18),
          width: selected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                center.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (distanceLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  distanceLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kBrandGreen.withValues(alpha: 0.9),
                  ),
                ),
              ],
              if (center.org.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  center.org,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (center.address.isNotEmpty || center.cityLine.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  [
                    if (center.address.isNotEmpty) center.address,
                    if (center.cityLine.isNotEmpty) center.cityLine,
                  ].join(', '),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87.withValues(alpha: 0.65),
                  ),
                ),
              ],
              if (center.type.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  center.type,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.black87.withValues(alpha: 0.55),
                  ),
                ),
              ],
              if (onCall != null || onOpenWebsite != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (onCall != null)
                      TextButton.icon(
                        onPressed: onCall,
                        style: TextButton.styleFrom(
                          foregroundColor: kBrandGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.call, size: 16),
                        label: Text(center.phone),
                      ),
                    if (onOpenWebsite != null)
                      TextButton(
                        onPressed: onOpenWebsite,
                        style: TextButton.styleFrom(
                          foregroundColor: kBrandGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Website'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
