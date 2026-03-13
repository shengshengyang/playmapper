import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/place.dart';

class PlaceApiService {
  PlaceApiService({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;

  Future<List<Place>> fetchPlaces({bool includeAllStatus = false}) async {
    try {
      final endpoint = includeAllStatus ? '/places/all' : '/places';
      debugPrint('Fetching places from: ${_dio.options.baseUrl}$endpoint');
      final response = await _dio.get<dynamic>(endpoint);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data type: ${response.data.runtimeType}');
      debugPrint('Response data: ${response.data}');

      final List<dynamic> data;
      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['data'] != null) {
        data = response.data['data'] as List<dynamic>;
      } else {
        data = [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(Place.fromJson)
          .where((place) => place.latitude != 0 && place.longitude != 0)
          .toList();
    } on DioException catch (e) {
      debugPrint('DioException: ${e.type} - ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
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

}
