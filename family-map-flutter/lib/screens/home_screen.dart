import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/place.dart';
import '../services/geocoding_service.dart';
import '../services/place_api_service.dart';
import '../widgets/platform_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    PlaceApiService? apiService,
    GeocodingService? geocodingService,
  })  : _apiService = apiService,
        _geocodingService = geocodingService;

  final PlaceApiService? _apiService;
  final GeocodingService? _geocodingService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _facilityFilters = ['親子廁所', '兒童遊戲區', '哺乳室', '尿布台'];
  static const _mobileBreakpoint = 900.0;

  late final PlaceApiService _apiService;
  late final GeocodingService _geocodingService;
  final _searchController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _waypointControllers = <TextEditingController>[TextEditingController()];
  final _selectedFacilities = <String>{};

  final _submitFormKey = GlobalKey<FormState>();
  final _submitNameController = TextEditingController();
  final _submitTypeController = TextEditingController(text: '兒童遊戲區');
  final _submitAddressController = TextEditingController();
  final _submitDescriptionController = TextEditingController();
  final _submitLatController = TextEditingController();
  final _submitLngController = TextEditingController();

  String get _mapboxToken {
    try {
      return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    } catch (_) {
      return '';
    }
  }

  List<Place> _places = const [];
  bool _loading = true;
  String? _error;
  bool _submittingPlace = false;
  bool _resolvingCoordinates = false;
  bool _resolvingAddress = false;
  bool _submitDialogOpened = false;
  bool _desktopPanelExpanded = true;
  bool _mobilePanelExpanded = false;
  Place? _selectedPlace;

  int get _approvedCount =>
      _filteredPlaces.where((place) => place.isApproved).length;
  int get _pendingCount =>
      _filteredPlaces.where((place) => place.isPending).length;

  @override
  void initState() {
    super.initState();
    _apiService = widget._apiService ?? PlaceApiService();
    _geocodingService = widget._geocodingService ?? GeocodingService();
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
      final data = await _apiService.fetchMapMarkers();
      setState(() {
        _places = data;
        if (_selectedPlace != null) {
          final matches = data.where((place) => place.id == _selectedPlace!.id);
          _selectedPlace = matches.isEmpty ? null : matches.first;
        }
      });
    } catch (e) {
      debugPrint('Failed to load places: $e');
      setState(() => _error = '景點資料載入失敗');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Place> get _filteredPlaces {
    final query = _searchController.text.toLowerCase().trim();

    return _places.where((place) {
      final matchesQuery = query.isEmpty ||
          place.name.toLowerCase().contains(query) ||
          (place.address?.toLowerCase().contains(query) ?? false);
      if (!matchesQuery) {
        return false;
      }
      if (_selectedFacilities.isEmpty) {
        return true;
      }
      return _selectedFacilities.any((filter) {
        final lowerFilter = filter.toLowerCase();
        return place.infrastructureType.toLowerCase().contains(lowerFilter) ||
            place.facilities.any(
              (facility) => facility.toLowerCase().contains(lowerFilter),
            );
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Family Map Navigator'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          if (!_isMobileLayout(context))
            IconButton(
              onPressed: () => setState(
                () => _desktopPanelExpanded = !_desktopPanelExpanded,
              ),
              icon: Icon(_desktopPanelExpanded ? Icons.menu_open : Icons.menu),
              tooltip: _desktopPanelExpanded ? '收起側邊面板' : '展開側邊面板',
            ),
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < _mobileBreakpoint) {
                      return _buildMobileLayout();
                    }
                    return _buildDesktopLayout();
                  },
                ),
    );
  }

  bool _isMobileLayout(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _mobileBreakpoint;

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildMapSection()),
          AnimatedContainer(
            width: _desktopPanelExpanded ? 420 : 76,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: _desktopPanelExpanded
                ? _buildPanelContent()
                : _buildCollapsedPanelRail(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: _buildMapSection()),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxHeight: _mobilePanelExpanded
                  ? MediaQuery.sizeOf(context).height * 0.6
                  : 68,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  onTap: () => setState(
                    () => _mobilePanelExpanded = !_mobilePanelExpanded,
                  ),
                  child: SizedBox(
                    height: 68,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          _mobilePanelExpanded
                              ? Icons.expand_more
                              : Icons.expand_less,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _mobilePanelExpanded ? '收起景點與路線' : '展開景點與路線',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          onPressed: _showSubmitPlaceDialog,
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('新增'),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
                if (_mobilePanelExpanded) const Divider(height: 1),
                if (_mobilePanelExpanded) Expanded(child: _buildPanelContent()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        _buildSearchCard(),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  PlatformMap(
                    places: _filteredPlaces,
                    focusPlace: _selectedPlace,
                    mapboxAccessToken: _mapboxToken,
                    onPlaceTap: _handlePlaceTap,
                    onMapTap: _handleMapTap,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '景點 ${_filteredPlaces.length} / ${_places.length}',
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildStatChip(
                                  label: '已審核',
                                  count: _approvedCount,
                                  background: const Color(0xFFDCFCE7),
                                  foreground: const Color(0xFF166534),
                                ),
                                _buildStatChip(
                                  label: '待審核',
                                  count: _pendingCount,
                                  background: const Color(0xFFFFF3C4),
                                  foreground: const Color(0xFF92400E),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(left: 16, bottom: 16, child: _buildLegendCard()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜尋台中景點、地址或設施',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => _searchController.clear(),
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFacilityFilter(),
        ],
      ),
    );
  }

  Widget _buildLegendCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('圖例（台中測試點）', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            _LegendRow(
              icon: Icons.attractions,
              label: '兒童遊戲區',
              color: Color(0xFF22C55E),
            ),
            _LegendRow(
              icon: Icons.child_friendly,
              label: '哺乳室',
              color: Color(0xFF8B5CF6),
            ),
            _LegendRow(
              icon: Icons.family_restroom,
              label: '親子廁所',
              color: Color(0xFF06B6D4),
            ),
            _LegendRow(
              icon: Icons.baby_changing_station,
              label: '尿布台',
              color: Color(0xFFF97316),
            ),
            SizedBox(height: 4),
            Text(
              '待審核點位以淡色與標籤呈現',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label：$count',
        style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildPanelContent() {
    return Column(
      children: [
        Expanded(child: _buildPlaceList()),
        const Divider(height: 1),
        _buildRoutePlanner(),
      ],
    );
  }

  Widget _buildCollapsedPanelRail() {
    return Column(
      children: [
        const SizedBox(height: 12),
        IconButton(
          onPressed: () => setState(() => _desktopPanelExpanded = true),
          icon: const Icon(Icons.chevron_left),
          tooltip: '展開側邊面板',
        ),
        const SizedBox(height: 8),
        const RotatedBox(quarterTurns: 3, child: Text('景點列表 / 路線規劃')),
      ],
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
      return const Center(child: Text('目前沒有符合條件的景點'));
    }

    return ListView.separated(
      itemCount: _filteredPlaces.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = _filteredPlaces[index];
        final isSelected = _selectedPlace?.id == place.id;

        return ListTile(
          selected: isSelected,
          tileColor: place.isPending ? const Color(0xFFFFFBEB) : null,
          title: Text(
            place.name,
            style: TextStyle(
              color: place.isPending ? const Color(0xFF92400E) : null,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${place.infrastructureType}\n${place.address ?? '未提供地址'}',
          ),
          isThreeLine: true,
          trailing: Chip(
            label: Text(place.statusLabel),
            visualDensity: VisualDensity.compact,
            backgroundColor: place.isPending
                ? const Color(0xFFFFF3C4)
                : const Color(0xFFDCFCE7),
            labelStyle: TextStyle(
              color: place.isPending
                  ? const Color(0xFF92400E)
                  : const Color(0xFF166534),
              fontWeight: FontWeight.w700,
            ),
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
            Text('路線規劃', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _startController,
              decoration: const InputDecoration(labelText: '起點（地址或 lat,lng）'),
            ),
            const SizedBox(height: 8),
            ..._waypointControllers.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: '中繼點 ${entry.key + 1}',
                      ),
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
                  label: const Text('清空中繼點'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _endController,
              decoration: const InputDecoration(labelText: '終點（地址或 lat,lng）'),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _openNavigation,
              icon: const Icon(Icons.alt_route),
              label: const Text('開啟導航'),
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
              if (place.facilities.isNotEmpty)
                Text('設施：${place.facilities.join('、')}'),
              Text('座標：${place.latitude}, ${place.longitude}'),
              Text('狀態：${place.statusLabel}'),
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
    final waypoints = _waypointControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (origin.isEmpty || destination.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先輸入起點與終點')));
      return;
    }

    final uri = _buildNavigationUri(
      origin: origin,
      destination: destination,
      waypoints: waypoints,
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('無法開啟外部導航')));
    }
  }

  Future<void> _handleMapTap(double latitude, double longitude) async {
    if (!_submitDialogOpened) {
      return;
    }

    _submitLatController.text = latitude.toStringAsFixed(6);
    _submitLngController.text = longitude.toStringAsFixed(6);
    await _reverseGeocode(
      latitude: latitude,
      longitude: longitude,
      fromMapTap: true,
    );
  }

  Future<void> _geocodeAddress() async {
    if (_resolvingCoordinates) {
      return;
    }

    final address = _submitAddressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先輸入地址')));
      return;
    }

    setState(() => _resolvingCoordinates = true);
    try {
      final result = await _geocodingService.geocodeAddress(address);
      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('找不到對應座標')));
        }
        return;
      }

      _submitLatController.text = result.latitude.toStringAsFixed(6);
      _submitLngController.text = result.longitude.toStringAsFixed(6);
      _submitAddressController.text = result.address;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已帶入地址與座標')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('地址轉座標失敗：$e')));
      }
    } finally {
      if (mounted) {
        setState(() => _resolvingCoordinates = false);
      }
    }
  }

  Future<void> _reverseGeocodeFromCoordinates() async {
    final lat = double.tryParse(_submitLatController.text.trim());
    final lng = double.tryParse(_submitLngController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入有效經緯度')));
      return;
    }

    await _reverseGeocode(latitude: lat, longitude: lng);
  }

  Future<void> _reverseGeocode({
    required double latitude,
    required double longitude,
    bool fromMapTap = false,
  }) async {
    if (_resolvingAddress) {
      return;
    }

    setState(() => _resolvingAddress = true);
    try {
      final address = await _geocodingService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
      if (address == null || address.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('找不到對應地址')));
        }
        return;
      }

      _submitAddressController.text = address;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fromMapTap ? '已由地圖點位帶入地址與座標' : '已帶入地址')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('座標轉地址失敗：$e')));
      }
    } finally {
      if (mounted) {
        setState(() => _resolvingAddress = false);
      }
    }
  }

  void _showSubmitPlaceDialog() {
    _submitDialogOpened = true;
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('可先在地圖上點選位置，再補上地址與景點資訊'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitNameController,
                      decoration: const InputDecoration(labelText: '景點名稱'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? '請輸入景點名稱'
                              : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitTypeController,
                      decoration: const InputDecoration(labelText: '設施類型'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? '請輸入設施類型'
                              : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitAddressController,
                      decoration: const InputDecoration(labelText: '地址'),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _geocodeAddress,
                        icon: const Icon(Icons.travel_explore),
                        label: const Text('地址轉座標'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitDescriptionController,
                      decoration: const InputDecoration(labelText: '補充描述'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitLatController,
                      decoration: const InputDecoration(labelText: '緯度'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? '請輸入有效緯度'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _submitLngController,
                      decoration: const InputDecoration(labelText: '經度'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? '請輸入有效經度'
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _reverseGeocodeFromCoordinates,
                        icon: const Icon(Icons.pin_drop),
                        label: const Text('座標轉地址'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  _submittingPlace ? null : () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: _submittingPlace ? null : _submitPlace,
              child: Text(_submittingPlace ? '送出中...' : '送出審核'),
            ),
          ],
        );
      },
    ).then((_) => _submitDialogOpened = false);
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
        address: _submitAddressController.text.trim().isEmpty
            ? null
            : _submitAddressController.text.trim(),
        description: _submitDescriptionController.text.trim().isEmpty
            ? null
            : _submitDescriptionController.text.trim(),
        latitude: double.parse(_submitLatController.text.trim()),
        longitude: double.parse(_submitLngController.text.trim()),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('景點已送出，等待審核')));
      }
      _clearSubmitForm();
      await _loadPlaces();
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('送出失敗：${e.response?.data ?? e.message}')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingPlace = false);
      }
    }
  }

  void _clearSubmitForm() {
    _submitNameController.clear();
    _submitTypeController.text = '兒童遊戲區';
    _submitAddressController.clear();
    _submitDescriptionController.clear();
    _submitLatController.clear();
    _submitLngController.clear();
  }

  Uri _buildNavigationUri({
    required String origin,
    required String destination,
    required List<String> waypoints,
  }) {
    if (_isApplePlatform) {
      final waypointsText =
          waypoints.isEmpty ? '' : ' via ${waypoints.join(' via ')}';
      return Uri.parse(
        'https://maps.apple.com/?saddr=$origin&daddr=$destination$waypointsText&dirflg=d',
      );
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

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: color,
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
