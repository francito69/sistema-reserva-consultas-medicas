// Sistema de Reserva de Consultas Médicas - UNI
// JavaScript Principal

console.log('🏥 Sistema de Reserva de Consultas Médicas');
console.log('📍 Universidad Nacional de Ingeniería (UNI)');
console.log('🚀 Frontend cargado correctamente');

// Configuración de la API
const API_BASE_URL = 'http://localhost:8080/api';

// Utilidades
const utils = {
    // Formatear fecha
    formatDate(date) {
        return new Date(date).toLocaleDateString('es-PE');
    },

    // Mostrar mensaje
    showMessage(message, type = 'info') {
        alert(message);
    },

    // Validar formulario
    validateForm(formData) {
        for (let [key, value] of formData.entries()) {
            if (!value) {
                this.showMessage(`El campo ${key} es obligatorio`, 'error');
                return false;
            }
        }
        return true;
    }
};

// Hacer disponible globalmente
window.API_BASE_URL = API_BASE_URL;
window.utils = utils;

// Animaciones al scroll
document.addEventListener('DOMContentLoaded', () => {
    const elements = document.querySelectorAll('.slide-up');

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.animation = 'slideUp 0.5s ease-out forwards';
            }
        });
    });

    elements.forEach(el => observer.observe(el));
});
