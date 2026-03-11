import 'package:dio/dio.dart';

import '../models/place.dart';

class PlaceApiService {
  PlaceApiService({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080'),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;

  Future<List<Place>> fetchPlaces() async {
    final response = await _dio.get<List<dynamic>>('/places');
    final data = response.data ?? [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Place.fromJson)
        .where((place) => place.latitude != 0 && place.longitude != 0)
        .toList();
  }
}
