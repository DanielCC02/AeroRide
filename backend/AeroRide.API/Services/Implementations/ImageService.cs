using AeroRide.API.Interfaces;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.AspNetCore.Http;

namespace AeroRide.API.Services
{
    /// <summary>
    /// Servicio responsable de la gestión de imágenes en Azure Blob Storage.
    /// Permite subir y eliminar archivos de manera genérica.
    /// </summary>
    public class ImageService : IImageService
    {
        private readonly IConfiguration _configuration;

        /// <summary>
        /// Inicializa el servicio con la configuración de Azure Storage.
        /// </summary>
        /// <param name="configuration">Configuración de la aplicación.</param>
        public ImageService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        /// <inheritdoc />
        public async Task<string> UploadImageAsync(IFormFile file, string containerName)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("Debe seleccionar una imagen válida.");

            var connectionString = _configuration["AzureStorage:ConnectionString"];
            var blobServiceClient = new BlobServiceClient(connectionString);
            var containerClient = blobServiceClient.GetBlobContainerClient(containerName);

            await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);

            // 🔹 Validaciones básicas (opcional)
            var extension = Path.GetExtension(file.FileName).ToLower();
            var allowed = new[] { ".jpg", ".jpeg", ".png", ".webp" };
            if (!allowed.Contains(extension))
                throw new InvalidOperationException("Formato de archivo no permitido. Solo se aceptan JPG, PNG o WEBP.");

            // 🔹 Subida del archivo
            var blobName = $"{Guid.NewGuid()}{extension}";
            var blobClient = containerClient.GetBlobClient(blobName);

            using (var stream = file.OpenReadStream())
            {
                await blobClient.UploadAsync(stream, overwrite: true);
            }

            return blobClient.Uri.ToString();
        }

        /// <inheritdoc />
        public async Task<bool> DeleteImageAsync(string fileUrl, string containerName)
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
