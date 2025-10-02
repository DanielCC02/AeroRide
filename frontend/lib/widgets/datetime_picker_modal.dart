import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// DateTimePickerModal
/// -------------------------------------------
/// Modal personalizado para seleccionar
/// fecha y hora en un solo flujo.
///
/// - Muestra un calendario usando `table_calendar`.
/// - Permite elegir una hora con `showTimePicker`.
/// - Devuelve el objeto `DateTime` completo
///   mediante el callback [onSelected].
class DateTimePickerModal extends StatefulWidget {
  final Function(DateTime dateTime)
  onSelected; // callback al seleccionar fecha y hora

  const DateTimePickerModal({super.key, required this.onSelected});

  @override
  State<DateTimePickerModal> createState() => _DateTimePickerModalState();
}

class _DateTimePickerModalState extends State<DateTimePickerModal> {
  // Día actualmente enfocado en el calendario
  DateTime _focusedDay = DateTime.now();

  // Día seleccionado por el usuario
  DateTime? _selectedDay;

  // Hora seleccionada por el usuario
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // el modal se ajusta a su contenido
        children: [
          // --------------------------------
          // Encabezado con logo y destinos
          // (por ahora dummy, se reemplazará dinámicamente)
          // --------------------------------
          Column(
            children: const [
              Text(
                "AERORIDE", // Nombre de la app
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              // Destinos fijos por ahora (dummy)
              Text(
                "MRPV (SYQ) → Nosara",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
            ],
          ),

          // --------------------------------
          // Calendario interactivo
          // --------------------------------
          TableCalendar(
            // primer día permitido: hoy
            firstDay: DateTime.now(),

            // último día permitido: hoy + 1 año
            lastDay: DateTime(
              DateTime.now().year + 1,
              DateTime.now().month,
              DateTime.now().day,
            ),

            // día enfocado por defecto (hoy)
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 12),

          // --------------------------------
          // Selector de hora
          // --------------------------------
          ListTile(
            title: const Text("Time"),
            trailing: Text(
              _selectedTime != null
                  ? _selectedTime!.format(context) // hora elegida
                  : "Select time", // placeholder
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              // abre el selector nativo de hora
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() => _selectedTime = picked);
              }
            },
          ),

          const SizedBox(height: 12),

          // --------------------------------
          // Botón Done
          // - Solo confirma si se eligió
          //   fecha y hora.
          // - Construye un objeto DateTime
          //   combinando ambos valores.
          // --------------------------------
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (_selectedDay != null && _selectedTime != null) {
                // Combina la fecha del calendario con la hora seleccionada
                final dateTime = DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                  _selectedTime!.hour,
                  _selectedTime!.minute,
                );

                // Retorna el valor al widget padre
                widget.onSelected(dateTime);

                // Cierra el modal
                Navigator.pop(context);
              }
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}