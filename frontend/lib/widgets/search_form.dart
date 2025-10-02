import 'package:flutter/material.dart';
import 'datetime_picker_modal.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  // Variable para controlar si el viaje es solo ida o ida y vuelta
  bool _isRoundTrip = false;

  // Variables para guardar la fecha/hora seleccionada
  DateTime? _departureDateTime; // salida
  DateTime? _returnDateTime;    // regreso (solo si es Round Trip)

  /// Método para abrir el modal de selección de fecha y hora
  /// - Si [isReturn] es true, actualiza la fecha de regreso
  /// - Si [isReturn] es false, actualiza la fecha de salida
  Future<void> _selectDateTime({required bool isReturn}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // para que el modal ocupe la pantalla completa si hace falta
      builder: (context) {
        return DateTimePickerModal(
          onSelected: (dateTime) {
            setState(() {
              if (isReturn) {
                _returnDateTime = dateTime;
              } else {
                _departureDateTime = dateTime;
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // -------------------------------
        // Botones One Way / Round Trip
        // -------------------------------
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_isRoundTrip ? Colors.red : Colors.grey[300],
                  foregroundColor: !_isRoundTrip ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isRoundTrip = false; // se selecciona solo ida
                  });
                },
                child: const Text("One Way"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRoundTrip ? Colors.red : Colors.grey[300],
                  foregroundColor: _isRoundTrip ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isRoundTrip = true; // se selecciona ida y vuelta
                  });
                },
                child: const Text("Round Trip"),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // -------------------------------
        // Campos de origen y destino
        // -------------------------------
        TextField(
          decoration: const InputDecoration(
            labelText: "From", // aeropuerto de salida
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          decoration: const InputDecoration(
            labelText: "To", // aeropuerto de destino
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        // -------------------------------
        // Campo de fecha/hora de salida
        // -------------------------------
        GestureDetector(
          // al tocar abre el modal
          onTap: () => _selectDateTime(isReturn: false),
          child: AbsorbPointer(
            // AbsorbPointer evita que se escriba manualmente en el TextField
            child: TextField(
              decoration: InputDecoration(
                labelText: _isRoundTrip
                    ? "Departure Date & Time"
                    : "Date & Time",
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              // Se muestra el valor seleccionado en el TextField
              controller: TextEditingController(
                text: _departureDateTime != null
                    ? "${_departureDateTime!.day}/${_departureDateTime!.month}/${_departureDateTime!.year} "
                      "${_departureDateTime!.hour.toString().padLeft(2, '0')}:${_departureDateTime!.minute.toString().padLeft(2, '0')}"
                    : "",
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // -------------------------------
        // Campo de fecha/hora de regreso (solo visible si es Round Trip)
        // -------------------------------
        if (_isRoundTrip)
          Column(
            children: [
              GestureDetector(
                onTap: () => _selectDateTime(isReturn: true),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Return Date & Time",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _returnDateTime != null
                          ? "${_returnDateTime!.day}/${_returnDateTime!.month}/${_returnDateTime!.year} "
                            "${_returnDateTime!.hour.toString().padLeft(2, '0')}:${_returnDateTime!.minute.toString().padLeft(2, '0')}"
                          : "",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),

        // -------------------------------
        // Campo de pasajeros
        // -------------------------------
        TextField(
          decoration: const InputDecoration(
            labelText: "Passengers", // cantidad de pasajeros
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.people),
          ),
          keyboardType: TextInputType.number, // solo números
        ),
        const SizedBox(height: 20),

        // -------------------------------
        // Botón de búsqueda
        // -------------------------------
        ElevatedButton(
          onPressed: () {
            // Por ahora solo imprime los valores seleccionados
            debugPrint("Departure: $_departureDateTime");
            debugPrint("Return: $_returnDateTime");

            // FUTURO: aquí se puede llamar al provider para
            // hacer la búsqueda de vuelos con estos filtros
          },
          child: const Text("Search"),
        ),
      ],
    );
  }
}