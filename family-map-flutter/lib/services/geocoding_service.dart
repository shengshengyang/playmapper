import 'package:dio/dio.dart';

class GeocodingResult {
  const GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

class GeocodingService {
  GeocodingService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://nominatim.openstreetmap.org',
            headers: const {
              'User-Agent': 'family-map-flutter/1.0',
            },
          ),
        );

  final Dio _dio;

  Future<GeocodingResult?> geocodeAddress(String address) async {
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: {
        'q': address,
        'format': 'jsonv2',
        'limit': 1,
      },
    );

    final list = response.data;
    if (list == null || list.isEmpty) {
      return null;
    }

    final first = list.first as Map<String, dynamic>;
    return GeocodingResult(
      latitude: double.parse(first['lat'] as String),
      longitude: double.parse(first['lon'] as String),
      address: (first['display_name'] as String?) ?? address,
    );
  }

  Future<String?> reverseGeocode({required double latitude, required double longitude}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reverse',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'format': 'jsonv2',
      },
    );

    return response.data?['display_name'] as String?;
  }
}
