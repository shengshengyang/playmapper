import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final center = _resolveCenter(places, focusPlace);

  return FlutterMap(
    options: MapOptions(
      initialCenter: center,
      initialZoom: 13,
      minZoom: 10,
      maxZoom: 18,
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
              (place) => _buildPlaceMarker(
                place,
                onPlaceTap: onPlaceTap,
                isSelected: focusPlace?.id == place.id,
              ),
            )
            .toList(),
      ),
    ],
  );
}

Marker _buildPlaceMarker(
  Place place, {
  required ValueChanged<Place> onPlaceTap,
  bool isSelected = false,
}) {
  final color = place.isPending
      ? const Color(0xFFFFF7ED)
      : _getMarkerColor(place.infrastructureType);

  return Marker(
    point: LatLng(place.latitude, place.longitude),
    width: isSelected ? 56 : 48,
    height: isSelected ? 68 : 60,
    child: GestureDetector(
      onTap: () => onPlaceTap(place),
      child: Tooltip(
        message: '${place.name} (${place.statusLabel})',
        preferBelow: false,
        child: CustomPaint(
          painter: _MarkerPainter(
            fillColor: color,
            borderColor: place.isPending
                ? const Color(0xFFF59E0B)
                : Colors.white,
            isSelected: isSelected,
            isPending: place.isPending,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Icon(
                  _getIconForType(place.infrastructureType),
                  color: place.isPending
                      ? const Color(0xFFB45309)
                      : Colors.white,
                  size: isSelected ? 20 : 18,
                ),
                if (place.isPending)
                  const Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Text(
                      '審',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
              ],
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
    case '兒童遊戲區':
      return const Color(0xFF22C55E);
    case '哺乳室':
      return const Color(0xFF8B5CF6);
    case '尿布台':
      return const Color(0xFFF97316);
    case 'library':
      return const Color(0xFF3B82F6);
    case 'museum':
      return const Color(0xFFEC4899);
    default:
      return const Color(0xFF0EA5E9);
  }
}

IconData _getIconForType(String infrastructureType) {
  switch (infrastructureType.toLowerCase()) {
    case '親子廁所':
      return Icons.family_restroom;
    case '兒童遊戲區':
      return Icons.attractions;
    case '哺乳室':
      return Icons.child_friendly;
    case '尿布台':
      return Icons.baby_changing_station;
    case 'library':
      return Icons.local_library;
    case 'museum':
      return Icons.museum;
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
  return const LatLng(taichungMapCenterLatitude, taichungMapCenterLongitude);
}

class _MarkerPainter extends CustomPainter {
  const _MarkerPainter({
    required this.fillColor,
    required this.borderColor,
    required this.isSelected,
    required this.isPending,
  });

  final Color fillColor;
  final Color borderColor;
  final bool isSelected;
  final bool isPending;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h);
    path.quadraticBezierTo(w / 4, h * 0.7, w / 8, h * 0.25);
    path.arcToPoint(
      Offset(w * 7 / 8, h * 0.25),
      radius: Radius.circular(w / 2),
    );
    path.quadraticBezierTo(w * 3 / 4, h * 0.7, w / 2, h);

    canvas.drawPath(
      path.shift(const Offset(2, 2)),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.5 : 2.5;

    if (isPending) {
      _drawDashedPath(canvas, path, borderPaint);
    } else {
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, ui.Path source, Paint paint) {
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      const dash = 6.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dash);
        canvas.drawPath(segment, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        isSelected != oldDelegate.isSelected ||
        isPending != oldDelegate.isPending;
  }
}
