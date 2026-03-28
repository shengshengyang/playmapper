import 'package:family_map_flutter/data/mock_map_places.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'taichung mock places include approved and pending samples with multiple marker types',
    () {
      final places = getTaichungMockPlaces();

      expect(places.where((place) => place.isApproved).length, 2);
      expect(places.where((place) => place.isPending).length, 2);
      expect(
        places.map((place) => place.infrastructureType).toSet(),
        containsAll(<String>['兒童遊戲區', '哺乳室', '親子廁所', '尿布台']),
      );
    },
  );
}
