import '../models/place.dart';

const taichungMapCenterLatitude = 24.1477;
const taichungMapCenterLongitude = 120.6736;

List<Place> getTaichungMockPlaces() {
  return const [
    Place(
      id: 'tc-approved-1',
      name: '秋紅谷親子遊戲區',
      address: '台中市西屯區朝富路30號',
      latitude: 24.1676,
      longitude: 120.6395,
      infrastructureType: '兒童遊戲區',
      facilities: ['遊戲區', '休息座椅', '親子廁所'],
      minAge: 3,
      maxAge: 12,
      status: 'approved',
    ),
    Place(
      id: 'tc-approved-2',
      name: '國立自然科學博物館哺乳室',
      address: '台中市北區館前路1號',
      latitude: 24.1577,
      longitude: 120.6662,
      infrastructureType: '哺乳室',
      facilities: ['哺乳室', '飲水機', '尿布台'],
      minAge: 0,
      maxAge: 4,
      status: 'approved',
    ),
    Place(
      id: 'tc-pending-1',
      name: '草悟道送審親子廁所',
      address: '台中市西區英才路534號附近',
      latitude: 24.1489,
      longitude: 120.6623,
      infrastructureType: '親子廁所',
      facilities: ['親子廁所', '洗手台'],
      minAge: 1,
      maxAge: 10,
      status: 'pending',
    ),
    Place(
      id: 'tc-pending-2',
      name: '台中公園送審尿布台',
      address: '台中市中區公園路37-1號附近',
      latitude: 24.1452,
      longitude: 120.6840,
      infrastructureType: '尿布台',
      facilities: ['尿布台', '遮雨空間'],
      minAge: 0,
      maxAge: 3,
      status: 'pending',
    ),
  ];
}
