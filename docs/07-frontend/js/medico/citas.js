// Gestión de Citas - Médico
let citaActual = null;

document.addEventListener('DOMContentLoaded', async () => {
    await cargarCitas();

    // Configurar fecha de hoy por defecto
    const hoy = new Date().toISOString().split('T')[0];
    document.getElementById('filtroFecha').value = hoy;

    document.getElementById('filtroFecha').addEventListener('change', async () => {
        await cargarCitas();
    });

    document.getElementById('filtroEstado').addEventListener('change', async () => {
        await cargarCitas();
    });

    document.getElementById('confirmarActualizacion').addEventListener('click', async () => {
        await actualizarEstado();
    });
});

async function cargarCitas() {
    const container = document.getElementById('citasContainer');
    const filtroFecha = document.getElementById('filtroFecha').value;
    const filtroEstado = document.getElementById('filtroEstado').value;

    try {
        container.innerHTML = `
            <div class="loading-spinner">
                <div class="spinner"></div>
            </div>
        `;

        const user = JSON.parse(localStorage.getItem('user'));
        let url = `${API_BASE_URL}/citas/medico/${user.id}`;

        if (filtroFecha) {
            url = `${API_BASE_URL}/citas/medico/${user.id}/fecha/${filtroFecha}`;
        }

        const response = await fetch(url);

        if (response.ok) {
            let citas = await response.json();

            // Aplicar filtro de estado
            if (filtroEstado) {
                citas = citas.filter(c => c.estado.nombre === filtroEstado);
            }

            // Ordenar por hora
            citas.sort((a, b) => a.horaInicio.localeCompare(b.horaInicio));

            if (citas.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📅</div>
                        <p class="empty-state-text">No se encontraron citas</p>
                    </div>
                `;
                return;
            }

            const citasHtml = citas.map(cita => crearCitaCard(cita)).join('');
            container.innerHTML = citasHtml;

            // Agregar event listeners
            container.querySelectorAll('.btn-actualizar').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    const idCita = e.target.dataset.id;
                    const cita = citas.find(c => c.idCita == idCita);
                    mostrarModalActualizar(cita);
                });
            });
        }
    } catch (error) {
        console.error('Error al cargar citas:', error);
        container.innerHTML = `
            <div class="empty-state">
                <p class="empty-state-text">Error al cargar citas</p>
            </div>
        `;
    }
}

function crearCitaCard(cita) {
    const fechaCita = new Date(cita.fechaCita);
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    fechaCita.setHours(0, 0, 0, 0);

    const esHoyOPasado = fechaCita <= hoy;
    const puedeActualizar = esHoyOPasado && cita.estado.nombre === 'CONFIRMADA';

    return `
        <div class="cita-card">
            <div class="cita-header">
                <div class="cita-fecha">
                    📅 ${formatearFecha(cita.fechaCita)} - ${cita.horaInicio} a ${cita.horaFin}
                </div>
                <span class="badge badge-${getBadgeClass(cita.estado.nombre)}">
                    ${cita.estado.nombre}
                </span>
            </div>
            <div class="cita-body">
                <div class="cita-info">
                    <strong>Código:</strong>
                    <span>${cita.codigoCita || 'N/A'}</span>
                </div>
                <div class="cita-info">
                    <strong>Paciente:</strong>
                    <span>${cita.paciente.nombres} ${cita.paciente.apellidoPaterno} ${cita.paciente.apellidoMaterno}</span>
                </div>
                <div class="cita-info">
                    <strong>DNI:</strong>
                    <span>${cita.paciente.dni}</span>
                </div>
                <div class="cita-info">
                    <strong>Teléfono:</strong>
                    <span>${cita.paciente.telefono || 'N/A'}</span>
                </div>
                <div class="cita-info">
                    <strong>Consultorio:</strong>
                    <span>${cita.consultorio.nombre} - Piso ${cita.consultorio.piso.numero}</span>
                </div>
                <div class="cita-info">
                    <strong>Motivo:</strong>
                    <span>${cita.motivoConsulta}</span>
                </div>
                ${cita.observaciones ? `
                    <div class="cita-info">
                        <strong>Observaciones:</strong>
                        <span>${cita.observaciones}</span>
                    </div>
                ` : ''}
            </div>
            <div class="cita-actions">
                ${puedeActualizar ? `
                    <button class="btn btn-success btn-sm btn-actualizar" data-id="${cita.idCita}">
                        ✏️ Actualizar Estado
                    </button>
                ` : ''}
            </div>
        </div>
    `;
}

function mostrarModalActualizar(cita) {
    citaActual = cita;
    const modal = document.getElementById('actualizarEstadoModal');
    const detalles = document.getElementById('citaDetalles');

    detalles.innerHTML = `
        <div style="background-color: var(--gray-50); padding: 15px; border-radius: 8px; margin-bottom: 20px;">
            <p><strong>Fecha:</strong> ${formatearFecha(cita.fechaCita)} - ${cita.horaInicio}</p>
            <p><strong>Paciente:</strong> ${cita.paciente.nombres} ${cita.paciente.apellidoPaterno} ${cita.paciente.apellidoMaterno}</p>
            <p><strong>DNI:</strong> ${cita.paciente.dni}</p>
            <p><strong>Motivo:</strong> ${cita.motivoConsulta}</p>
        </div>
    `;

    document.getElementById('nuevoEstado').value = '';
    document.getElementById('observaciones').value = '';
    modal.style.display = 'flex';
}

function cerrarModal() {
    document.getElementById('actualizarEstadoModal').style.display = 'none';
    citaActual = null;
}

async function actualizarEstado() {
    const nuevoEstado = document.getElementById('nuevoEstado').value;
    const observaciones = document.getElementById('observaciones').value;

    if (!nuevoEstado) {
        alert('Por favor seleccione un estado');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/citas/${citaActual.idCita}/estado`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                estado: nuevoEstado,
                observaciones: observaciones
            })
        });

        if (response.ok) {
            alert('Estado actualizado exitosamente');
            cerrarModal();
            await cargarCitas();
        } else {
            const error = await response.json();
            alert(error.message || 'Error al actualizar estado');
        }
    } catch (error) {
        console.error('Error al actualizar estado:', error);
        alert('Error al conectar con el servidor');
    }
}

function formatearFecha(fecha) {
    const date = new Date(fecha);
    const opciones = { year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString('es-PE', opciones);
}

function getBadgeClass(estado) {
    const map = {
        'PENDIENTE': 'warning',
        'CONFIRMADA': 'info',
        'ATENDIDA': 'success',
        'CANCELADA': 'danger',
        'NO_PRESENTADO': 'secondary'
    };
    return map[estado] || 'secondary';
}

// Cerrar modal al hacer clic fuera
window.onclick = function(event) {
    const modal = document.getElementById('actualizarEstadoModal');
    if (event.target === modal) {
        cerrarModal();
    }
}
