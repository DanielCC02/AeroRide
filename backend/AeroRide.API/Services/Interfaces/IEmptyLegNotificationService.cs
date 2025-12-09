using AeroRide.API.Models.Domain;

namespace AeroRide.API.Services.Interfaces
{
    public interface IEmptyLegNotificationService
    {
        Task NotifyUsersForEmptyLegsAsync(IEnumerable<Flight> emptyLegs);
    }

}
