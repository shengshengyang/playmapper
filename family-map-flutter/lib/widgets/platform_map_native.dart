import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as mapkit;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

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
          infoWindow: mapkit.InfoWindow(title: place.name, snippet: place.address),
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
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => onPlaceTap(place),
                  child: Icon(
                    _iconForType(place.infrastructureType),
                    color: place.isPending ? Colors.grey : (focusPlace?.id == place.id ? Colors.deepOrange : Colors.red),
                    size: 32,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ],
  );
}

IconData _iconForType(String infrastructureType) {
  switch (infrastructureType.toLowerCase()) {
    case '親子廁所':
      return Icons.family_restroom;
    case '親子景點':
      return Icons.park;
    case '公園':
    case 'park':
      return Icons.park;
    default:
      return Icons.location_on;
  }
}

ll.LatLng _resolveCenter(List<Place> places, Place? focusPlace) {
  if (focusPlace != null) {
    return ll.LatLng(focusPlace.latitude, focusPlace.longitude);
  }
  if (places.isNotEmpty) {
    return ll.LatLng(places.first.latitude, places.first.longitude);
  }
  return ll.LatLng(25.0330, 121.5654);
}
