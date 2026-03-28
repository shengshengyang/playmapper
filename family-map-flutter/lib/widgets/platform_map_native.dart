import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as mapkit;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../data/mock_map_places.dart';
import '../models/place.dart';

Widget buildPlatformMap(
  BuildContext context, {
  required List<Place> places,
  required Place? focusPlace,
  required String? mapboxAccessToken,
  required ValueChanged<Place> onPlaceTap,
  required void Function(double latitude, double longitude) onMapTap,
}) {
  if (Platform.isIOS) {
    return _buildMapKit(places, focusPlace);
  }
  return _buildOpenStreetMap(places, focusPlace, onPlaceTap, onMapTap);
}

Widget _buildMapKit(List<Place> places, Place? focusPlace) {
  final center = _resolveCenter(places, focusPlace);
  final annotations = places
      .map(
        (place) => mapkit.Annotation(
          annotationId: mapkit.AnnotationId('place_${place.id}'),
          position: mapkit.LatLng(place.latitude, place.longitude),
          infoWindow: mapkit.InfoWindow(
            title: '${_iconForType(place.infrastructureType)} ${place.name}',
            snippet: '${place.statusLabel} · ${place.infrastructureType}',
          ),
        ),
      )
      .toSet();

  return mapkit.AppleMap(
    initialCameraPosition: mapkit.CameraPosition(
      target: mapkit.LatLng(center.latitude, center.longitude),
      zoom: 13,
    ),
    annotations: annotations,
    myLocationButtonEnabled: true,
  );
}

Widget _buildOpenStreetMap(
  List<Place> places,
  Place? focusPlace,
  ValueChanged<Place> onPlaceTap,
  void Function(double latitude, double longitude) onMapTap,
) {
  final center = _resolveCenter(places, focusPlace);

  return FlutterMap(
    options: MapOptions(
      initialCenter: center,
      initialZoom: 13,
      onTap: (_, point) => onMapTap(point.latitude, point.longitude),
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.familymap.app',
      ),
      MarkerLayer(
        markers: places
            .map(
              (place) => Marker(
                point: ll.LatLng(place.latitude, place.longitude),
                width: 60,
                height: 68,
                child: GestureDetector(
                  onTap: () => onPlaceTap(place),
                  child: _NativeMarker(
                    place: place,
                    isSelected: focusPlace?.id == place.id,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ],
  );
}

class _NativeMarker extends StatelessWidget {
  const _NativeMarker({required this.place, required this.isSelected});

  final Place place;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(place.infrastructureType);

    return Opacity(
      opacity: place.isPending ? 0.76 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSelected ? 42 : 38,
            height: isSelected ? 42 : 38,
            decoration: BoxDecoration(
              color: place.isPending ? const Color(0xFFFFF7ED) : color,
              shape: BoxShape.circle,
              border: Border.all(
                color: place.isPending ? const Color(0xFFF59E0B) : Colors.white,
                width: place.isPending ? 2 : 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _iconForType(place.infrastructureType),
              color: place.isPending ? const Color(0xFFB45309) : Colors.white,
              size: isSelected ? 22 : 20,
            ),
          ),
          const SizedBox(height: 4),
          if (place.isPending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: const Text(
                '待審核',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

IconData _iconForType(String infrastructureType) {
  switch (infrastructureType.toLowerCase()) {
    case '親子廁所':
      return Icons.family_restroom;
    case '兒童遊戲區':
      return Icons.attractions;
    case '哺乳室':
      return Icons.child_friendly;
    case '尿布台':
      return Icons.baby_changing_station;
    case 'park':
      return Icons.park;
    case 'museum':
      return Icons.museum;
    default:
      return Icons.location_on;
  }
}

Color _colorForType(String infrastructureType) {
  switch (infrastructureType.toLowerCase()) {
    case '親子廁所':
      return const Color(0xFF06B6D4);
    case '兒童遊戲區':
      return const Color(0xFF22C55E);
    case '哺乳室':
      return const Color(0xFF8B5CF6);
    case '尿布台':
      return const Color(0xFFF97316);
    case 'museum':
      return const Color(0xFF3B82F6);
    default:
      return const Color(0xFF0EA5E9);
  }
}

ll.LatLng _resolveCenter(List<Place> places, Place? focusPlace) {
  if (focusPlace != null) {
    return ll.LatLng(focusPlace.latitude, focusPlace.longitude);
  }
  if (places.isNotEmpty) {
    return ll.LatLng(places.first.latitude, places.first.longitude);
  }
  return ll.LatLng(taichungMapCenterLatitude, taichungMapCenterLongitude);
}
