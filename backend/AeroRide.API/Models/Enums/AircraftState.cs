namespace AeroRide.API.Models.Enums
{
    /// <summary>
    /// Represents the possible operational states of an aircraft within the AeroRide system.
    /// This state describes the aircraft's technical or administrative condition,
    /// not its temporal availability or scheduling.
    /// </summary>
    public enum AircraftState
    {
        /// <summary>
        /// Aircraft is operational and ready to be assigned to flights.
        /// </summary>
        Disponible = 1,

        /// <summary>
        /// Aircraft is currently under maintenance or technical inspection.
        /// </summary>
        EnMantenimiento = 2,

        /// <summary>
        /// Aircraft is out of service, either temporarily or permanently.
        /// </summary>
        FueraDeServicio = 3
    }
}
