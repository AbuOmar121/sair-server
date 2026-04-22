class Report {
  final String id;
  final String citizenId;
  final String officerId;
  final String zoneId;

  final double lat;
  final double lng;
  final String address;

  final String accidentType;
  final String description;
  final DateTime occurredAt;
  final String locationSource;

  final List<String> mediaUrls;

  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.citizenId,
    required this.officerId,
    required this.zoneId,
    required this.lat,
    required this.lng,
    required this.address,
    required this.accidentType,
    required this.description,
    required this.occurredAt,
    required this.locationSource,
    required this.mediaUrls,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      citizenId: json['citizenId'] as String,
      officerId: json['officerId'] as String,
      zoneId: json['zoneId'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      accidentType: json['accidentType'] as String,
      description: json['description'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      locationSource: json['locationSource'] as String,
      mediaUrls: (json['mediaUrls'] as List<dynamic>).cast<String>(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'citizenId': citizenId,
      'officerId': officerId,
      'zoneId': zoneId,
      'lat': lat,
      'lng': lng,
      'address': address,
      'accidentType': accidentType,
      'description': description,
      'occurredAt': occurredAt.toIso8601String(),
      'locationSource': locationSource,
      'mediaUrls': mediaUrls,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
