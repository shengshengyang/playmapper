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

  final String id;
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
  bool get isApproved => !isPending;
  String get statusLabel => isPending ? '待審核' : '已審核';

  factory Place.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['reviewStatus'] ?? json['status'] ?? 'approved';

    return Place(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? '未命名景點',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      infrastructureType:
          json['infrastructureType'] as String? ??
          json['type'] as String? ??
          '一般設施',
      address: json['address'] as String?,
      description: json['description'] as String?,
      facilities:
          (json['facilities'] as List?)?.map((e) => '$e').toList() ?? const [],
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      status: '$rawStatus',
    );
  }
}
