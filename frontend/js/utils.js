// =============================================
// UTILIDADES JAVASCRIPT
// Universidad Nacional de Ingeniería (UNI)
// Archivo: utils.js
// ============================================= 

const Utils = {
    
    // =============================================
    // AUTENTICACIÓN
    // =============================================
    
    /**
     * Guardar token de autenticación
     */
    saveToken(token) {
        localStorage.setItem(CONFIG.AUTH.TOKEN_KEY, token);
        localStorage.setItem(CONFIG.AUTH.TOKEN_KEY + '_timestamp', Date.now());
    },
    
    /**
     * Obtener token de autenticación
     */
    getToken() {
        const token = localStorage.getItem(CONFIG.AUTH.TOKEN_KEY);
        const timestamp = localStorage.getItem(CONFIG.AUTH.TOKEN_KEY + '_timestamp');
        
        // Verificar si el token ha expirado
        if (token && timestamp) {
            const now = Date.now();
            const elapsed = now - parseInt(timestamp);
            
            if (elapsed > CONFIG.AUTH.TOKEN_EXPIRY) {
                this.logout();
                return null;
            }
        }
        
        return token;
    },
    
    /**
     * Guardar datos del usuario
     */
    saveUser(userData) {
        localStorage.setItem(CONFIG.AUTH.USER_KEY, JSON.stringify(userData));
    },
    
    /**
     * Obtener datos del usuario
     */
    getUser() {
        const userData = localStorage.getItem(CONFIG.AUTH.USER_KEY);
        return userData ? JSON.parse(userData) : null;
    },
    
    /**
     * Verificar si el usuario está autenticado
     */
    isAuthenticated() {
        return this.getToken() !== null;
    },
    
    /**
     * Verificar rol del usuario
     */
    hasRole(role) {
        const user = this.getUser();
        return user && user.rol === role;
    },
    
    /**
     * Cerrar sesión
     */
    logout() {
        localStorage.removeItem(CONFIG.AUTH.TOKEN_KEY);
        localStorage.removeItem(CONFIG.AUTH.TOKEN_KEY + '_timestamp');
        localStorage.removeItem(CONFIG.AUTH.USER_KEY);
        window.location.href = '/pages/login.html';
    },
    
    /**
     * Redirigir según el rol del usuario
     */
    redirectByRole() {
        const user = this.getUser();
        if (!user) {
            window.location.href = '/pages/login.html';
            return;
        }
        
        switch(user.rol) {
            case CONFIG.ROLES.ADMIN:
                window.location.href = '/pages/admin/dashboard.html';
                break;
            case CONFIG.ROLES.MEDICO:
                window.location.href = '/pages/medico/dashboard.html';
                break;
            case CONFIG.ROLES.PACIENTE:
                window.location.href = '/pages/paciente/dashboard.html';
                break;
            default:
                window.location.href = '/index.html';
        }
    },
    
    // =============================================
    // VALIDACIONES
    // =============================================
    
    /**
     * Validar DNI peruano (8 dígitos)
     */
    validateDNI(dni) {
        const dniRegex = /^\d{8}$/;
        return dniRegex.test(dni);
    },
    
    /**
     * Validar teléfono peruano (9 dígitos)
     */
    validateTelefono(telefono) {
        const telefonoRegex = /^9\d{8}$/;
        return telefonoRegex.test(telefono);
    },
    
    /**
     * Validar email
     */
    validateEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },
    
    /**
     * Validar contraseña
     */
    validatePassword(password) {
        return password && 
               password.length >= CONFIG.VALIDATION.PASSWORD_MIN_LENGTH &&
               password.length <= CONFIG.VALIDATION.PASSWORD_MAX_LENGTH;
    },
    
    /**
     * Validar fecha (no puede ser en el pasado)
     */
    validateFechaFutura(fecha) {
        const fechaSeleccionada = new Date(fecha);
        const hoy = new Date();
        hoy.setHours(0, 0, 0, 0);
        return fechaSeleccionada >= hoy;
    },
    
    // =============================================
    // FORMATO DE DATOS
    // =============================================
    
    /**
     * Formatear fecha a formato local
     */
    formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('es-PE', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    },
    
    /**
     * Formatear fecha y hora
     */
    formatDateTime(dateTimeString) {
        if (!dateTimeString) return '-';
        const date = new Date(dateTimeString);
        return date.toLocaleString('es-PE', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    },
    
    /**
     * Formatear hora
     */
    formatTime(timeString) {
        if (!timeString) return '-';
        return timeString.substring(0, 5); // HH:mm
    },
    
    /**
     * Obtener nombre del día de la semana
     */
    getDiaSemana(diaSemanaNum) {
        return CONFIG.DIAS_SEMANA[diaSemanaNum] || '-';
    },
    
    /**
     * Capitalizar primera letra
     */
    capitalize(str) {
        if (!str) return '';
        return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    },
    
    /**
     * Formatear nombre completo
     */
    formatNombreCompleto(nombres, apellidoPaterno, apellidoMaterno) {
        return `${nombres} ${apellidoPaterno} ${apellidoMaterno}`.trim();
    },
    
    // =============================================
    // UI / UX
    // =============================================
    
    /**
     * Mostrar notificación toast
     */
    showToast(message, type = 'info', duration = 3000) {
        // Crear contenedor si no existe
        let container = document.getElementById('toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toast-container';
            container.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
            `;
            document.body.appendChild(container);
        }
        
        // Crear toast
        const toast = document.createElement('div');
        toast.className = `alert alert-${type}`;
        toast.style.cssText = `
            min-width: 300px;
            margin-bottom: 10px;
            animation: slideInRight 0.3s ease-out;
        `;
        toast.textContent = message;
        
        container.appendChild(toast);
        
        // Eliminar después de la duración
        setTimeout(() => {
            toast.style.animation = 'slideOutRight 0.3s ease-out';
            setTimeout(() => {
                container.removeChild(toast);
            }, 300);
        }, duration);
    },
    
    /**
     * Mostrar spinner de carga
     */
    showLoading(elementId = 'loading-spinner') {
        const spinner = document.getElementById(elementId);
        if (spinner) {
            spinner.classList.remove('d-none');
        }
    },
    
    /**
     * Ocultar spinner de carga
     */
    hideLoading(elementId = 'loading-spinner') {
        const spinner = document.getElementById(elementId);
        if (spinner) {
            spinner.classList.add('d-none');
        }
    },
    
    /**
     * Confirmar acción
     */
    confirm(message) {
        return window.confirm(message);
    },
    
    /**
     * Deshabilitar botón mientras se procesa
     */
    disableButton(buttonId) {
        const btn = document.getElementById(buttonId);
        if (btn) {
            btn.disabled = true;
            btn.dataset.originalText = btn.textContent;
            btn.textContent = 'Procesando...';
        }
    },
    
    /**
     * Habilitar botón después de procesar
     */
    enableButton(buttonId) {
        const btn = document.getElementById(buttonId);
        if (btn) {
            btn.disabled = false;
            btn.textContent = btn.dataset.originalText || btn.textContent;
        }
    },
    
    /**
     * Limpiar formulario
     */
    clearForm(formId) {
        const form = document.getElementById(formId);
        if (form) {
            form.reset();
            // Limpiar mensajes de error
            const errorMessages = form.querySelectorAll('.invalid-feedback');
            errorMessages.forEach(msg => msg.style.display = 'none');
            // Quitar clases de validación
            const inputs = form.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.classList.remove('is-invalid', 'is-valid');
            });
        }
    },
    
    /**
     * Marcar campo como inválido
     */
    markFieldInvalid(fieldId, message) {
        const field = document.getElementById(fieldId);
        if (field) {
            field.classList.add('is-invalid');
            field.classList.remove('is-valid');
            
            // Mostrar mensaje de error
            let feedback = field.nextElementSibling;
            if (!feedback || !feedback.classList.contains('invalid-feedback')) {
                feedback = document.createElement('div');
                feedback.className = 'invalid-feedback';
                field.parentNode.insertBefore(feedback, field.nextSibling);
            }
            feedback.textContent = message;
            feedback.style.display = 'block';
        }
    },
    
    /**
     * Marcar campo como válido
     */
    markFieldValid(fieldId) {
        const field = document.getElementById(fieldId);
        if (field) {
            field.classList.remove('is-invalid');
            field.classList.add('is-valid');
            
            // Ocultar mensaje de error
            const feedback = field.nextElementSibling;
            if (feedback && feedback.classList.contains('invalid-feedback')) {
                feedback.style.display = 'none';
            }
        }
    },
    
    // =============================================
    // HELPERS
    // =============================================
    
    /**
     * Construir URL con parámetros
     */
    buildUrl(endpoint, params = {}) {
        let url = CONFIG.API_BASE_URL + endpoint;
        
        // Reemplazar parámetros en la URL
        Object.keys(params).forEach(key => {
            url = url.replace(`:${key}`, params[key]);
        });
        
        return url;
    },
    
    /**
     * Obtener parámetros de la URL
     */
    getQueryParams() {
        const params = {};
        const queryString = window.location.search.substring(1);
        const queries = queryString.split('&');
        
        queries.forEach(query => {
            const [key, value] = query.split('=');
            if (key) {
                params[decodeURIComponent(key)] = decodeURIComponent(value || '');
            }
        });
        
        return params;
    },
    
    /**
     * Calcular edad a partir de fecha de nacimiento
     */
    calcularEdad(fechaNacimiento) {
        const hoy = new Date();
        const nacimiento = new Date(fechaNacimiento);
        let edad = hoy.getFullYear() - nacimiento.getFullYear();
        const mes = hoy.getMonth() - nacimiento.getMonth();
        
        if (mes < 0 || (mes === 0 && hoy.getDate() < nacimiento.getDate())) {
            edad--;
        }
        
        return edad;
    },
    
    /**
     * Generar color según el estado de la cita
     */
    getEstadoColor(estadoCodigo) {
        return CONFIG.COLORES_ESTADO[estadoCodigo] || '#6c757d';
    },
    
    /**
     * Debounce para búsquedas
     */
    debounce(func, wait = 300) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },
    
    /**
     * Parsear errores de validación del backend
     */
    parseValidationErrors(errors) {
        const errorMessages = {};
        
        if (Array.isArray(errors)) {
            errors.forEach(error => {
                errorMessages[error.field] = error.message;
            });
        } else if (typeof errors === 'object') {
            Object.keys(errors).forEach(field => {
                errorMessages[field] = errors[field];
            });
        }
        
        return errorMessages;
    }
};

// Animaciones CSS adicionales para toasts
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Exportar para uso global
if (typeof window !== 'undefined') {
    window.Utils = Utils;
}
