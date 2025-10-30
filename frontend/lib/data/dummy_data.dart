// lib/data/dummy_data.dart
// Mantiene ÚNICAMENTE el dummy de aviones.
// Los aeropuertos ahora se consumen desde la BD vía AirportService
// y el modelo de dominio (airport_model.dart).

import '../models/plane.dart';

/// AVIONES (mapeados a tus assets)
const planes = <Plane>[
  Plane(
    id: 'p1',
    model: 'Cessna Caravan (208B)',
    seats: 12,
    maxWeightKg: 1500,
    priceUsd: 1200,
    image: 'assets/images/avioneta_CESSNACARAVAN.jpg',
  ),
  Plane(
    id: 'p2',
    model: 'Cessna 206',
    seats: 5,
    maxWeightKg: 600,
    priceUsd: 700,
    image: 'assets/images/avioneta_CESSNA206.jpg',
  ),
  Plane(
    id: 'p3',
    model: 'Piper PA-34',
    seats: 5,
    maxWeightKg: 650,
    priceUsd: 850,
    image: 'assets/images/avioneta_piperPA-34.jpg',
  ),
];

// ❌ Se removieron los aeropuertos y helpers locales.
// ✅ Usa AirportService.searchAirports(...) para sugerencias/búsqueda real.
