// Login Script
document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');
    const messageContainer = document.getElementById('messageContainer');

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;

        try {
            showMessage('Iniciando sesión...', 'info');

            const response = await fetch(`${API_BASE_URL}/auth/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    username: username,
                    password: password
                })
            });

            if (response.ok) {
                const data = await response.json();

                // Guardar token y datos del usuario
                localStorage.setItem('token', data.token);
                localStorage.setItem('user', JSON.stringify({
                    username: data.username,
                    rol: data.rol,
                    idReferencia: data.idReferencia
                }));

                showMessage('Inicio de sesión exitoso. Redirigiendo...', 'success');

                // Redirigir según el rol
                setTimeout(() => {
                    switch (data.rol) {
                        case 'PACIENTE':
                            window.location.href = '/pages/paciente/dashboard.html';
                            break;
                        case 'MEDICO':
                            window.location.href = '/pages/medico/dashboard.html';
                            break;
                        case 'ADMIN':
                            window.location.href = '/pages/admin/dashboard.html';
                            break;
                        default:
                            window.location.href = '/';
                    }
                }, 1000);
            } else {
                const error = await response.json();
                showMessage(error.message || 'Usuario o contraseña incorrectos', 'error');
            }
        } catch (error) {
            console.error('Error:', error);
            showMessage('Error al conectar con el servidor', 'error');
        }
    });

    function showMessage(message, type) {
        messageContainer.textContent = message;
        messageContainer.className = `message-container message-${type}`;
        messageContainer.style.display = 'block';
    }
});
