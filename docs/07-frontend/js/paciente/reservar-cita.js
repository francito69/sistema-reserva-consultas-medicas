// Reservar Cita - Multi-step Form
let selectedEspecialidad = null;
let selectedMedico = null;
let selectedFecha = null;
let selectedHora = null;

document.addEventListener('DOMContentLoaded', async () => {
    await cargarEspecialidades();
    configurarPasos();
});

async function cargarEspecialidades() {
    try {
        const response = await fetch(`${API_BASE_URL}/especialidades`);
        if (response.ok) {
            const especialidades = await response.json();
            const select = document.getElementById('especialidad');
            select.innerHTML = '<option value="">Seleccione una especialidad...</option>' +
                especialidades.map(e => `
                    <option value="${e.idEspecialidad}">${e.nombre}</option>
                `).join('');

            select.addEventListener('change', async (e) => {
                selectedEspecialidad = e.target.value;
                if (selectedEspecialidad) {
                    await cargarMedicos(selectedEspecialidad);
                }
            });
        }
    } catch (error) {
        console.error('Error al cargar especialidades:', error);
    }
}

async function cargarMedicos(idEspecialidad) {
    const select = document.getElementById('medico');
    const info = document.getElementById('medicoInfo');

    try {
        const response = await fetch(`${API_BASE_URL}/medicos/especialidad/${idEspecialidad}`);
        if (response.ok) {
            const medicos = await response.json();

            if (medicos.length === 0) {
                select.innerHTML = '<option value="">No hay médicos disponibles para esta especialidad</option>';
                select.disabled = true;
                return;
            }

            select.innerHTML = '<option value="">Seleccione un médico...</option>' +
                medicos.map(m => `
                    <option value="${m.idMedico}">
                        Dr. ${m.nombres} ${m.apellidos} - CMP: ${m.numeroColegiatura}
                    </option>
                `).join('');

            select.disabled = false;

            select.addEventListener('change', async (e) => {
                selectedMedico = e.target.value;
                if (selectedMedico) {
                    const medico = medicos.find(m => m.idMedico == selectedMedico);
                    info.textContent = `Especialidades: ${medico.especialidades.join(', ')}`;
                    habilitarFecha();
                }
            });
        }
    } catch (error) {
        console.error('Error al cargar médicos:', error);
    }
}

function habilitarFecha() {
    const fechaInput = document.getElementById('fechaCita');
    fechaInput.disabled = false;

    // Establecer fecha mínima (hoy + 2 horas)
    const minDate = new Date();
    minDate.setHours(minDate.getHours() + 2);
    fechaInput.min = minDate.toISOString().split('T')[0];

    // Establecer fecha máxima (60 días)
    const maxDate = new Date();
    maxDate.setDate(maxDate.getDate() + 60);
    fechaInput.max = maxDate.toISOString().split('T')[0];

    fechaInput.addEventListener('change', async (e) => {
        selectedFecha = e.target.value;
        if (selectedFecha) {
            await cargarHorariosDisponibles();
        }
    });
}

async function cargarHorariosDisponibles() {
    const container = document.getElementById('horariosDisponibles');
    const nextBtn = document.getElementById('nextStep3');

    try {
        container.innerHTML = '<p>Cargando horarios disponibles...</p>';

        const response = await fetch(
            `${API_BASE_URL}/medicos/${selectedMedico}/horarios?fecha=${selectedFecha}`
        );

        if (response.ok) {
            const horarios = await response.json();

            if (horarios.length === 0) {
                container.innerHTML = '<p class="text-muted">No hay horarios disponibles para esta fecha</p>';
                nextBtn.disabled = true;
                return;
            }

            container.innerHTML = horarios.map(h => `
                <button type="button" class="horario-btn" data-hora="${h.horaInicio}">
                    ${h.horaInicio}
                </button>
            `).join('');

            // Event listeners para los botones de horario
            container.querySelectorAll('.horario-btn').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    container.querySelectorAll('.horario-btn').forEach(b => b.classList.remove('selected'));
                    e.target.classList.add('selected');
                    selectedHora = e.target.dataset.hora;
                    nextBtn.disabled = false;
                });
            });
        }
    } catch (error) {
        console.error('Error al cargar horarios:', error);
        container.innerHTML = '<p class="text-muted">Error al cargar horarios</p>';
    }
}

