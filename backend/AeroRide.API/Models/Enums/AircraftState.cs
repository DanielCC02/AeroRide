namespace AeroRide.API.Models.Enums
{
    /// <summary>
    /// Representa los estados operativos posibles de una aeronave dentro del sistema AeroRide.
    /// Este estado describe su condición técnica o administrativa,
    /// no su disponibilidad temporal.
    /// </summary>
    public enum AircraftState
    {
        /// <summary>Aeronave operativa y lista para asignación de vuelos.</summary>
        Disponible = 1,

        /// <summary>Aeronave en mantenimiento o revisión técnica.</summary>
        EnMantenimiento = 2,

        /// <summary>Aeronave fuera de servicio (baja temporal o permanente).</summary>
        FueraDeServicio = 3
    }
}
