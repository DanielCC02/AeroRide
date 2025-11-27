using AeroRide.API.Interfaces;
using AeroRide.API.Services.Interfaces;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.AspNetCore.Http;

namespace AeroRide.API.Services
{
    /// <summary>
    /// Servicio responsable de la gestión de archivos PDF u otros documentos
    /// en Azure Blob Storage.
    /// </summary>
    public class AzureFileStorageService : IFileStorageService
    {
        private readonly IConfiguration _configuration;

        public AzureFileStorageService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        /// <inheritdoc />
        public async Task<string> UploadAsync(IFormFile file, string containerName)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("Debe seleccionar un archivo válido.");

            var connectionString = _configuration["AzureStorage:ConnectionString"];
            var blobServiceClient = new BlobServiceClient(connectionString);
            var containerClient = blobServiceClient.GetBlobContainerClient(containerName);

            // El contenedor queda accesible públicamente
            await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);

            // Se mantiene la extensión original (PDF recomendado)
            var extension = Path.GetExtension(file.FileName).ToLower();
            var blobName = $"{Guid.NewGuid()}{extension}";

            var blobClient = containerClient.GetBlobClient(blobName);

            using (var stream = file.OpenReadStream())
            {
                await blobClient.UploadAsync(stream, overwrite: true);
            }

            return blobClient.Uri.ToString();
        }

        /// <inheritdoc />
        public async Task<bool> DeleteAsync(string fileUrl, string containerName)
        {
            if (string.IsNullOrWhiteSpace(fileUrl))
                throw new ArgumentException("La URL del archivo no puede estar vacía.");

            var connectionString = _configuration["AzureStorage:ConnectionString"];
            var blobServiceClient = new BlobServiceClient(connectionString);
            var containerClient = blobServiceClient.GetBlobContainerClient(containerName);

            var blobName = Path.GetFileName(new Uri(fileUrl).LocalPath);
            var blobClient = containerClient.GetBlobClient(blobName);

            return await blobClient.DeleteIfExistsAsync();
        }
    }
}