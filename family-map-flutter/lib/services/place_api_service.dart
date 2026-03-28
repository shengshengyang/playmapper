import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/mock_map_places.dart';
import '../models/place.dart';

class PlaceApiService {
  PlaceApiService({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl:
                  baseUrl ??
                  dotenv.env['API_BASE_URL'] ??
                  'http://localhost:8080',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Future<List<Place>> fetchPlaces({bool includeAllStatus = false}) async {
    try {
      final endpoint = includeAllStatus ? '/places/all' : '/places';
      final response = await _dio.get<dynamic>(endpoint);
      return _decodePlaces(response.data);
    } on DioException catch (e) {
      debugPrint('fetchPlaces failed: ${e.message}');
      rethrow;
    }
  }

  Future<List<Place>> fetchMapMarkers() async {
    try {
      final response = await _dio.get<dynamic>('/places/map-markers');
      final places = _decodePlaces(response.data);
      if (places.isEmpty) {
        debugPrint(
          'Map markers endpoint returned empty data. Using Taichung mock places.',
        );
        return getTaichungMockPlaces();
      }
      return places;
    } on DioException catch (e) {
      debugPrint('fetchMapMarkers failed: ${e.message}');
      return getTaichungMockPlaces();
    }
  }

  Future<Place> submitPlace({
    required String name,
    required String infrastructureType,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
  }) async {
    final response = await _dio.post<dynamic>(
      '/places',
      data: {
        'name': name,
        'infrastructureType': infrastructureType,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return Place.fromJson(payload);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: 'Unexpected response payload for submitPlace',
    );
  }

  List<Place> _decodePlaces(dynamic payload) {
    final List<dynamic> data;
    if (payload is List) {
      data = payload;
    } else if (payload is Map && payload['data'] is List) {
      data = payload['data'] as List<dynamic>;
    } else {
      data = const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Place.fromJson)
        .where((place) => place.latitude != 0 && place.longitude != 0)
        .toList();
  }
}
