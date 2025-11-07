// =====================================================
// REGISTRO DE PACIENTE - VALIDACIONES Y ENVÍO
// Sistema de Reserva de Consultas Médicas - UNI
// =====================================================

document.addEventListener('DOMContentLoaded', () => {
    // Referencias a elementos del formulario
    const form = document.getElementById('registroForm');
    const alertMessage = document.getElementById('alertMessage');
    const registerButton = document.getElementById('registerButton');
    const registerButtonText = document.getElementById('registerButtonText');
    const registerSpinner = document.getElementById('registerSpinner');
    const togglePasswordButton = document.getElementById('togglePassword');

    // Referencias a inputs
    const inputs = {
        dni: document.getElementById('dni'),
        fechaNacimiento: document.getElementById('fechaNacimiento'),
        nombres: document.getElementById('nombres'),
        apellidoPaterno: document.getElementById('apellidoPaterno'),
        apellidoMaterno: document.getElementById('apellidoMaterno'),
        genero: document.getElementById('genero'),
        email: document.getElementById('email'),
        telefono: document.getElementById('telefono'),
        direccion: document.getElementById('direccion'),
        nombreUsuario: document.getElementById('nombreUsuario'),
        password: document.getElementById('password'),
        confirmPassword: document.getElementById('confirmPassword'),
        terminos: document.getElementById('terminos')
    };

    // Referencias a elementos de strength de contraseña
    const passwordStrength = document.getElementById('passwordStrength');
    const strengthBars = [
        document.getElementById('strengthBar1'),
        document.getElementById('strengthBar2'),
        document.getElementById('strengthBar3'),
        document.getElementById('strengthBar4')
    ];
    const strengthText = document.getElementById('strengthText');

    // =====================================================
    // UTILIDADES
    // =====================================================

    function showAlert(message, type = 'error') {
        alertMessage.className = `alert alert-${type}`;
        alertMessage.innerHTML = `
            <div class="alert-title">${type === 'success' ? '✓ Éxito' : type === 'warning' ? '⚠ Advertencia' : '✗ Error'}</div>
            ${message}
        `;
        alertMessage.style.display = 'block';
        alertMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    function hideAlert() {
        alertMessage.style.display = 'none';
    }

    function setFieldError(fieldName, message) {
        const field = inputs[fieldName];
        const errorElement = document.getElementById(`${fieldName}Error`);

        if (field && errorElement) {
            field.classList.add('is-invalid');
            field.classList.remove('is-valid');
            errorElement.textContent = message;
        }
    }

    function setFieldValid(fieldName) {
        const field = inputs[fieldName];
        const errorElement = document.getElementById(`${fieldName}Error`);

        if (field && errorElement) {
            field.classList.remove('is-invalid');
            field.classList.add('is-valid');
            errorElement.textContent = '';
        }
    }

    function clearFieldValidation(fieldName) {
        const field = inputs[fieldName];
        const errorElement = document.getElementById(`${fieldName}Error`);

        if (field && errorElement) {
            field.classList.remove('is-invalid', 'is-valid');
            errorElement.textContent = '';
        }
    }

    // =====================================================
    // VALIDACIONES
    // =====================================================

    const validators = {
        dni: (value) => {
            if (!value) return 'El DNI es obligatorio';
            if (!/^\d{8}$/.test(value)) return 'El DNI debe tener 8 dígitos';
            return null;
        },

        fechaNacimiento: (value) => {
            if (!value) return 'La fecha de nacimiento es obligatoria';

            const birthDate = new Date(value);
            const today = new Date();
            let age = today.getFullYear() - birthDate.getFullYear();
            const monthDiff = today.getMonth() - birthDate.getMonth();

            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }

            if (age < 18) return 'Debe ser mayor de 18 años';
            if (age > 120) return 'Fecha de nacimiento inválida';

            return null;
        },

        nombres: (value) => {
            if (!value) return 'Los nombres son obligatorios';
            if (value.trim().length < 2) return 'Los nombres deben tener al menos 2 caracteres';
            if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(value)) return 'Los nombres solo pueden contener letras';
            return null;
        },

        apellidoPaterno: (value) => {
            if (!value) return 'El apellido paterno es obligatorio';
            if (value.trim().length < 2) return 'El apellido debe tener al menos 2 caracteres';
            if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(value)) return 'El apellido solo puede contener letras';
            return null;
        },

        apellidoMaterno: (value) => {
            if (!value) return 'El apellido materno es obligatorio';
            if (value.trim().length < 2) return 'El apellido debe tener al menos 2 caracteres';
            if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(value)) return 'El apellido solo puede contener letras';
            return null;
        },

        genero: (value) => {
            if (!value) return 'Debe seleccionar un género';
            if (!['M', 'F'].includes(value)) return 'Género inválido';
            return null;
        },

        email: (value) => {
            if (!value) return 'El email es obligatorio';
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(value)) return 'Email inválido';
            return null;
        },

        telefono: (value) => {
            if (!value) return 'El teléfono es obligatorio';
            if (!/^9\d{8}$/.test(value)) return 'El teléfono debe tener 9 dígitos y empezar con 9';
            return null;
        },

        direccion: (value) => {
            if (!value) return 'La dirección es obligatoria';
            if (value.trim().length < 10) return 'La dirección debe tener al menos 10 caracteres';
            return null;
        },

        nombreUsuario: (value) => {
            if (!value) return 'El nombre de usuario es obligatorio';
            if (value.length < 4) return 'El usuario debe tener al menos 4 caracteres';
            if (!/^[a-zA-Z0-9._]+$/.test(value)) return 'Solo letras, números, puntos y guiones bajos';
            return null;
        },

        password: (value) => {
            if (!value) return 'La contraseña es obligatoria';
            if (value.length < 8) return 'La contraseña debe tener al menos 8 caracteres';
            if (!/(?=.*[a-z])/.test(value)) return 'Debe contener al menos una minúscula';
            if (!/(?=.*[A-Z])/.test(value)) return 'Debe contener al menos una mayúscula';
            if (!/(?=.*\d)/.test(value)) return 'Debe contener al menos un número';
            return null;
        },

        confirmPassword: (value) => {
            if (!value) return 'Debe confirmar la contraseña';
            if (value !== inputs.password.value) return 'Las contraseñas no coinciden';
            return null;
        },

        terminos: (checked) => {
            if (!checked) return 'Debe aceptar los términos y condiciones';
            return null;
        }
    };

    function validateField(fieldName) {
        const field = inputs[fieldName];
        if (!field) return false;

        const value = field.type === 'checkbox' ? field.checked : field.value.trim();
        const error = validators[fieldName](value);

        if (error) {
            setFieldError(fieldName, error);
            return false;
        } else {
            setFieldValid(fieldName);
            return true;
        }
    }

    // =====================================================
    // PASSWORD STRENGTH INDICATOR
    // =====================================================

    function calculatePasswordStrength(password) {
        let strength = 0;

        if (password.length >= 8) strength++;
        if (password.length >= 12) strength++;
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
        if (/\d/.test(password)) strength++;
        if (/[^a-zA-Z0-9]/.test(password)) strength++;

        return Math.min(strength, 4);
    }

    function updatePasswordStrength(password) {
        if (!password) {
            passwordStrength.style.display = 'none';
            return;
        }

        passwordStrength.style.display = 'block';

        const strength = calculatePasswordStrength(password);
        const strengthLevels = ['', 'Débil', 'Regular', 'Buena', 'Fuerte'];
        const strengthClasses = ['', 'weak', 'fair', 'good', 'strong'];
        const strengthColors = ['', 'var(--error-600)', 'var(--warning-600)', 'var(--success-500)', 'var(--success-600)'];

        strengthBars.forEach((bar, index) => {
            bar.className = 'password-strength-bar';
            if (index < strength) {
                bar.classList.add(`active-${strengthClasses[strength]}`);
            }
        });

        strengthText.textContent = `Fortaleza: ${strengthLevels[strength]}`;
        strengthText.style.color = strengthColors[strength];
    }

    // =====================================================
    // EVENT LISTENERS
    // =====================================================

    // Toggle password visibility
    togglePasswordButton.addEventListener('click', () => {
        const type = inputs.password.getAttribute('type') === 'password' ? 'text' : 'password';
        inputs.password.setAttribute('type', type);
        togglePasswordButton.textContent = type === 'password' ? '👁️' : '🙈';
    });

    // Validación solo números para DNI
    inputs.dni.addEventListener('input', (e) => {
        e.target.value = e.target.value.replace(/\D/g, '').substring(0, 8);
    });

    // Validación solo números para teléfono
    inputs.telefono.addEventListener('input', (e) => {
        e.target.value = e.target.value.replace(/\D/g, '').substring(0, 9);
    });

    // Password strength en tiempo real
    inputs.password.addEventListener('input', (e) => {
        updatePasswordStrength(e.target.value);
    });

    // Validación al perder el foco
    Object.keys(inputs).forEach(fieldName => {
        const field = inputs[fieldName];
        if (field) {
            field.addEventListener('blur', () => validateField(fieldName));
        }
    });

    // Validación con debounce mientras escribe
    let validationTimeouts = {};

    ['nombres', 'apellidoPaterno', 'apellidoMaterno', 'email', 'direccion', 'nombreUsuario'].forEach(fieldName => {
        inputs[fieldName].addEventListener('input', () => {
            clearTimeout(validationTimeouts[fieldName]);
            validationTimeouts[fieldName] = setTimeout(() => {
                validateField(fieldName);
            }, 500);
        });
    });

    // Validar confirmación de contraseña en tiempo real
    inputs.confirmPassword.addEventListener('input', () => {
        clearTimeout(validationTimeouts.confirmPassword);
        validationTimeouts.confirmPassword = setTimeout(() => {
            validateField('confirmPassword');
        }, 500);
    });

    // =====================================================
    // MANEJO DEL FORMULARIO
    // =====================================================

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideAlert();

        // Validar todos los campos
        let isValid = true;
        Object.keys(inputs).forEach(fieldName => {
            if (!validateField(fieldName)) {
                isValid = false;
            }
        });

        if (!isValid) {
            showAlert('Por favor, corrija los errores en el formulario');
            return;
        }

        // Deshabilitar botón y mostrar spinner
        registerButton.disabled = true;
        registerButtonText.textContent = 'Registrando...';
        registerSpinner.style.display = 'inline-block';

        // Preparar datos
        const formData = {
            dni: inputs.dni.value.trim(),
            nombres: inputs.nombres.value.trim(),
            apellidoPaterno: inputs.apellidoPaterno.value.trim(),
            apellidoMaterno: inputs.apellidoMaterno.value.trim(),
            fechaNacimiento: inputs.fechaNacimiento.value,
            sexo: inputs.genero.value,
            direccion: inputs.direccion.value.trim(),
            email: inputs.email.value.trim().toLowerCase(),
            telefono: inputs.telefono.value.trim(),
            nombreUsuario: inputs.nombreUsuario.value.trim(),
            contrasena: inputs.password.value
        };

        try {
            const response = await fetch(`${API_BASE_URL}/auth/register`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });

            const data = await response.json();

            if (response.ok) {
                showAlert('¡Registro exitoso! Iniciando sesión automáticamente...', 'success');

                // Guardar token y datos del usuario automáticamente
                localStorage.setItem('token', data.token);
                localStorage.setItem('user', JSON.stringify({
                    username: data.username,
                    rol: data.rol,
                    idReferencia: data.idReferencia
                }));

                // Limpiar formulario
                form.reset();
                Object.keys(inputs).forEach(fieldName => {
                    clearFieldValidation(fieldName);
                });

                // Redirigir al dashboard del paciente después de 2 segundos
                setTimeout(() => {
                    window.location.href = '/pages/paciente/dashboard.html';
                }, 2000);
            } else {
                // Manejar errores del servidor
                if (data.errors) {
                    // Errores de validación por campo
                    let errorMessages = [];
                    for (const [field, message] of Object.entries(data.errors)) {
                        setFieldError(field, message);
                        errorMessages.push(message);
                    }
                    showAlert(errorMessages.join('<br>'));
                } else {
                    showAlert(data.message || 'Error al registrar el paciente');
                }

                // Habilitar botón nuevamente
                registerButton.disabled = false;
                registerButtonText.textContent = 'Registrarse';
                registerSpinner.style.display = 'none';
            }
        } catch (error) {
            console.error('Error:', error);
            showAlert('Error al conectar con el servidor. Por favor, intente nuevamente.');

            // Habilitar botón nuevamente
            registerButton.disabled = false;
            registerButtonText.textContent = 'Registrarse';
            registerSpinner.style.display = 'none';
        }
    });

    // =====================================================
    // INICIALIZACIÓN
    // =====================================================

    // Establecer fecha máxima (18 años atrás)
    const today = new Date();
    const maxDate = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
    inputs.fechaNacimiento.max = maxDate.toISOString().split('T')[0];

    // Establecer fecha mínima (120 años atrás)
    const minDate = new Date(today.getFullYear() - 120, today.getMonth(), today.getDate());
    inputs.fechaNacimiento.min = minDate.toISOString().split('T')[0];

    console.log('✅ Sistema de registro de pacientes inicializado correctamente');
});
