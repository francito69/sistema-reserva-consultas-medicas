// =============================================
// CONFIGURACIÓN DEL SISTEMA
// Universidad Nacional de Ingeniería (UNI)
// Archivo: config.js
// =============================================

const CONFIG = {
    // URL del backend API
    API_BASE_URL: 'http://localhost:8080/api',
    
    // Endpoints de la API
    ENDPOINTS: {
        // Autenticación
        LOGIN: '/auth/login',
        LOGOUT: '/auth/logout',
        REGISTER: '/auth/register',
        
        // Pacientes
        PACIENTES: '/pacientes',
        PACIENTE_BY_ID: '/pacientes/:id',
        PACIENTE_CITAS: '/pacientes/:id/citas',
        
        // Médicos
        MEDICOS: '/medicos',
        MEDICO_BY_ID: '/medicos/:id',
        MEDICOS_BY_ESPECIALIDAD: '/medicos/especialidad/:id',
        MEDICO_HORARIOS: '/medicos/:id/horarios',
        
        // Especialidades
        ESPECIALIDADES: '/especialidades',
        ESPECIALIDAD_BY_ID: '/especialidades/:id',
        
        // Consultorios
        CONSULTORIOS: '/consultorios',
        CONSULTORIO_BY_ID: '/consultorios/:id',
        
        // Horarios
        HORARIOS: '/horarios',
        HORARIO_BY_ID: '/horarios/:id',
        HORARIOS_DISPONIBLES: '/horarios/disponibles',
        
        // Citas
        CITAS: '/citas',
        CITA_BY_ID: '/citas/:id',
        CITAS_BY_PACIENTE: '/citas/paciente/:id',
        CITAS_BY_MEDICO: '/citas/medico/:id',
        CITAS_BY_FECHA: '/citas/fecha/:fecha',
        CANCELAR_CITA: '/citas/:id/cancelar',
        CONFIRMAR_CITA: '/citas/:id/confirmar',
        ATENDER_CITA: '/citas/:id/atender',
        
        // Estados de cita
        ESTADOS_CITA: '/estados-cita',
        
        // Notificaciones
        NOTIFICACIONES: '/notificaciones',
        NOTIFICACIONES_PENDIENTES: '/notificaciones/pendientes',
        
        // Dashboard
        DASHBOARD_ADMIN: '/dashboard/admin',
        DASHBOARD_MEDICO: '/dashboard/medico/:id',
        DASHBOARD_PACIENTE: '/dashboard/paciente/:id',
        
        // Reportes
        REPORTES_CITAS: '/reportes/citas',
        REPORTES_MEDICOS: '/reportes/medicos',
        REPORTES_ESPECIALIDADES: '/reportes/especialidades'
    },
    
    // Configuración de autenticación
    AUTH: {
        TOKEN_KEY: 'auth_token',
        USER_KEY: 'user_data',
        TOKEN_EXPIRY: 24 * 60 * 60 * 1000 // 24 horas en milisegundos
    },
    
    // Roles de usuario
    ROLES: {
        ADMIN: 'ADMIN',
        MEDICO: 'MEDICO',
        PACIENTE: 'PACIENTE'
    },
    
    // Estados de cita
    ESTADOS_CITA: {
        PENDIENTE: 'PEND',
        CONFIRMADA: 'CONF',
        ATENDIDA: 'ATEN',
        CANCELADA: 'CANC',
        NO_ASISTIO: 'NOAS'
    },
    
    // Colores de estados (para UI)
    COLORES_ESTADO: {
        PEND: '#ffc107',
        CONF: '#28a745',
        ATEN: '#17a2b8',
        CANC: '#dc3545',
        NOAS: '#6c757d'
    },
    
    // Configuración de paginación
    PAGINATION: {
        DEFAULT_PAGE_SIZE: 10,
        PAGE_SIZE_OPTIONS: [5, 10, 20, 50]
    },
    
    // Configuración de validaciones
    VALIDATION: {
        DNI_LENGTH: 8,
        TELEFONO_LENGTH: 9,
        PASSWORD_MIN_LENGTH: 6,
        PASSWORD_MAX_LENGTH: 20
    },
    
    // Mensajes del sistema
    MESSAGES: {
        SUCCESS: {
            REGISTRO: '✅ Registro exitoso',
            ACTUALIZACION: '✅ Actualización exitosa',
            ELIMINACION: '✅ Eliminación exitosa',
            RESERVA_CITA: '✅ Cita reservada exitosamente',
            CANCELACION_CITA: '✅ Cita cancelada exitosamente'
        },
        ERROR: {
            GENERIC: '❌ Ocurrió un error. Por favor, intente nuevamente.',
            NETWORK: '❌ Error de conexión. Verifique su conexión a internet.',
            UNAUTHORIZED: '❌ No autorizado. Por favor, inicie sesión.',
            VALIDATION: '❌ Por favor, corrija los errores en el formulario.',
            NOT_FOUND: '❌ Recurso no encontrado.'
        },
        WARNING: {
            CAMPOS_VACIOS: '⚠️ Por favor, complete todos los campos obligatorios.',
            CONFIRM_DELETE: '⚠️ ¿Está seguro de eliminar este registro?',
            CONFIRM_CANCEL: '⚠️ ¿Está seguro de cancelar esta cita?'
        }
    },
    
    // Configuración de fechas
    DATE_FORMAT: 'YYYY-MM-DD',
    DATETIME_FORMAT: 'YYYY-MM-DD HH:mm:ss',
    TIME_FORMAT: 'HH:mm',
    
    // Días de la semana
    DIAS_SEMANA: {
        1: 'Lunes',
        2: 'Martes',
        3: 'Miércoles',
        4: 'Jueves',
        5: 'Viernes',
        6: 'Sábado',
        7: 'Domingo'
    }
};

// Exportar configuración (si usas módulos ES6)
// export default CONFIG;

// Para uso en navegador (sin módulos)
if (typeof window !== 'undefined') {
    window.CONFIG = CONFIG;
}
