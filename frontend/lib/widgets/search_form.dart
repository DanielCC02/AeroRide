import 'package:flutter/material.dart';
import 'datetime_picker_modal.dart';
import '../data/dummy_data.dart';
import '../models/search_criteria.dart';
import '../screens/plane_list_screen.dart';

/// SearchForm
/// ---------------------------------------------------------------------------
/// Formulario principal del flujo de reserva en Home:
/// - Tipo de viaje (One-way / Round trip)
/// - Selección de aeropuertos (From / To)
/// - Fecha y hora (usa `DateTimePickerModal`)
/// - Número de pasajeros (stepper)
/// - Botón Search (navega a `PlaneListScreen` con `SearchCriteria`)
///
/// DETALLES DE UX / UI:
/// - El encabezado “Flight” (icono + texto) está **centrado** (requisito).
/// - El “hero” superior usa la imagen `assets/images/main_menu_pic.jpg`.
/// - Los campos “From/To” son de texto simple (mock); se resuelven con
///   `findAirportByCodeOrName` (IATA o nombre completo).
///
/// NAVEGACIÓN:
/// - Al pulsar “Search” se valida que haya origen, destino y fecha/hora
///   de salida; se construye un `SearchCriteria` y se hace push a
///   `PlaneListScreen(criteria: ...)`.
///
/// POSIBLES MEJORAS FUTURAS:
/// - Cambiar “From/To” por pickers de aeropuertos con lista sugerida.
/// - Internacionalización de fechas/meses con `intl`.
/// - Mover límites de pasajeros a configuración/tema.
class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  // ---- Estado del formulario ------------------------------------------------
  bool _isRoundTrip = false;

  DateTime? _departureDateTime; // Fecha/hora de salida
  DateTime? _returnDateTime;    // Fecha/hora de regreso (si aplica)

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  int _pax = 1;

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  // ---- Selectores / modales -------------------------------------------------

  /// Abre el modal de selección de fecha y hora (salida o regreso).
  /// Devuelve el valor elegido a través de `onSelected` del modal.
  Future<void> _openDatePicker({required bool isReturn}) async {
    final fromAp = findAirportByCodeOrName(_fromCtrl.text.trim());
    final toAp   = findAirportByCodeOrName(_toCtrl.text.trim());
    final routeTitle = (fromAp != null && toAp != null)
        ? '${fromAp.codeOaci} (${fromAp.codeIata}) → ${toAp.name}'
        : null;

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return DateTimePickerModal(
          routeTitle: routeTitle,
          initialDateTime: isReturn ? _returnDateTime : _departureDateTime,
          onSelected: (selected) {
            setState(() {
              if (isReturn) {
                _returnDateTime = selected;
              } else {
                _departureDateTime = selected;
              }
            });
          },
        );
      },
    );
  }

  // ---- Acción principal -----------------------------------------------------

  /// Valida campos requeridos y navega a `PlaneListScreen` con `SearchCriteria`.
  void _search() {
    FocusScope.of(context).unfocus();

    if (_fromCtrl.text.trim().isEmpty || _toCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select origin and destination')),
      );
      return;
    }
    if (_departureDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date & time')),
      );
      return;
    }

    final from = findAirportByCodeOrName(_fromCtrl.text.trim());
    final to   = findAirportByCodeOrName(_toCtrl.text.trim());
    if (from == null || to == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airport not found. Try IATA (e.g., SJO) or full name.')),
      );
      return;
    }

    final criteria = SearchCriteria(
      from: from,
      to: to,
      passengers: _pax,
      departure: _departureDateTime!,
    );

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => PlaneListScreen(criteria: criteria)),
    );
  }

  // ---- Utilidades de formato ------------------------------------------------

  /// Devuelve un texto estilo “october 8, 2025  9:40 a.m.” o vacío si `null`.
  String _formatDT(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'p.m.' : 'a.m.';
    final mm = dt.minute.toString().padLeft(2, '0');
    final months = [
      'january','february','march','april','may','june',
      'july','august','september','october','november','december'
    ];
    final month = months[dt.month - 1];
    return '$month ${dt.day}, ${dt.year}  $h:$mm $ampm';
  }

  // ---- Build ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // HERO (mockup)
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/main_menu_pic.jpg',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 10),

        // ===== Encabezado "Flight" centrado (icono + texto) =====
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flight_takeoff, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 6),
              Text(
                'Flight',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Card del formulario (contenedor con sombra suave)
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // One-way / Round trip (píldoras)
              Row(
                children: [
                  Expanded(
                    child: _TripPill(
                      label: 'One-way',
                      selected: !_isRoundTrip,
                      onTap: () => setState(() => _isRoundTrip = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TripPill(
                      label: 'Round trip',
                      selected: _isRoundTrip,
                      onTap: () => setState(() => _isRoundTrip = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // From / To (mock textfields)
              _TextFieldMock(label: 'From', controller: _fromCtrl),
              const SizedBox(height: 8),
              _TextFieldMock(label: 'To', controller: _toCtrl),
              const SizedBox(height: 8),

              // Date / Time (salida y, si aplica, regreso)
              _DateField(
                label: _isRoundTrip ? 'Departure date and time' : 'Date and time',
                valueText: _formatDT(_departureDateTime),
                onTap: () => _openDatePicker(isReturn: false),
              ),
              if (_isRoundTrip) ...[
                const SizedBox(height: 8),
                _DateField(
                  label: 'Return date and time',
                  valueText: _formatDT(_returnDateTime),
                  onTap: () => _openDatePicker(isReturn: true),
                ),
              ],

              const SizedBox(height: 8),

              // Passengers + stepper
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Passengers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _Stepper(
                value: _pax,
                onChanged: (v) => setState(() => _pax = v),
              ),

              const SizedBox(height: 14),

              // Search (acción principal)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Sub-widgets de UI (píldoras, campos y stepper). Mantienen el archivo ordenado.
// -----------------------------------------------------------------------------

/// Botón “píldora” para One-way / Round trip.
class _TripPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TripPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Mock de TextField para “From/To” (sin buscador aún).
class _TextFieldMock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _TextFieldMock({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Campo de fecha/hora con estilo de “falso TextField” y onTap externo.
class _DateField extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.valueText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(valueText, style: const TextStyle(color: Colors.black87)),
          ),
        ),
      ],
    );
  }
}

/// Stepper simple para número de pasajeros.
class _Stepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    void dec() => onChanged(value > 1 ? value - 1 : 1);
    void inc() => onChanged(value + 1);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(onPressed: dec, icon: const Icon(Icons.remove)),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(onPressed: inc, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
