import 'package:flutter/widgets.dart';

import '../models/place.dart';
import 'platform_map_native.dart' if (dart.library.html) 'platform_map_web.dart';

class PlatformMap extends StatelessWidget {
  const PlatformMap({
    super.key,
    required this.places,
    this.focusPlace,
    this.mapboxAccessToken,
  });

  final List<Place> places;
  final Place? focusPlace;
  final String? mapboxAccessToken;

  @override
  Widget build(BuildContext context) {
    return buildPlatformMap(
      context,
      places: places,
      focusPlace: focusPlace,
      mapboxAccessToken: mapboxAccessToken,
    );
  }
}
