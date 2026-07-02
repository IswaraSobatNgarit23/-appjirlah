import '../../models/evacuation_route.dart';
import '../constants/geo_constants.dart';

/// Data dummy rute evakuasi untuk keperluan development dan testing.
///
/// Untuk menambah/mengubah lokasi evakuasi dummy, edit file ini saja.
/// Saat integrasi backend, file ini tidak perlu dihapus — cukup jangan panggil.
List<EvacuationRoute> getDummyRoutes() {
  return [
    // --- 1. Lapangan Penanggal ---
    EvacuationRoute(
      id: 'penanggal',
      destination: 'Lapangan Penanggal',
      distance: '4.2 KM',
      estimate: '± 15 menit berjalan kaki',
      latitude: -8.2085,
      longitude: 112.9012,
      description: 'Lapangan terbuka luas di Desa Penanggal. '
          'Area aman dengan akses jalan lebar untuk kendaraan evakuasi.',
      locationType: LocationType.lapangan,
      capacity: 500,
      routeSteps: const [
        RouteStep(
          instruction: 'Keluar dari desa, jalan ke arah barat',
          distance: '800 m',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kiri di pertigaan Jl. Raya Pronojiwo',
          distance: '1.2 KM',
          direction: StepDirection.left,
        ),
        RouteStep(
          instruction: 'Lurus melewati jembatan Sungai Besuk Sat',
          distance: '1.5 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kanan, Lapangan Penanggal di sebelah kiri',
          distance: '700 m',
          direction: StepDirection.right,
        ),
        RouteStep(
          instruction: 'Tiba di Lapangan Penanggal',
          distance: '0 m',
          direction: StepDirection.destination,
        ),
      ],
      routeCoordinates: [
        [kDefaultUserLat, kDefaultUserLng],
        [-8.2145, 112.9300],
        [-8.2130, 112.9220],
        [-8.2110, 112.9150],
        [-8.2095, 112.9080],
        [-8.2085, 112.9012],
      ],
      emergencyContacts: const [
        EmergencyContact(name: 'BPBD Lumajang', phone: '(0334) 891234'),
        EmergencyContact(name: 'Posko Pronojiwo', phone: '0812-3456-7890'),
      ],
    ),

    // --- 2. SDN Supiturang ---
    EvacuationRoute(
      id: 'sdn_supiturang',
      destination: 'SDN Supiturang',
      distance: '6.1 KM',
      estimate: '± 25 menit berjalan kaki',
      latitude: -8.1980,
      longitude: 112.9520,
      description: 'Gedung sekolah dengan halaman luas. '
          'Tersedia toilet, air bersih, dan dapur umum darurat.',
      locationType: LocationType.sekolah,
      capacity: 300,
      routeSteps: const [
        RouteStep(
          instruction: 'Jalan ke arah utara melalui Jl. Desa Supiturang',
          distance: '1.0 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kanan di Jl. Raya Supiturang',
          distance: '2.0 KM',
          direction: StepDirection.right,
        ),
        RouteStep(
          instruction: 'Lurus melewati perempatan desa',
          distance: '1.8 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'SDN Supiturang ada di sebelah kanan jalan',
          distance: '1.3 KM',
          direction: StepDirection.slightRight,
        ),
        RouteStep(
          instruction: 'Tiba di SDN Supiturang',
          distance: '0 m',
          direction: StepDirection.destination,
        ),
      ],
      routeCoordinates: [
        [kDefaultUserLat, kDefaultUserLng],
        [-8.2120, 112.9370],
        [-8.2080, 112.9410],
        [-8.2040, 112.9460],
        [-8.2010, 112.9490],
        [-8.1980, 112.9520],
      ],
      emergencyContacts: const [
        EmergencyContact(name: 'Kepala Desa Supiturang', phone: '0813-5678-9012'),
        EmergencyContact(name: 'PMI Lumajang', phone: '(0334) 895678'),
      ],
    ),

    // --- 3. Balai Desa Candipuro ---
    EvacuationRoute(
      id: 'balai_candipuro',
      destination: 'Balai Desa Candipuro',
      distance: '8.5 KM',
      estimate: '± 35 menit berjalan kaki',
      latitude: -8.1850,
      longitude: 112.9180,
      description: 'Pusat koordinasi evakuasi tingkat kecamatan. '
          'Dilengkapi posko kesehatan dan logistik darurat.',
      locationType: LocationType.balaiDesa,
      capacity: 400,
      routeSteps: const [
        RouteStep(
          instruction: 'Keluar desa menuju Jl. Raya Pronojiwo',
          distance: '1.5 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kiri arah Candipuro',
          distance: '2.5 KM',
          direction: StepDirection.left,
        ),
        RouteStep(
          instruction: 'Lurus melewati Pasar Candipuro',
          distance: '2.0 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kanan ke Jl. Balai Desa',
          distance: '1.5 KM',
          direction: StepDirection.right,
        ),
        RouteStep(
          instruction: 'Lurus 1 KM, Balai Desa di sebelah kiri',
          distance: '1.0 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Tiba di Balai Desa Candipuro',
          distance: '0 m',
          direction: StepDirection.destination,
        ),
      ],
      routeCoordinates: [
        [kDefaultUserLat, kDefaultUserLng],
        [-8.2130, 112.9310],
        [-8.2080, 112.9260],
        [-8.2020, 112.9230],
        [-8.1960, 112.9210],
        [-8.1900, 112.9195],
        [-8.1850, 112.9180],
      ],
      emergencyContacts: const [
        EmergencyContact(name: 'Camat Candipuro', phone: '0811-2345-6789'),
        EmergencyContact(name: 'BPBD Lumajang', phone: '(0334) 891234'),
        EmergencyContact(name: 'Puskesmas Candipuro', phone: '(0334) 893456'),
      ],
    ),

    // --- 4. Puskesmas Senduro ---
    EvacuationRoute(
      id: 'puskesmas_senduro',
      destination: 'Puskesmas Senduro',
      distance: '10.3 KM',
      estimate: '± 45 menit berkendaraan',
      latitude: -8.1720,
      longitude: 112.8950,
      description: 'Fasilitas kesehatan dengan UGD dan ruang rawat. '
          'Prioritas untuk evakuasi medis dan lansia.',
      locationType: LocationType.puskesmas,
      capacity: 150,
      routeSteps: const [
        RouteStep(
          instruction: 'Keluar desa ke Jl. Raya Pronojiwo arah barat',
          distance: '2.0 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kanan arah Senduro',
          distance: '3.0 KM',
          direction: StepDirection.right,
        ),
        RouteStep(
          instruction: 'Lurus melewati perkebunan',
          distance: '2.5 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kiri masuk Kec. Senduro',
          distance: '1.8 KM',
          direction: StepDirection.left,
        ),
        RouteStep(
          instruction: 'Puskesmas di sisi kanan, 1 KM setelah pasar',
          distance: '1.0 KM',
          direction: StepDirection.slightRight,
        ),
        RouteStep(
          instruction: 'Tiba di Puskesmas Senduro',
          distance: '0 m',
          direction: StepDirection.destination,
        ),
      ],
      routeCoordinates: [
        [kDefaultUserLat, kDefaultUserLng],
        [-8.2120, 112.9280],
        [-8.2060, 112.9200],
        [-8.1980, 112.9130],
        [-8.1900, 112.9060],
        [-8.1810, 112.9000],
        [-8.1720, 112.8950],
      ],
      emergencyContacts: const [
        EmergencyContact(name: 'Puskesmas Senduro', phone: '(0334) 897890'),
        EmergencyContact(name: 'Ambulans Lumajang', phone: '119'),
      ],
    ),

    // --- 5. Posko Induk BPBD Lumajang ---
    EvacuationRoute(
      id: 'posko_bpbd',
      destination: 'Posko Induk BPBD Lumajang',
      distance: '15.0 KM',
      estimate: '± 30 menit berkendaraan',
      latitude: -8.1350,
      longitude: 112.9080,
      description: 'Pusat komando utama penanggulangan bencana. '
          'Tersedia helipad, gudang logistik, dan pusat komunikasi.',
      locationType: LocationType.posko,
      capacity: 1000,
      routeSteps: const [
        RouteStep(
          instruction: 'Keluar desa ke Jl. Raya Pronojiwo',
          distance: '2.0 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kiri ke Jl. Raya Lumajang',
          distance: '4.0 KM',
          direction: StepDirection.left,
        ),
        RouteStep(
          instruction: 'Lurus melewati Kecamatan Candipuro',
          distance: '3.5 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Ikuti rambu ke Kota Lumajang',
          distance: '3.0 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kanan ke Jl. BPBD',
          distance: '1.5 KM',
          direction: StepDirection.right,
        ),
        RouteStep(
          instruction: 'Posko Induk BPBD di sebelah kanan',
          distance: '1.0 KM',
          direction: StepDirection.slightRight,
        ),
        RouteStep(
          instruction: 'Tiba di Posko Induk BPBD Lumajang',
          distance: '0 m',
          direction: StepDirection.destination,
        ),
      ],
      routeCoordinates: [
        [kDefaultUserLat, kDefaultUserLng],
        [-8.2100, 112.9280],
        [-8.2000, 112.9220],
        [-8.1880, 112.9170],
        [-8.1750, 112.9130],
        [-8.1600, 112.9100],
        [-8.1480, 112.9090],
        [-8.1350, 112.9080],
      ],
      emergencyContacts: const [
        EmergencyContact(name: 'BPBD Lumajang', phone: '(0334) 891234'),
        EmergencyContact(name: 'SAR Lumajang', phone: '(0334) 899012'),
        EmergencyContact(name: 'Polres Lumajang', phone: '(0334) 881100'),
      ],
    ),

    // --- 6. Rumah Gombet ---
    EvacuationRoute(
      id: 'rumah_gombet',
      destination: 'Rumah Gombet',
      distance: '4.2 KM',
      estimate: '± 15 menit berjalan kaki',
      latitude: -8.2085,
      longitude: 112.9012,
      description: 'Rumah Gombet. '
          'Area aman dengan akses jalan lebar untuk kendaraan evakuasi.',
      locationType: LocationType.gedung,
      capacity: 50,
      routeSteps: const [
        RouteStep(
          instruction: 'Keluar dari desa, jalan ke arah barat',
          distance: '800 m',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kiri di pertigaan Jl. Raya Pronojiwo',
          distance: '1.2 KM',
          direction: StepDirection.left,
        ),
        RouteStep(
          instruction: 'Lurus melewati jembatan Sungai Besuk Sat',
          distance: '1.5 KM',
          direction: StepDirection.straight,
        ),
        RouteStep(
          instruction: 'Belok kanan, Rumah Gombet di sebelah kiri',
          distance: '700 m',
          direction: StepDirection.right,
        ),
        RouteStep(
          instruction: 'Tiba di Rumah Gombet',
          distance: '0 m',
          direction: StepDirection.destination,
        ),
      ],
      routeCoordinates: [
        [kDefaultUserLat, kDefaultUserLng],
        [-8.2145, 112.9300],
        [-8.2130, 112.9220],
        [-8.2110, 112.9150],
        [-8.2095, 112.9080],
        [-8.2085, 112.9012],
      ],
      emergencyContacts: const [
        EmergencyContact(name: 'BPBD Lumajang', phone: '(0334) 891234'),
        EmergencyContact(name: 'Posko Pronojiwo', phone: '0812-3456-7890'),
      ],
    ),
  ];
}
