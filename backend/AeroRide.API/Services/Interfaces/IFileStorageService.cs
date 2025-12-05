namespace AeroRide.API.Services.Interfaces
{
    public interface IFileStorageService
    {
        Task<string> UploadAsync(IFormFile file, string containerName);
        Task<bool> DeleteAsync(string fileUrl, string containerName);
    }

}
