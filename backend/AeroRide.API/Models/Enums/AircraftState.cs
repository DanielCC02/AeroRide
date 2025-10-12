namespace AeroRide.API.Models.Enums
{
    /// <summary>
    /// Representa los estados operativos posibles de una aeronave dentro del sistema AeroRide.
    /// </summary>
    public enum AircraftState
    {
        /// <summary>Aeronave disponible para asignación o vuelo.</summary>
        Disponible = 1,

        /// <summary>Aeronave actualmente en vuelo.</summary>
        EnVuelo = 2,

        /// <summary>Aeronave en mantenimiento o revisión técnica.</summary>
        EnMantenimiento = 3,

        /// <summary>Aeronave fuera de servicio temporal o permanentemente.</summary>
        FueraDeServicio = 4
    }
}
