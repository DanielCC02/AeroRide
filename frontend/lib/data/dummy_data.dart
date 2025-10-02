import '../models/airport.dart';
import '../models/plane.dart';

/// AVIONES (mapeados a tus assets)
const planes = <Plane>[
  Plane(
    id: 'p1',
    model: 'Cessna Caravan (208B)',
    seats: 12,
    maxWeightKg: 1500,
    priceUsd: 1200,
    image: 'lib/assets/images/avioneta_CESSNACARAVAN.jpg',
  ),
  Plane(
    id: 'p2',
    model: 'Cessna 206',
    seats: 5,
    maxWeightKg: 600,
    priceUsd: 700,
    image: 'lib/assets/images/avioneta_CESSNA206.jpg',
  ),
  Plane(
    id: 'p3',
    model: 'Piper PA-34',
    seats: 5,
    maxWeightKg: 650,
    priceUsd: 850,
    image: 'lib/assets/images/avioneta_piperPA-34.jpg',
  ),
];

/// AEROPUERTOS (con imagen)
/// - SJO y LIR por ahora usan una imagen placeholder (main_menu_pic.jpg).
/// - Destinos con fotos tuyas: Tamarindo (TNO), Santa Teresa ~ Tambor (TMU), Quepos (XQP), Nosara (NOB).
final airports = <Airport>[
  Airport(
    codeIata: 'SJO',
    name: 'San José',
    country: 'Costa Rica',
    codeOaci: 'MROC',
    image: 'lib/assets/images/main_menu_pic.jpg',
  ),
  Airport(
    codeIata: 'LIR',
    name: 'Liberia',
    country: 'Costa Rica',
    codeOaci: 'MRLB',
    image: 'lib/assets/images/main_menu_pic.jpg',
  ),
  Airport(
    codeIata: 'TNO',
    name: 'Tamarindo',
    country: 'Costa Rica',
    codeOaci: 'MRTM',
    image: 'lib/assets/images/destino_tamarindo.jpg',
  ),
  Airport(
    codeIata: 'TMU',
    name: 'Tambor (p/ Santa Teresa)',
    country: 'Costa Rica',
    codeOaci: 'MRTR',
    image: 'lib/assets/images/destino_santateresa.jpg',
  ),
  Airport(
    codeIata: 'XQP',
    name: 'Quepos',
    country: 'Costa Rica',
    codeOaci: 'MRQP',
    image: 'lib/assets/images/destino_quepos.jpg',
  ),
  Airport(
    codeIata: 'NOB',
    name: 'Nosara',
    country: 'Costa Rica',
    codeOaci: 'MRNS',
    image: 'lib/assets/images/destino_nosara.jpg',
  ),
];
