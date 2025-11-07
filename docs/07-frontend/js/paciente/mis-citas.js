// Mis Citas - Listado y Cancelación
let citaActual = null;

document.addEventListener('DOMContentLoaded', async () => {
    await cargarCitas();

    document.getElementById('filtroEstado').addEventListener('change', async () => {
        await cargarCitas();
    });

    document.getElementById('confirmarCancelacion').addEventListener('click', async () => {
        await cancelarCita();
    });
});

async function cargarCitas() {
    const container = document.getElementById('citasContainer');
    const filtroEstado = document.getElementById('filtroEstado').value;

    try {
        container.innerHTML = `
            <div class="loading-spinner">
                <div class="spinner"></div>
            </div>
        `;

        const user = JSON.parse(localStorage.getItem('user'));
        const response = await fetch(`${API_BASE_URL}/citas/paciente/${user.id}`);

        if (response.ok) {
            let citas = await response.json();

            // Aplicar filtro
            if (filtroEstado) {
                citas = citas.filter(c => c.estado.nombre === filtroEstado);
            }

            // Ordenar por fecha descendente
            citas.sort((a, b) => new Date(b.fechaCita) - new Date(a.fechaCita));

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

            // Agregar event listeners a los botones
            container.querySelectorAll('.btn-cancelar').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    const idCita = e.target.dataset.id;
                    const cita = citas.find(c => c.idCita == idCita);
                    mostrarModalCancelar(cita);
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
    const puedeCancel ar = (fechaCita > hoy) &&
                         (cita.estado.nombre === 'PENDIENTE' || cita.estado.nombre === 'CONFIRMADA');

    // Verificar si quedan más de 2 horas
    const horasCita = new Date(cita.fechaCita + 'T' + cita.horaInicio);
    const horasRestantes = (horasCita - new Date()) / (1000 * 60 * 60);
    const puedeCancelarTiempo = horasRestantes > 2;

    return `
        <div class="cita-card">
            <div class="cita-header">
                <div class="cita-fecha">
                    📅 ${formatearFecha(cita.fechaCita)} - ${cita.horaInicio}
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
                    <strong>Médico:</strong>
                    <span>Dr. ${cita.medico.nombres} ${cita.medico.apellidos}</span>
                </div>
                <div class="cita-info">
                    <strong>Especialidad:</strong>
                    <span>${cita.especialidad || 'N/A'}</span>
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
                ${puedeCancel ar && puedeCancelarTiempo ? `
                    <button class="btn btn-danger btn-sm btn-cancelar" data-id="${cita.idCita}">
                        ❌ Cancelar Cita
                    </button>
                ` : puedeCancel ar && !puedeCancelarTiempo ? `
                    <small class="text-muted">
                        No se puede cancelar (faltan menos de 2 horas)
                    </small>
                ` : ''}
            </div>
        </div>
    `;
}

function mostrarModalCancelar(cita) {
    citaActual = cita;
    const modal = document.getElementById('cancelarModal');
    const detalles = document.getElementById('citaDetalles');

    detalles.innerHTML = `
        <hr>
        <p><strong>Fecha:</strong> ${formatearFecha(cita.fechaCita)} - ${cita.horaInicio}</p>
        <p><strong>Médico:</strong> Dr. ${cita.medico.nombres} ${cita.medico.apellidos}</p>
    `;

    document.getElementById('motivoCancelacion').value = '';
    modal.style.display = 'flex';
}

function cerrarModal() {
    document.getElementById('cancelarModal').style.display = 'none';
    citaActual = null;
}

async function cancelarCita() {
    const motivo = document.getElementById('motivoCancelacion').value;

    if (motivo.length < 10) {
        alert('El motivo debe tener al menos 10 caracteres');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/citas/${citaActual.idCita}/cancelar`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ motivo: motivo })
        });

        if (response.ok) {
            alert('Cita cancelada exitosamente');
            cerrarModal();
            await cargarCitas();
        } else {
            const error = await response.json();
            alert(error.message || 'Error al cancelar cita');
        }
    } catch (error) {
        console.error('Error al cancelar cita:', error);
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
    const modal = document.getElementById('cancelarModal');
    if (event.target === modal) {
        cerrarModal();
    }
}
