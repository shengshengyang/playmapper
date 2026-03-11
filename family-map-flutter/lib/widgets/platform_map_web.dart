import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

Widget buildPlatformMap(
  BuildContext context, {
  required List<Place> places,
  required Place? focusPlace,
  required String? mapboxAccessToken,
}) {
  final center = _resolveCenter(places, focusPlace);

  if (mapboxAccessToken == null || mapboxAccessToken.isEmpty) {
    return const Center(
      child: Text('請設定 MAPBOX_ACCESS_TOKEN 才能載入 Web 地圖'),
    );
  }

  return FlutterMap(
    options: MapOptions(
      initialCenter: center,
      initialZoom: 13,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
        additionalOptions: {'accessToken': mapboxAccessToken},
      ),
      MarkerLayer(
        markers: places
            .map(
              (place) => Marker(
                point: LatLng(place.latitude, place.longitude),
                width: 44,
                height: 44,
                child: Tooltip(
                  message: place.name,
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 34),
                ),
              ),
            )
            .toList(),
      ),
    ],
  );
}

LatLng _resolveCenter(List<Place> places, Place? focusPlace) {
  if (focusPlace != null) {
    return LatLng(focusPlace.latitude, focusPlace.longitude);
  }
  if (places.isNotEmpty) {
    return LatLng(places.first.latitude, places.first.longitude);
  }
  return const LatLng(25.0330, 121.5654);
}
