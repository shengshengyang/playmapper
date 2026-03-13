import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

Widget buildPlatformMap(
  BuildContext context, {
  required List<Place> places,
  required Place? focusPlace,
  required String? mapboxAccessToken,
  required ValueChanged<Place> onPlaceTap,
}) {
  final center = _resolveCenter(places, focusPlace);

  return FlutterMap(
    options: MapOptions(
      initialCenter: center,
      initialZoom: 13,
      minZoom: 10,
      maxZoom: 18,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.familymap.app',
      ),
      MarkerLayer(
        markers: places
            .map((place) => _buildPlaceMarker(place, onPlaceTap: onPlaceTap, isSelected: focusPlace?.id == place.id))
            .toList(),
      ),
    ],
  );
}

Marker _buildPlaceMarker(Place place, {required ValueChanged<Place> onPlaceTap, bool isSelected = false}) {
  final color = _getMarkerColor(place.infrastructureType);

  return Marker(
    point: LatLng(place.latitude, place.longitude),
    width: isSelected ? 48 : 40,
    height: isSelected ? 56 : 48,
    child: GestureDetector(
      onTap: () => onPlaceTap(place),
      child: Tooltip(
        message: place.name,
        preferBelow: false,
        child: CustomPaint(
          painter: _MarkerPainter(
            color: color,
            isSelected: isSelected,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              _getIconForType(place.infrastructureType),
              color: Colors.white,
              size: isSelected ? 20 : 16,
            ),
          ),
        ),
      ),
    ),
  );
}

Color _getMarkerColor(String infrastructureType) {
  switch (infrastructureType.toLowerCase()) {
    case '親子廁所':
      return const Color(0xFF06B6D4);
    case '親子景點':
      return const Color(0xFF22C55E);
    case '公園':
    case 'park':
      return const Color(0xFF22C55E);
    case '圖書館':
    case 'library':
      return const Color(0xFF3B82F6);
    case '博物館':
    case 'museum':
      return const Color(0xFF8B5CF6);
    case '遊樂園':
    case 'amusement_park':
      return const Color(0xFFF59E0B);
    case '動物園':
    case 'zoo':
      return const Color(0xFFEC4899);
    default:
      return const Color(0xFF0EA5E9);
  }
}

IconData _getIconForType(String infrastructureType) {
  switch (infrastructureType.toLowerCase()) {
    case '親子廁所':
      return Icons.family_restroom;
    case '親子景點':
      return Icons.park;
    case '公園':
    case 'park':
      return Icons.park;
    case '圖書館':
    case 'library':
      return Icons.local_library;
    case '博物館':
    case 'museum':
      return Icons.museum;
    case '遊樂園':
    case 'amusement_park':
      return Icons.attractions;
    case '動物園':
    case 'zoo':
      return Icons.pets;
    default:
      return Icons.location_on;
  }
}

LatLng _resolveCenter(List<Place> places, Place? focusPlace) {
  if (focusPlace != null) {
    return LatLng(focusPlace.latitude, focusPlace.longitude);
  }
  if (places.isNotEmpty) {
    return LatLng(places.first.latitude, places.first.longitude);
  }
  return const LatLng(24.1477, 120.6736);
}

class _MarkerPainter extends CustomPainter {
  final Color color;
  final bool isSelected;

  _MarkerPainter({required this.color, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = ui.Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h);
    path.quadraticBezierTo(w / 4, h * 0.7, w / 8, h * 0.25);
    path.arcToPoint(Offset(w * 7 / 8, h * 0.25), radius: Radius.circular(w / 2));
    path.quadraticBezierTo(w * 3 / 4, h * 0.7, w / 2, h);
    canvas.drawPath(path.shift(const Offset(2, 2)), shadowPaint);

    path.reset();
    path.moveTo(w / 2, h);
    path.quadraticBezierTo(w / 4, h * 0.7, w / 8, h * 0.25);
    path.arcToPoint(Offset(w * 7 / 8, h * 0.25), radius: Radius.circular(w / 2));
    path.quadraticBezierTo(w * 3 / 4, h * 0.7, w / 2, h);
    canvas.drawPath(path, paint);

    if (isSelected) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter oldDelegate) {
    return color != oldDelegate.color || isSelected != oldDelegate.isSelected;
  }
}
