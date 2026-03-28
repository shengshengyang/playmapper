import 'package:dio/dio.dart';
import 'package:family_map_flutter/data/mock_map_places.dart';
import 'package:family_map_flutter/models/place.dart';
import 'package:family_map_flutter/screens/home_screen.dart';
import 'package:family_map_flutter/services/place_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlaceApiService extends PlaceApiService {
  _FakePlaceApiService(this._places)
      : super(
          dio: Dio(BaseOptions(baseUrl: 'http://localhost:8080')),
        );

  final List<Place> _places;

  @override
  Future<List<Place>> fetchMapMarkers() async {
    return _places;
  }
}

void main() {
  testWidgets('home screen renders Taichung test marker stats and legend',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          apiService: _FakePlaceApiService(getTaichungMockPlaces()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('圖例（台中測試點）'), findsOneWidget);
    expect(find.text('已審核：2'), findsOneWidget);
    expect(find.text('待審核：2'), findsOneWidget);
    expect(find.text('秋紅谷親子遊戲區'), findsOneWidget);
    expect(find.text('草悟道送審親子廁所'), findsOneWidget);
  });
}
