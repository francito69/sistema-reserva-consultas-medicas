// Auth Guard - Protección de rutas y utilidades de autenticación

// Funciones de utilidad globales
window.getToken = function() {
    return localStorage.getItem('token');
};

window.getCurrentUser = function() {
    const userJson = localStorage.getItem('user');
    return userJson ? JSON.parse(userJson) : null;
};

window.logout = function() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    localStorage.removeItem('username');
    localStorage.removeItem('rol');
    localStorage.removeItem('idReferencia');
};

// Protección de rutas
(function() {
    const token = localStorage.getItem('token');
    const user = JSON.parse(localStorage.getItem('user') || 'null');

    // Si no hay token, redirigir al login
    if (!token || !user) {
        window.location.href = '/pages/auth/login.html';
        return;
    }

    // Verificar rol según la página actual
    const path = window.location.pathname;

    if (path.includes('/paciente/') && user.rol !== 'PACIENTE') {
        alert('No tiene permisos para acceder a esta página');
        window.location.href = '/';
        return;
    }

    if (path.includes('/medico/') && user.rol !== 'MEDICO') {
        alert('No tiene permisos para acceder a esta página');
        window.location.href = '/';
        return;
    }

    if (path.includes('/admin/') && user.rol !== 'ADMIN') {
        alert('No tiene permisos para acceder a esta página');
        window.location.href = '/';
        return;
    }

    console.log('✅ Usuario autenticado:', user);
})();
