using AutoMapper;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Models.DTOs.Authorization;

namespace AeroRide.API.Mappings
{
    /// <summary>
    /// Perfil de AutoMapper que define las reglas de conversión
    /// entre las entidades del dominio (<see cref="User"/>) y los distintos DTOs.
    /// 
    /// Esta configuración centraliza la lógica de transformación de datos
    /// para mantener los controladores y servicios limpios y consistentes.
    /// </summary>
    public class UserProfile : Profile
    {
        public UserProfile()
        {
            // ======================================================
            // 📤 ENTIDAD → DTOs DE RESPUESTA (para GETs)
            // ======================================================

            // 1️⃣ Listado general de usuarios
            CreateMap<User, UserListDto>()
                .ForMember(dest => dest.Role,
                    opt => opt.MapFrom(src => src.Role != null ? src.Role.Name : "Sin rol"))
                .ForMember(dest => dest.IsActive,
                    opt => opt.MapFrom(src => src.IsActive))
                .ForMember(dest => dest.CompanyName,
                    opt => opt.MapFrom(src => src.Company != null ? src.Company.Name : null));

            // 2️⃣ Detalle de usuario individual
            CreateMap<User, UserDetailDto>()
                .ForMember(dest => dest.Role,
                    opt => opt.MapFrom(src => src.Role != null ? src.Role.Name : "Sin rol"))
                .ForMember(dest => dest.TermsOfUse, opt => opt.MapFrom(src => src.TermsOfUse))
                .ForMember(dest => dest.PrivacyNotice, opt => opt.MapFrom(src => src.PrivacyNotice))
                .ForMember(dest => dest.RegistrationDate, opt => opt.MapFrom(src => src.RegistrationDate))
                .ForMember(dest => dest.CompanyName,
                    opt => opt.MapFrom(src => src.Company != null ? src.Company.Name : null));

            // 3️⃣ Perfil del usuario autenticado
            CreateMap<User, UserProfileDto>()
                .ForMember(dest => dest.Role,
                    opt => opt.MapFrom(src => src.Role != null ? src.Role.Name : "Sin rol"))
                .ForMember(dest => dest.CompanyName,
                    opt => opt.MapFrom(src => src.Company != null ? src.Company.Name : null));

            // 4️⃣ Respuesta estándar del usuario (registro o creación)
            CreateMap<User, UserResponseDto>()
                .ForMember(dest => dest.Role,
                    opt => opt.MapFrom(src => src.Role != null ? src.Role.Name : "User"))
                .ForMember(dest => dest.CompanyName,
                    opt => opt.MapFrom(src => src.Company != null ? src.Company.Name : null));

            // ======================================================
            // 📥 DTOs DE ENTRADA (para POST / PUT)
            // ======================================================

            // 5️⃣ Registro normal (Auth/Register)
            CreateMap<UserRegisterDto, User>()
                .ForMember(dest => dest.Password, opt => opt.MapFrom(src => src.Password))
                .ForMember(dest => dest.RoleId, opt => opt.MapFrom(_ => 4)) // Rol por defecto: User
                .ForMember(dest => dest.RegistrationDate, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.IsVerified, opt => opt.MapFrom(_ => false)) 
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.TermsOfUse, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.PrivacyNotice, opt => opt.MapFrom(_ => true));

            // 6️⃣ Creación manual por admin
            CreateMap<CreateUserDto, User>()
                .ForMember(dest => dest.Password, opt => opt.MapFrom(src => src.Password))
                .ForMember(dest => dest.RegistrationDate, opt => opt.MapFrom(_ => DateTime.UtcNow))
                .ForMember(dest => dest.IsVerified, opt => opt.MapFrom(_ => true)) // Creado por admin → verificado automáticamente
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.PrivacyNotice, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.TermsOfUse, opt => opt.MapFrom(_ => true))
                .ForMember(dest => dest.CompanyId, opt => opt.MapFrom(src => src.CompanyId));

            // ======================================================
            // ✏️ ACTUALIZACIONES
            // ======================================================

            // 7️⃣ Actualización del perfil por el propio usuario
            CreateMap<UserUpdateDto, User>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Email, opt => opt.Ignore())
                .ForMember(dest => dest.RoleId, opt => opt.Ignore())
                .ForMember(dest => dest.Password, opt => opt.Ignore())
                .ForMember(dest => dest.CompanyId, opt => opt.Ignore()); // no debe cambiar su compañía

            // 8️⃣ Actualización por administrador (puede modificar correo, rol o empresa)
            CreateMap<UserUpdateAdminDto, User>()
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.Email))
                .ForMember(dest => dest.RoleId, opt => opt.MapFrom(src => src.RoleId))
                .ForMember(dest => dest.CompanyId, opt => opt.MapFrom(src => src.CompanyId))
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));


        }
    }
}
