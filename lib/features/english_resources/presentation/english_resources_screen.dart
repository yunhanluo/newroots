import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_locale.dart';
import '../../../core/models/resource.dart';
import '../../../core/services/resource_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../core/widgets/finder_controls.dart';
import '../../../core/widgets/finder_map.dart';
import '../../../l10n/app_localizations.dart';

/// Feature 4: English Learning Resource Finder (map + list).
class EnglishResourcesScreen extends ConsumerStatefulWidget {
  const EnglishResourcesScreen({super.key});

  @override
  ConsumerState<EnglishResourcesScreen> createState() =>
      _EnglishResourcesScreenState();
}

class _EnglishResourcesScreenState
    extends ConsumerState<EnglishResourcesScreen> {
  final _locationController = TextEditingController();
  final _mapController = MapController();
  bool _loading = false;
  bool _didAutofillFromSurvey = false;
  String? _error;
  String? _resolvedLabel;
  String? _source;
  LatLng? _searchCenter;
  List<Resource> _resources = const [];
  Resource? _selected;
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
    final l10n = AppLocalizations.of(context);
    final locationText = _locationController.text.trim();
    if (locationText.isEmpty) {
      setState(() => _error = l10n.englishEnterLocation);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _source = null;
      _selected = null;
    });

    try {
      final result = await ref
          .read(resourceServiceProvider)
          .findEnglishNearby(
            location: locationText,
            language: ref.read(appLocaleProvider).languageCode,
          );

      if (!mounted) return;
      final center = LatLng(result.latitude, result.longitude);
      setState(() {
        _resolvedLabel = result.locationLabel;
        _source = result.source;
        _searchCenter = center;
        _resources = result.resources;
        // Give results the screen once a search succeeds; the summary bar
        // keeps the current location visible.
        if (result.resources.isNotEmpty) _searchExpanded = false;
        if (result.resources.isEmpty) {
          _error = l10n.englishNoResults;
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fitMap(center, result.resources);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _describeError(error, l10n);
        _resources = const [];
        _resolvedLabel = null;
        _source = null;
        _searchCenter = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Resource> get _mappableResources => _resources
      .where(
        (r) =>
            r.latitude != null &&
            r.longitude != null &&
            r.latitude != 0 &&
            r.longitude != 0,
      )
      .toList();

  void _fitMap(LatLng center, List<Resource> resources) {
    final withCoords = resources
        .where(
          (r) =>
              r.latitude != null &&
              r.longitude != null &&
              r.latitude != 0 &&
              r.longitude != 0,
        )
        .toList();
    if (withCoords.isEmpty) {
      _mapController.move(center, 11);
      return;
    }
    final points = <LatLng>[
      center,
      ...withCoords.map((r) => LatLng(r.latitude!, r.longitude!)),
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

  String _describeError(Object error, AppLocalizations l10n) {
    if (error is FirebaseFunctionsException) {
      return error.message ?? l10n.englishLoadError;
    }
    return l10n.englishLoadError;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _resizeMap(double delta, double maxMapHeight) {
    setState(
      () =>
          _mapHeight = (_mapHeight + delta).clamp(kMinMapHeight, maxMapHeight),
    );
  }

  void _selectResource(Resource resource) {
    setState(() => _selected = resource);
    final lat = resource.latitude;
    final lng = resource.longitude;
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      _mapController.move(LatLng(lat, lng), 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    ref.listen<AsyncValue<UserProfileData?>>(userProfileProvider, (_, next) {
      _tryAutofillFromSurvey(next.value);
    });
    _tryAutofillFromSurvey(profile);

    final mapCenter = _searchCenter ?? _defaultCenter;
    final mappable = _mappableResources;
    final l10n = AppLocalizations.of(context);

    return BrandScaffold(
      title: l10n.featureEnglish,
      body: Column(
        children: [
          if (!_searchExpanded)
            CollapsedSearchBar(
              location: _resolvedLabel ?? _locationController.text.trim(),
              emptyLocationHint: l10n.finderSetCityOrZip,
              detail: l10n.englishSearchDetail,
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
                          l10n.englishSearchIntro,
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
                      labelText: l10n.finderCityOrZipLabel,
                      hintText: l10n.finderCityOrZipHint,
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
                        : Text(l10n.englishFindButton),
                  ),
                  if (_resolvedLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.finderNear(_resolvedLabel!),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  if (_source != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _source == 'curated'
                          ? l10n.englishSourceCurated
                          : l10n.englishSourceNamed(_source!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87.withValues(alpha: 0.5),
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
                        badge: l10n.englishSearchDetail,
                        pins: [
                          for (final resource in mappable)
                            FinderMapPin(
                              point: LatLng(
                                resource.latitude!,
                                resource.longitude!,
                              ),
                              selected: _selected?.id == resource.id,
                              onTap: () => _selectResource(resource),
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
                        itemCount: _resources.length,
                        itemBuilder: (context, index) {
                          final resource = _resources[index];
                          return _ResourceCard(
                            resource: resource,
                            selected: _selected?.id == resource.id,
                            onTap: () => _selectResource(resource),
                            onOpen: resource.sourceUrl == null
                                ? null
                                : () => _openUrl(resource.sourceUrl!),
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

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.resource,
    required this.selected,
    required this.onTap,
    this.onOpen,
  });

  final Resource resource;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final distance = resource.distanceKm;
    final distanceLabel = distance == null
        ? null
        : l10n.finderKmAway(
            distance < 10
                ? distance.toStringAsFixed(1)
                : '${distance.round()}',
          );

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      resource.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (resource.verified)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.verified, size: 18, color: kBrandGreen),
                    ),
                ],
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
              if (resource.city.isNotEmpty || resource.address.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  [
                    if (resource.address.isNotEmpty) resource.address,
                    if (resource.city.isNotEmpty) resource.city,
                  ].join(', '),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87.withValues(alpha: 0.65),
                  ),
                ),
              ],
              if (resource.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  resource.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87.withValues(alpha: 0.8),
                  ),
                ),
              ],
              if (onOpen != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onOpen,
                  style: TextButton.styleFrom(
                    foregroundColor: kBrandGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(AppLocalizations.of(context).finderOpenWebsite),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
