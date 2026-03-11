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
}) {
  if (Platform.isIOS) {
    return _buildMapKit(places, focusPlace);
  }
  return _buildMapboxTileMap(places, focusPlace, mapboxAccessToken);
}

Widget _buildMapKit(List<Place> places, Place? focusPlace) {
  final center = _resolveCenter(places, focusPlace);
  final annotations = places
      .map(
        (place) => mapkit.Annotation(
          annotationId: mapkit.AnnotationId('place_${place.id}'),
          position: mapkit.LatLng(place.latitude, place.longitude),
          infoWindow: mapkit.InfoWindow(title: place.name),
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

Widget _buildMapboxTileMap(List<Place> places, Place? focusPlace, String? mapboxAccessToken) {
  final center = _resolveCenter(places, focusPlace);

  if (mapboxAccessToken == null || mapboxAccessToken.isEmpty) {
    return const Center(
      child: Text('請設定 MAPBOX_ACCESS_TOKEN 才能載入 Android 地圖'),
    );
  }

  return FlutterMap(
    options: MapOptions(
      initialCenter: center,
      initialZoom: 13,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
        additionalOptions: {'accessToken': mapboxAccessToken},
      ),
      MarkerLayer(
        markers: places
            .map(
              (place) => Marker(
                point: ll.LatLng(place.latitude, place.longitude),
                width: 44,
                height: 44,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 34),
              ),
            )
            .toList(),
      ),
    ],
  );
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
