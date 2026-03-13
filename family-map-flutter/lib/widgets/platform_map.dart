import 'package:flutter/widgets.dart';

import '../models/place.dart';
import 'platform_map_native.dart' if (dart.library.html) 'platform_map_web.dart';

class PlatformMap extends StatelessWidget {
  const PlatformMap({
    super.key,
    required this.places,
    this.focusPlace,
    this.mapboxAccessToken,
    required this.onPlaceTap,
    required this.onMapTap,
  });

  final List<Place> places;
  final Place? focusPlace;
  final String? mapboxAccessToken;
  final ValueChanged<Place> onPlaceTap;
  final void Function(double latitude, double longitude) onMapTap;

  @override
  Widget build(BuildContext context) {
    return buildPlatformMap(
      context,
      places: places,
      focusPlace: focusPlace,
      mapboxAccessToken: mapboxAccessToken,
      onPlaceTap: onPlaceTap,
      onMapTap: onMapTap,
    );
  }
}