function configurarPasos() {
    document.getElementById('nextStep1').addEventListener('click', () => {
        if (!selectedEspecialidad) {
            alert('Por favor seleccione una especialidad');
            return;
        }
        mostrarPaso(2);
    });

    document.getElementById('prevStep2').addEventListener('click', () => mostrarPaso(1));
    document.getElementById('nextStep2').addEventListener('click', () => {
        if (!selectedMedico) {
            alert('Por favor seleccione un médico');
            return;
        }
        mostrarPaso(3);
    });

    document.getElementById('prevStep3').addEventListener('click', () => mostrarPaso(2));
    document.getElementById('nextStep3').addEventListener('click', () => {
        if (!selectedFecha || !selectedHora) {
            alert('Por favor seleccione fecha y hora');
            return;
        }
        mostrarResumen();
        mostrarPaso(4);
    });

    document.getElementById('prevStep4').addEventListener('click', () => mostrarPaso(3));

    document.getElementById('reservarCitaForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        await confirmarReserva();
    });
}

function mostrarPaso(paso) {
    for (let i = 1; i <= 4; i++) {
        document.getElementById(`step${i}`).style.display = i === paso ? 'block' : 'none';
    }
}

async function mostrarResumen() {
    const container = document.getElementById('resumenCita');

    try {
        // Obtener datos del médico
        const medicoResponse = await fetch(`${API_BASE_URL}/medicos/${selectedMedico}`);
        const medico = await medicoResponse.json();

        // Obtener datos de la especialidad
        const especialidadResponse = await fetch(`${API_BASE_URL}/especialidades/${selectedEspecialidad}`);
        const especialidad = await especialidadResponse.json();

        container.innerHTML = `
            <p><strong>Especialidad:</strong> ${especialidad.nombre}</p>
            <p><strong>Médico:</strong> Dr. ${medico.nombres} ${medico.apellidos}</p>
            <p><strong>Fecha:</strong> ${formatearFecha(selectedFecha)}</p>
            <p><strong>Hora:</strong> ${selectedHora}</p>
        `;
    } catch (error) {
        console.error('Error al mostrar resumen:', error);
    }
}

async function confirmarReserva() {
    const motivoConsulta = document.getElementById('motivoConsulta').value;
    const messageContainer = document.getElementById('messageContainer');

    if (motivoConsulta.length < 10) {
        showMessage('El motivo de consulta debe tener al menos 10 caracteres', 'error');
        return;
    }

    try {
        showMessage('Confirmando reserva...', 'info');

        const user = JSON.parse(localStorage.getItem('user'));

        const citaData = {
            idPaciente: user.id,
            idMedico: selectedMedico,
            fechaCita: selectedFecha,
            horaInicio: selectedHora,
            motivoConsulta: motivoConsulta
        };

        const response = await fetch(`${API_BASE_URL}/citas`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(citaData)
        });

        if (response.ok) {
            const cita = await response.json();
            showMessage('¡Cita reservada exitosamente! Redirigiendo...', 'success');

            setTimeout(() => {
                window.location.href = '/pages/paciente/mis-citas.html';
            }, 2000);
        } else {
            const error = await response.json();
            showMessage(error.message || 'Error al reservar cita', 'error');
        }
    } catch (error) {
        console.error('Error al confirmar reserva:', error);
        showMessage('Error al conectar con el servidor', 'error');
    }
}

function formatearFecha(fecha) {
    const date = new Date(fecha);
    const opciones = { year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString('es-PE', opciones);
}

function showMessage(message, type) {
    const messageContainer = document.getElementById('messageContainer');
    messageContainer.textContent = message;
    messageContainer.className = `message-container message-${type}`;
    messageContainer.style.display = 'block';
}
