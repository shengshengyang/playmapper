import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../models/place.dart';
import '../services/place_api_service.dart';
import '../widgets/platform_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _facilityFilters = ['親子廁所', '親子景點'];

  final _apiService = PlaceApiService();
  final _searchController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _waypointControllers = <TextEditingController>[TextEditingController()];
  final _selectedFacilities = <String>{};

  final _submitFormKey = GlobalKey<FormState>();
  final _submitNameController = TextEditingController();
  final _submitTypeController = TextEditingController(text: '親子景點');
  final _submitAddressController = TextEditingController();
  final _submitDescriptionController = TextEditingController();
  final _submitLatController = TextEditingController();
  final _submitLngController = TextEditingController();

  String get _mapboxToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  List<Place> _places = const [];
  bool _loading = true;
  String? _error;
  bool _submittingPlace = false;
  Place? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startController.dispose();
    _endController.dispose();
    _submitNameController.dispose();
    _submitTypeController.dispose();
    _submitAddressController.dispose();
    _submitDescriptionController.dispose();
    _submitLatController.dispose();
    _submitLngController.dispose();
    for (final controller in _waypointControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final data = await _apiService.fetchPlaces(includeAllStatus: true);
      setState(() => _places = data);
    } catch (e) {
      debugPrint('載入點位失敗: $e');
      setState(() => _error = '載入點位失敗：$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Place> get _filteredPlaces {
    final query = _searchController.text.toLowerCase().trim();

    return _places.where((p) {
      final matchQuery = query.isEmpty || p.name.toLowerCase().contains(query) || (p.address?.toLowerCase().contains(query) ?? false);
      if (!matchQuery) {
        return false;
      }
      if (_selectedFacilities.isEmpty) {
        return true;
      }
      return _selectedFacilities.any((filter) {
        final lowerFilter = filter.toLowerCase();
        return p.infrastructureType.toLowerCase().contains(lowerFilter) || p.facilities.any((f) => f.toLowerCase().contains(lowerFilter));
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Map Flutter'),
        actions: [
          IconButton(
            onPressed: _showSubmitPlaceDialog,
            icon: const Icon(Icons.add_location_alt),
            tooltip: '新增景點',
          ),
          IconButton(
            onPressed: _loadPlaces,
            icon: const Icon(Icons.refresh),
            tooltip: '重新載入',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: '搜尋設施名稱或地址',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildFacilityFilter(),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                child: PlatformMap(
                                  places: _filteredPlaces,
                                  focusPlace: _selectedPlace,
                                  mapboxAccessToken: _mapboxToken,
                                  onPlaceTap: _handlePlaceTap,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        child: Column(
                          children: [
                            Expanded(child: _buildPlaceList()),
                            const Divider(height: 1),
                            _buildRoutePlanner(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFacilityFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _facilityFilters
          .map(
            (filter) => FilterChip(
              label: Text(filter),
              selected: _selectedFacilities.contains(filter),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFacilities.add(filter);
                  } else {
                    _selectedFacilities.remove(filter);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlaceList() {
    if (_filteredPlaces.isEmpty) {
      return const Center(child: Text('目前沒有符合條件的點位'));
    }

    return ListView.separated(
      itemCount: _filteredPlaces.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = _filteredPlaces[index];
        final isSelected = _selectedPlace?.id == place.id;

        final subtitle = '${place.infrastructureType}\n${place.address ?? '未提供地址'}';

        return ListTile(
          selected: isSelected,
          tileColor: place.isPending ? Colors.grey.withOpacity(0.08) : null,
          title: Text(
            place.name,
            style: TextStyle(color: place.isPending ? Colors.grey[700] : null),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: place.isPending ? Colors.grey[600] : null),
          ),
          isThreeLine: true,
          trailing: place.isPending
              ? const Chip(
                  label: Text('待審核'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Color(0xFFE5E7EB),
                )
              : place.facilities.isEmpty
                  ? null
                  : Chip(
                      label: Text('${place.facilities.length} 項設施'),
                      visualDensity: VisualDensity.compact,
                    ),
          onTap: () => _handlePlaceTap(place),
        );
      },
    );
  }

  Widget _buildRoutePlanner() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('路徑規劃', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _startController,
              decoration: const InputDecoration(labelText: '起點 (地址或 lat,lng)'),
            ),
            const SizedBox(height: 8),
            ..._waypointControllers.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: '中繼點 ${entry.key + 1}'),
                    ),
                  ),
                ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _addWaypoint,
                  icon: const Icon(Icons.add),
                  label: const Text('新增中繼點'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearWaypoints,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('清除中繼點'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _endController,
              decoration: const InputDecoration(labelText: '終點 (地址或 lat,lng)'),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _openNavigation,
              icon: const Icon(Icons.alt_route),
              label: const Text('開始導航'),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlaceTap(Place place) {
    setState(() => _selectedPlace = place);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(place.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('類型：${place.infrastructureType}'),
              Text('地址：${place.address ?? '未提供'}'),
              if (place.facilities.isNotEmpty) Text('設施：${place.facilities.join('、')}'),
              Text('座標：${place.latitude}, ${place.longitude}'),
              Text('狀態：${place.isPending ? '待審核' : '正式景點'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  void _addWaypoint() {
    setState(() {
      _waypointControllers.add(TextEditingController());
    });
  }

  void _clearWaypoints() {
    for (final controller in _waypointControllers) {
      controller.clear();
    }
  }

  Future<void> _openNavigation() async {
    final origin = _startController.text.trim();
    final destination = _endController.text.trim();
    final waypoints = _waypointControllers.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();

    if (origin.isEmpty || destination.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請先輸入起點與終點')));
      return;
    }

    final uri = _buildNavigationUri(origin: origin, destination: destination, waypoints: waypoints);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無法開啟導航應用程式')));
    }
  }


  void _showSubmitPlaceDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增景點（送審）'),
          content: SizedBox(
            width: 460,
            child: Form(
              key: _submitFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _submitNameController,
                      decoration: const InputDecoration(labelText: '景點名稱'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '請輸入景點名稱' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitTypeController,
                      decoration: const InputDecoration(labelText: '設施類型'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '請輸入設施類型' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitAddressController,
                      decoration: const InputDecoration(labelText: '地址'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitDescriptionController,
                      decoration: const InputDecoration(labelText: '描述'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitLatController,
                      decoration: const InputDecoration(labelText: '緯度'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => double.tryParse(v ?? '') == null ? '請輸入正確緯度' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitLngController,
                      decoration: const InputDecoration(labelText: '經度'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => double.tryParse(v ?? '') == null ? '請輸入正確經度' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _submittingPlace ? null : () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: _submittingPlace ? null : _submitPlace,
              child: Text(_submittingPlace ? '送出中...' : '送出審核'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPlace() async {
    if (!(_submitFormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _submittingPlace = true);
    try {
      await _apiService.submitPlace(
        name: _submitNameController.text.trim(),
        infrastructureType: _submitTypeController.text.trim(),
        address: _submitAddressController.text.trim().isEmpty ? null : _submitAddressController.text.trim(),
        description: _submitDescriptionController.text.trim().isEmpty ? null : _submitDescriptionController.text.trim(),
        latitude: double.parse(_submitLatController.text.trim()),
        longitude: double.parse(_submitLngController.text.trim()),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('景點已送出，等待審核')));
      }
      _clearSubmitForm();
      await _loadPlaces();
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('送出失敗：${e.response?.data ?? e.message}')));
    } finally {
      if (mounted) {
        setState(() => _submittingPlace = false);
      }
    }
  }

  void _clearSubmitForm() {
    _submitNameController.clear();
    _submitTypeController.text = '親子景點';
    _submitAddressController.clear();
    _submitDescriptionController.clear();
    _submitLatController.clear();
    _submitLngController.clear();
  }

  Uri _buildNavigationUri({required String origin, required String destination, required List<String> waypoints}) {
    if (_isApplePlatform) {
      final waypointsText = waypoints.isEmpty ? '' : ' via ${waypoints.join(' via ')}';
      return Uri.parse('https://maps.apple.com/?saddr=$origin&daddr=$destination$waypointsText&dirflg=d');
    }

    final params = <String, String>{
      'api': '1',
      'origin': origin,
      'destination': destination,
      'travelmode': 'driving',
    };

    if (waypoints.isNotEmpty) {
      params['waypoints'] = waypoints.join('|');
    }

    return Uri.https('www.google.com', '/maps/dir/', params);
  }

  bool get _isApplePlatform {
    if (kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS;
    }
    return defaultTargetPlatform == TargetPlatform.iOS;
  }
}
