using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace AeroRide.API.Helpers
{
    /// <summary>
    /// Servicio para manejar la carga de PDFs de bitácoras en un contenedor dedicado.
    /// </summary>
    public class BlobStorageLogsService
    {
        private readonly BlobContainerClient _container;

        public BlobStorageLogsService(IConfiguration config)
        {
            var connection = config["AzureStorage:ConnectionString"];
            var containerName = config["AzureStorage:LogsContainer"];

            var service = new BlobServiceClient(connection);

            _container = service.GetBlobContainerClient(containerName);

            // Crear contenedor con acceso público SOLO a blobs (necesario para descargas)
            _container.CreateIfNotExists(PublicAccessType.Blob);
        }

        /// <summary>
        /// Sube un PDF de bitácora al contenedor y devuelve la URL pública.
        /// </summary>
        public async Task<string> UploadPdfAsync(IFormFile pdf)
        {
            if (pdf == null || pdf.Length == 0)
                throw new Exception("Invalid PDF file.");

            string fileName = $"{Guid.NewGuid()}_{pdf.FileName}";

            var blob = _container.GetBlobClient(fileName);

            using var stream = pdf.OpenReadStream();
            await blob.UploadAsync(stream, overwrite: true);

            return blob.Uri.ToString();
        }
    }
}
