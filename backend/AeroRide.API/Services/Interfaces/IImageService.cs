using Microsoft.AspNetCore.Http;

namespace AeroRide.API.Interfaces
{
    /// <summary>
    /// Define las operaciones relacionadas con la gestión de imágenes en la nube.
    /// </summary>
    public interface IImageService
    {
        /// <summary>
        /// Sube una imagen al almacenamiento de Azure Blob Storage.
        /// </summary>
        /// <param name="file">Archivo de imagen a subir.</param>
        /// <param name="containerName">Nombre del contenedor donde se almacenará la imagen.</param>
        /// <returns>URL pública de la imagen subida.</returns>
        Task<string> UploadImageAsync(IFormFile file, string containerName);

        /// <summary>
        /// Elimina una imagen existente en Azure Blob Storage.
        /// </summary>
        /// <param name="fileUrl">URL pública de la imagen a eliminar.</param>
        /// <param name="containerName">Nombre del contenedor donde se encuentra la imagen.</param>
        /// <returns><c>true</c> si se eliminó correctamente; de lo contrario, <c>false</c>.</returns>
        Task<bool> DeleteImageAsync(string fileUrl, string containerName);
    }
}
