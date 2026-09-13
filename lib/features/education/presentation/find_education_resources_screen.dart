import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/education_resource.dart';
import '../../../core/services/education_resource_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import '../../../core/widgets/ai_body_text.dart';
import '../../../core/widgets/finder_controls.dart';
import '../../../core/widgets/finder_map.dart';
import '../../../l10n/app_localizations.dart';

/// Grade scale used by the range slider and the dataset: -1 = PK, 0 = K, 1-12.
const _gradeFloor = -1.0;
const _gradeCeiling = 12.0;

String _gradeName(int grade) {
  if (grade <= -1) return 'PK';
  if (grade == 0) return 'K';
  return '$grade';
}

const _schoolKinds = {'school', 'private_school'};

const _kindHeaderPrefix = '__header::';

/// Map + list of nearby California schools and education support programs.
class FindEducationResourcesScreen extends ConsumerStatefulWidget {
  const FindEducationResourcesScreen({super.key});

  @override
  ConsumerState<FindEducationResourcesScreen> createState() =>
      _FindEducationResourcesScreenState();
}

class _FindEducationResourcesScreenState
    extends ConsumerState<FindEducationResourcesScreen> {
  final _locationController = TextEditingController();
  final _mapController = MapController();
  bool _loading = false;
  bool _didAutofillFromSurvey = false;
  String? _error;
  String? _resolvedLabel;
  LatLng? _searchCenter;
  List<EducationResource> _resources = const [];
  EducationResource? _selected;
  final Map<String, SchoolAiSummary> _summaryCache = {};
  RangeValues _grades = const RangeValues(_gradeFloor, _gradeCeiling);
  String _kind = 'all';
  double _mapHeight = 220;
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

  List<(String, List<(String, String)>)> _kindGroups(AppLocalizations l10n) => [
    ('', [('all', l10n.educationAllTypes)]),
    (
      l10n.educationKindSchools,
      [
        ('school', l10n.educationKindPublicSchools),
        ('private_school', l10n.educationKindPrivateSchools),
      ],
    ),
    (
      l10n.educationKindPrograms,
      [
        ('enrollment_help', l10n.educationKindEnrollmentHelp),
        ('library', l10n.educationKindLibraries),
        ('tutoring', l10n.educationKindTutoring),
        ('stem', l10n.educationKindStem),
      ],
    ),
  ];

  List<DropdownMenuItem<String>> _buildKindItems(AppLocalizations l10n) {
    final items = <DropdownMenuItem<String>>[];
    for (final group in _kindGroups(l10n)) {
      final title = group.$1;
      if (title.isNotEmpty) {
        items.add(
          DropdownMenuItem<String>(
            enabled: false,
            value: '$_kindHeaderPrefix$title',
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: kBrandGreen.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }
      for (final option in group.$2) {
        items.add(
          DropdownMenuItem<String>(
            value: option.$1,
            child: Padding(
              padding: EdgeInsets.only(left: title.isEmpty ? 0 : 10),
              child: Text(option.$2, overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      }
    }
    return items;
  }

  List<String> _kindSelectedLabels(AppLocalizations l10n) {
    final labels = <String>[];
    for (final group in _kindGroups(l10n)) {
      if (group.$1.isNotEmpty) labels.add('');
      for (final option in group.$2) {
        labels.add(option.$2);
      }
    }
    return labels;
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context);
    final locationText = _locationController.text.trim();
    if (locationText.isEmpty) {
      setState(() => _error = l10n.educationEnterLocation);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _selected = null;
    });

    try {
      final result = await ref
          .read(educationResourceServiceProvider)
          .findNearby(
            location: locationText,
            gradeMin: _grades.start.round(),
            gradeMax: _grades.end.round(),
            kind: _kind,
          );

      if (!mounted) return;
      final center = LatLng(result.latitude, result.longitude);
      final mappable = result.resources
          .where((r) => r.latitude != 0 && r.longitude != 0)
          .toList();
      setState(() {
        _resolvedLabel = result.locationLabel;
        _searchCenter = center;
        _resources = result.resources;
        // Give results the screen once a search succeeds; the summary bar
        // keeps the current location and filters visible.
        if (result.resources.isNotEmpty) _searchExpanded = false;
        if (result.resources.isEmpty) {
          _error = l10n.educationNoResults;
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fitMap(center, mappable);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _describeError(error, l10n);
        _resources = const [];
        _resolvedLabel = null;
        _searchCenter = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fitMap(LatLng center, List<EducationResource> resources) {
    if (resources.isEmpty) {
      _mapController.move(center, 11);
      return;
    }
    final points = <LatLng>[
      center,
      ...resources.map((r) => LatLng(r.latitude, r.longitude)),
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
      return error.message ?? l10n.educationLoadError;
    }
    return l10n.educationLoadErrorShort;
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

  bool get _allGrades =>
      _grades.start <= _gradeFloor && _grades.end >= _gradeCeiling;

  String _gradeRangeLabel(AppLocalizations l10n) {
    if (_allGrades) return l10n.educationAllGrades;
    final low = _gradeName(_grades.start.round());
    final high = _gradeName(_grades.end.round());
    return low == high
        ? l10n.educationGradeSingle(low)
        : l10n.educationGradesRange(low, high);
  }

  String _labelForKind(String value, AppLocalizations l10n) {
    for (final group in _kindGroups(l10n)) {
      for (final option in group.$2) {
        if (option.$1 == value) return option.$2;
      }
    }
    return l10n.educationAllTypes;
  }

  void _resizeMap(double delta, double maxMapHeight) {
    setState(
      () =>
          _mapHeight = (_mapHeight + delta).clamp(kMinMapHeight, maxMapHeight),
    );
  }

  void _selectResource(EducationResource resource) {
    setState(() => _selected = resource);
    if (resource.latitude != 0 && resource.longitude != 0) {
      _mapController.move(LatLng(resource.latitude, resource.longitude), 14);
    }
  }

  Future<void> _showSchoolSummary(
    EducationResource resource,
    String language,
  ) async {
    final cached = _summaryCache[resource.id];
    final future = cached != null
        ? Future.value(cached)
        : ref
              .read(educationResourceServiceProvider)
              .summarizeSchool(resourceId: resource.id, language: language)
              .then((summary) {
                _summaryCache[resource.id] = summary;
                return summary;
              });

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => _SchoolSummarySheet(
        school: resource,
        summaryFuture: future,
        onOpenSource: _openUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    ref.listen<AsyncValue<UserProfileData?>>(userProfileProvider, (_, next) {
      _tryAutofillFromSurvey(next.value);
    });
    _tryAutofillFromSurvey(profile);

    final mapCenter = _searchCenter ?? _defaultCenter;
    final mapResources = _resources
        .where((r) => r.latitude != 0 && r.longitude != 0)
        .toList();
    final l10n = AppLocalizations.of(context);

    return BrandScaffold(
      title: l10n.educationFindTitle,
      body: Column(
        children: [
          if (!_searchExpanded)
            CollapsedSearchBar(
              location: _resolvedLabel ?? _locationController.text.trim(),
              emptyLocationHint: l10n.finderSetCityOrZip,
              detail:
                  '${_labelForKind(_kind, l10n)} · ${_gradeRangeLabel(l10n)}',
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
                          l10n.educationSearchIntro,
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
                  _GradeRangeField(
                    values: _grades,
                    label: _gradeRangeLabel(l10n),
                    enabled: !_loading,
                    onChanged: (values) => setState(() => _grades = values),
                    onReset: _allGrades
                        ? null
                        : () => setState(
                            () => _grades = const RangeValues(
                              _gradeFloor,
                              _gradeCeiling,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.educationTypeLabel,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _kind,
                              isExpanded: true,
                              selectedItemBuilder: (context) => [
                                for (final label in _kindSelectedLabels(l10n))
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              items: _buildKindItems(l10n),
                              onChanged: _loading
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      if (value.startsWith(_kindHeaderPrefix)) {
                                        return;
                                      }
                                      setState(() => _kind = value);
                                    },
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        : Text(l10n.educationFindButton),
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
                        badge: l10n.educationMapBadge,
                        pins: [
                          for (final resource in mapResources)
                            FinderMapPin(
                              point: LatLng(
                                resource.latitude,
                                resource.longitude,
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
                          return _EducationCard(
                            resource: resource,
                            selected: _selected?.id == resource.id,
                            onTap: () => _selectResource(resource),
                            onCall: resource.phone.isEmpty
                                ? null
                                : () => _callPhone(resource.phone),
                            onOpenWebsite: resource.website.isEmpty
                                ? null
                                : () => _openUrl(resource.website),
                            onMoreInformation:
                                _schoolKinds.contains(resource.kind)
                                ? () => _showSchoolSummary(
                                    resource,
                                    profile?.languageCode ?? 'en',
                                  )
                                : null,
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

/// Discrete PK-12 range slider for picking the grades a family needs.
class _GradeRangeField extends StatelessWidget {
  const _GradeRangeField({
    required this.values,
    required this.label,
    required this.enabled,
    required this.onChanged,
    this.onReset,
  });

  final RangeValues values;
  final String label;
  final bool enabled;
  final ValueChanged<RangeValues> onChanged;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Colors.black87.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.educationGradeLabel,
                style: TextStyle(fontSize: 12, color: muted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (onReset != null)
                TextButton(
                  onPressed: enabled ? onReset : null,
                  style: TextButton.styleFrom(
                    foregroundColor: kBrandGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.educationAllGrades),
                ),
            ],
          ),
          RangeSlider(
            values: values,
            min: _gradeFloor,
            max: _gradeCeiling,
            divisions: (_gradeCeiling - _gradeFloor).round(),
            activeColor: kBrandGreen,
            inactiveColor: kBrandGreen.withValues(alpha: 0.18),
            labels: RangeLabels(
              _gradeName(values.start.round()),
              _gradeName(values.end.round()),
            ),
            onChanged: enabled ? onChanged : null,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.educationGradePk,
                  style: TextStyle(fontSize: 11, color: muted),
                ),
                Text(
                  l10n.educationGrade12,
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({
    required this.resource,
    required this.selected,
    required this.onTap,
    this.onCall,
    this.onOpenWebsite,
    this.onMoreInformation,
  });

  final EducationResource resource;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final VoidCallback? onOpenWebsite;
  final VoidCallback? onMoreInformation;

  @override
  Widget build(BuildContext context) {
    final distance = resource.distanceKm;
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
                resource.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _Chip(label: resource.kindLabel),
                  if (resource.gradeLabel.isNotEmpty)
                    _Chip(label: resource.gradeLabel),
                  if (distanceLabel != null)
                    Text(
                      distanceLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kBrandGreen.withValues(alpha: 0.9),
                      ),
                    ),
                ],
              ),
              if (resource.district.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  resource.district,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (resource.address.isNotEmpty ||
                  resource.cityLine.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  [
                    if (resource.address.isNotEmpty) resource.address,
                    if (resource.cityLine.isNotEmpty) resource.cityLine,
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
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.black87.withValues(alpha: 0.55),
                  ),
                ),
              ],
              if (onCall != null ||
                  onOpenWebsite != null ||
                  onMoreInformation != null) ...[
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
                        label: Text(resource.phone),
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
                    if (onMoreInformation != null)
                      TextButton.icon(
                        onPressed: onMoreInformation,
                        style: TextButton.styleFrom(
                          foregroundColor: kBrandGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                        label: const Text('More information'),
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

class _SchoolSummarySheet extends StatelessWidget {
  const _SchoolSummarySheet({
    required this.school,
    required this.summaryFuture,
    required this.onOpenSource,
  });

  final EducationResource school;
  final Future<SchoolAiSummary> summaryFuture;
  final Future<void> Function(String url) onOpenSource;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.86,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            size: 15,
                            color: kBrandGreen,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'AI-generated school summary',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kBrandGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<SchoolAiSummary>(
              future: summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: kBrandGreen),
                        SizedBox(height: 14),
                        Text('Reading official school information…'),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  final error = snapshot.error;
                  final message = error is FirebaseFunctionsException
                      ? error.message
                      : null;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 40,
                            color: Colors.black45,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            message ??
                                'Could not generate this summary. Try again shortly.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close and try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final summary = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text(
                        'This summary was generated by AI from official sources. '
                        'It does not include ratings or parent reviews and may '
                        'miss recent changes. Verify important details directly '
                        'with the school.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AiBodyText(
                      summary.overview,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    if (summary.highlights.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const _SummaryHeading(title: 'What the sources say'),
                      const SizedBox(height: 8),
                      for (final item in summary.highlights)
                        _SummaryBullet(text: item),
                    ],
                    if (summary.questionsToAsk.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const _SummaryHeading(
                        title: 'Questions to ask the school',
                      ),
                      const SizedBox(height: 8),
                      for (final item in summary.questionsToAsk)
                        _SummaryBullet(text: item),
                    ],
                    if (summary.sources.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const _SummaryHeading(title: 'Sources'),
                      const SizedBox(height: 6),
                      for (final source in summary.sources)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => onOpenSource(source.url),
                            style: TextButton.styleFrom(
                              foregroundColor: kBrandGreen,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(source.title),
                          ),
                        ),
                    ],
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

class _SummaryHeading extends StatelessWidget {
  const _SummaryHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _SummaryBullet extends StatelessWidget {
  const _SummaryBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 6, color: kBrandGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AiBodyText(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kBrandGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kBrandGreen,
        ),
      ),
    );
  }
}
