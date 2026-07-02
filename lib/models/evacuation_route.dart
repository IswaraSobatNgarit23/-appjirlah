/// Model data rute evakuasi.
///
/// Untuk integrasi database lokal/API:
/// ```dart
/// final route = EvacuationRoute.fromJson(apiResponse);
/// ```
class EvacuationRoute {
  /// Identifier unik lokasi.
  final String id;

  /// Nama titik kumpul / tujuan evakuasi.
  final String destination;

  /// Jarak tempuh (misal: "4.2 KM").
  final String distance;

  /// Perkiraan waktu tempuh (misal: "± 15 menit berjalan kaki").
  final String estimate;

  /// Koordinat latitude titik kumpul.
  final double latitude;

  /// Koordinat longitude titik kumpul.
  final double longitude;

  /// Deskripsi singkat lokasi evakuasi.
  final String description;

  /// Tipe lokasi (Lapangan, Balai Desa, Sekolah, dll).
  final LocationType locationType;

  /// Kapasitas penampungan (jumlah orang).
  final int capacity;

  /// Langkah-langkah rute evakuasi.
  final List<RouteStep> routeSteps;

  /// Daftar koordinat polyline rute (untuk digambar di peta).
  /// Format: List of [latitude, longitude] pairs.
  final List<List<double>> routeCoordinates;

  /// Daftar kontak darurat terkait rute ini.
  final List<EmergencyContact> emergencyContacts;

  const EvacuationRoute({
    required this.id,
    required this.destination,
    required this.distance,
    required this.estimate,
    required this.latitude,
    required this.longitude,
    this.description = '',
    this.locationType = LocationType.lapangan,
    this.capacity = 0,
    this.routeSteps = const [],
    this.routeCoordinates = const [],
    required this.emergencyContacts,
  });

  // ---------------------------------------------------------------------------
  // INTEGRASI DATABASE / API
  // ---------------------------------------------------------------------------

  factory EvacuationRoute.fromJson(Map<String, dynamic> json) {
    final contacts = (json['emergency_contacts'] as List<dynamic>?)
            ?.map((c) => EmergencyContact.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final steps = (json['route_steps'] as List<dynamic>?)
            ?.map((s) => RouteStep.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    final coords = (json['route_coordinates'] as List<dynamic>?)
            ?.map((c) => (c as List<dynamic>).map((v) => (v as num).toDouble()).toList())
            .toList() ??
        [];

    return EvacuationRoute(
      id: json['id'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      estimate: json['estimate'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      locationType: LocationType.fromString(json['location_type'] as String? ?? ''),
      capacity: json['capacity'] as int? ?? 0,
      routeSteps: steps,
      routeCoordinates: coords,
      emergencyContacts: contacts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'distance': distance,
      'estimate': estimate,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'location_type': locationType.name,
      'capacity': capacity,
      'route_steps': routeSteps.map((s) => s.toJson()).toList(),
      'route_coordinates': routeCoordinates,
      'emergency_contacts': emergencyContacts.map((c) => c.toJson()).toList(),
    };
  }
}

/// Tipe lokasi evakuasi.
enum LocationType {
  lapangan,
  balaiDesa,
  sekolah,
  puskesmas,
  posko,
  masjid,
  gedung;

  String get displayName {
    switch (this) {
      case LocationType.lapangan:
        return 'Lapangan';
      case LocationType.balaiDesa:
        return 'Balai Desa';
      case LocationType.sekolah:
        return 'Sekolah';
      case LocationType.puskesmas:
        return 'Puskesmas';
      case LocationType.posko:
        return 'Posko';
      case LocationType.masjid:
        return 'Masjid';
      case LocationType.gedung:
        return 'Gedung';
    }
  }

  String get emoji {
    switch (this) {
      case LocationType.lapangan:
        return '🏟️';
      case LocationType.balaiDesa:
        return '🏛️';
      case LocationType.sekolah:
        return '🏫';
      case LocationType.puskesmas:
        return '🏥';
      case LocationType.posko:
        return '⛺';
      case LocationType.masjid:
        return '🕌';
      case LocationType.gedung:
        return '🏢';
    }
  }

  static LocationType fromString(String value) {
    return LocationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LocationType.lapangan,
    );
  }
}

/// Langkah navigasi dalam rute evakuasi.
class RouteStep {
  /// Instruksi navigasi (misal: "Jalan lurus ke arah barat").
  final String instruction;

  /// Jarak segment ini (misal: "500 m").
  final String distance;

  /// Arah: straight, left, right, destination.
  final StepDirection direction;

  const RouteStep({
    required this.instruction,
    required this.distance,
    this.direction = StepDirection.straight,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      direction: StepDirection.fromString(json['direction'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'distance': distance,
      'direction': direction.name,
    };
  }
}

/// Arah langkah navigasi.
enum StepDirection {
  straight,
  left,
  right,
  slightLeft,
  slightRight,
  destination;

  static StepDirection fromString(String value) {
    return StepDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StepDirection.straight,
    );
  }
}

/// Kontak darurat (nama instansi + nomor telepon).
class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.phone,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}
