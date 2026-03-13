class Place {
  const Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.infrastructureType,
    this.address,
    this.description,
    this.facilities = const [],
    this.minAge,
    this.maxAge,
    this.status = 'approved',
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String infrastructureType;
  final String? address;
  final String? description;
  final List<String> facilities;
  final int? minAge;
  final int? maxAge;
  final String status;

  bool get isPending => status.toLowerCase() == 'pending';

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as int,
      name: json['name'] as String? ?? '未命名設施',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      infrastructureType: json['infrastructureType'] as String? ?? '未知類型',
      address: json['address'] as String?,
      description: json['description'] as String?,
      facilities: (json['facilities'] as List?)?.map((e) => '$e').toList() ?? const [],
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      status: json['status'] as String? ?? 'approved',
    );
  }
}
