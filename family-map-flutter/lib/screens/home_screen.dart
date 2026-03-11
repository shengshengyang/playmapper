import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/place_api_service.dart';
import '../widgets/platform_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = PlaceApiService();
  final _searchController = TextEditingController();
  final _mapboxToken = const String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  List<Place> _places = const [];
  bool _loading = true;
  String? _error;
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
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final data = await _apiService.fetchPlaces();
      setState(() => _places = data);
    } catch (e) {
      setState(() => _error = '載入點位失敗：$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Place> get _filteredPlaces {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      return _places;
    }
    return _places
        .where(
          (p) => p.name.toLowerCase().contains(query) || (p.address?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Map Flutter'),
        actions: [
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
                            const SizedBox(height: 12),
                            Expanded(
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                child: PlatformMap(
                                  places: _filteredPlaces,
                                  focusPlace: _selectedPlace,
                                  mapboxAccessToken: _mapboxToken,
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
                        child: _buildPlaceList(),
                      ),
                    ),
                  ],
                ),
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

        return ListTile(
          selected: isSelected,
          title: Text(place.name),
          subtitle: Text('${place.infrastructureType}\n${place.address ?? '未提供地址'}'),
          isThreeLine: true,
          trailing: place.facilities.isEmpty
              ? null
              : Chip(
                  label: Text('${place.facilities.length} 項設施'),
                  visualDensity: VisualDensity.compact,
                ),
          onTap: () {
            setState(() => _selectedPlace = place);
          },
        );
      },
    );
  }
}
