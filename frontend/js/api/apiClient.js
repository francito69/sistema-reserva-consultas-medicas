// =============================================
// API CLIENT
// Universidad Nacional de Ingeniería (UNI)
// Archivo: api/apiClient.js
// =============================================

const ApiClient = {
    
    /**
     * Realizar petición HTTP genérica
     */
    async request(url, options = {}) {
        const defaultOptions = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        };
        
        // Agregar token de autenticación si existe
        const token = Utils.getToken();
        if (token) {
            defaultOptions.headers['Authorization'] = `Bearer ${token}`;
        }
        
        // Combinar opciones
        const finalOptions = {
            ...defaultOptions,
            ...options,
            headers: {
                ...defaultOptions.headers,
                ...(options.headers || {})
            }
        };
        
        try {
            const response = await fetch(url, finalOptions);
            
            // Manejar errores HTTP
            if (!response.ok) {
                return await this.handleErrorResponse(response);
            }
            
            // Verificar si hay contenido en la respuesta
            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return {
                    success: true,
                    data: await response.json(),
                    status: response.status
                };
            }
            
            return {
                success: true,
                data: null,
                status: response.status
            };
            
        } catch (error) {
            console.error('Error en petición:', error);
            return {
                success: false,
                error: CONFIG.MESSAGES.ERROR.NETWORK,
                status: 0
            };
        }
    },
    
    /**
     * Manejar respuesta de error
     */
    async handleErrorResponse(response) {
        const status = response.status;
        let errorMessage = CONFIG.MESSAGES.ERROR.GENERIC;
        let errors = null;
        
        try {
            const errorData = await response.json();
            errorMessage = errorData.message || errorData.error || errorMessage;
            errors = errorData.errors || null;
        } catch (e) {
            // Si no se puede parsear el error, usar mensaje por defecto
        }
        
        // Manejar casos específicos
        switch (status) {
            case 400:
                errorMessage = errorMessage || 'Solicitud inválida';
                break;
            case 401:
                errorMessage = CONFIG.MESSAGES.ERROR.UNAUTHORIZED;
                Utils.logout(); // Cerrar sesión si no está autorizado
                break;
            case 403:
                errorMessage = 'No tiene permisos para realizar esta acción';
                break;
            case 404:
                errorMessage = CONFIG.MESSAGES.ERROR.NOT_FOUND;
                break;
            case 500:
                errorMessage = 'Error interno del servidor';
                break;
        }
        
        return {
            success: false,
            error: errorMessage,
            errors: errors,
            status: status
        };
    },
    
    /**
     * GET request
     */
    async get(endpoint, params = {}) {
        const url = Utils.buildUrl(endpoint, params);
        return await this.request(url);
    },
    
    /**
     * POST request
     */
    async post(endpoint, data = {}, params = {}) {
        const url = Utils.buildUrl(endpoint, params);
        return await this.request(url, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    },
    
    /**
     * PUT request
     */
    async put(endpoint, data = {}, params = {}) {
        const url = Utils.buildUrl(endpoint, params);
        return await this.request(url, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    },
    
    /**
     * DELETE request
     */
    async delete(endpoint, params = {}) {
        const url = Utils.buildUrl(endpoint, params);
        return await this.request(url, {
            method: 'DELETE'
        });
    }
};

// Exportar para uso global
if (typeof window !== 'undefined') {
    window.ApiClient = ApiClient;
}
