using Azure.Storage.Blobs;

namespace AeroRide.API.Helpers
{
    /// <summary>
    /// Servicio para manejar la carga y almacenamiento de imágenes en Azure Blob Storage.
    /// Se encarga de subir los archivos y devolver la URL pública resultante.
    /// </summary>
    public class BlobStorageService
    {
        private readonly BlobContainerClient _containerClient;

        /// <summary>
        /// Inicializa el servicio de conexión con el contenedor configurado.
        /// </summary>
        public BlobStorageService(IConfiguration configuration)
        {
            var connectionString = configuration["AzureStorage:ConnectionString"];
            var containerName = configuration["AzureStorage:ContainerName"];

            _containerClient = new BlobContainerClient(connectionString, containerName);
            _containerClient.CreateIfNotExists(); // Crea el contenedor si no existe
        }

        /// <summary>
        /// Sube una imagen a Azure Blob Storage y devuelve la URL pública.
        /// </summary>
        /// <param name="file">Archivo a subir.</param>
        /// <returns>URL pública de la imagen almacenada.</returns>
        public async Task<string> UploadFileAsync(IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("El archivo proporcionado está vacío o es nulo.");

            // Se genera un nombre único para evitar colisiones
            var fileName = $"{Guid.NewGuid()}_{file.FileName}";
            var blobClient = _containerClient.GetBlobClient(fileName);

            using (var stream = file.OpenReadStream())
            {
                await blobClient.UploadAsync(stream, overwrite: true);
            }

            return blobClient.Uri.ToString(); // Devuelve la URL pública
        }
    }
}
