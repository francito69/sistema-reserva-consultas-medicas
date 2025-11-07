// Dashboard Paciente
document.addEventListener('DOMContentLoaded', async () => {
    const user = JSON.parse(localStorage.getItem('user'));

    await cargarEstadisticas();
    await cargarProximasCitas();
});

async function cargarEstadisticas() {
    try {
        const user = JSON.parse(localStorage.getItem('user'));
        const response = await fetch(`${API_BASE_URL}/citas/paciente/${user.id}`);

        if (response.ok) {
            const citas = await response.json();

            // Contar citas por estado
            const pendientes = citas.filter(c =>
                c.estado.nombre === 'PENDIENTE' || c.estado.nombre === 'CONFIRMADA'
            ).length;

            const completadas = citas.filter(c =>
                c.estado.nombre === 'ATENDIDA'
            ).length;

            document.getElementById('citasPendientes').textContent = pendientes;
            document.getElementById('citasCompletadas').textContent = completadas;

            // Encontrar próxima cita
            const citasFuturas = citas.filter(c => {
                const fechaCita = new Date(c.fechaCita);
                return fechaCita >= new Date() &&
                       (c.estado.nombre === 'PENDIENTE' || c.estado.nombre === 'CONFIRMADA');
            }).sort((a, b) => new Date(a.fechaCita) - new Date(b.fechaCita));

            if (citasFuturas.length > 0) {
                const proxima = citasFuturas[0];
                document.getElementById('proximaCita').textContent =
                    formatearFecha(proxima.fechaCita) + ' ' + proxima.horaInicio;
            } else {
                document.getElementById('proximaCita').textContent = 'Sin citas programadas';
            }
        }
    } catch (error) {
        console.error('Error al cargar estadísticas:', error);
    }
}

async function cargarProximasCitas() {
    const container = document.getElementById('proximasCitasContainer');

    try {
        const user = JSON.parse(localStorage.getItem('user'));
        const response = await fetch(`${API_BASE_URL}/citas/paciente/${user.id}`);

        if (response.ok) {
            const citas = await response.json();

            // Filtrar citas futuras pendientes/confirmadas
            const citasFuturas = citas.filter(c => {
                const fechaCita = new Date(c.fechaCita);
                return fechaCita >= new Date() &&
                       (c.estado.nombre === 'PENDIENTE' || c.estado.nombre === 'CONFIRMADA');
            }).sort((a, b) => new Date(a.fechaCita) - new Date(b.fechaCita))
              .slice(0, 5);

            if (citasFuturas.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📅</div>
                        <p class="empty-state-text">No tiene citas programadas</p>
                    </div>
                `;
                return;
            }

            const tabla = `
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Médico</th>
                            <th>Especialidad</th>
                            <th>Consultorio</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${citasFuturas.map(cita => `
                            <tr>
                                <td>${formatearFecha(cita.fechaCita)}</td>
                                <td>${cita.horaInicio}</td>
                                <td>Dr. ${cita.medico.nombres} ${cita.medico.apellidos}</td>
                                <td>${cita.especialidad || '-'}</td>
                                <td>${cita.consultorio.nombre}</td>
                                <td><span class="badge badge-${getBadgeClass(cita.estado.nombre)}">${cita.estado.nombre}</span></td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;

            container.innerHTML = tabla;
        }
    } catch (error) {
        console.error('Error al cargar próximas citas:', error);
        container.innerHTML = `
            <div class="empty-state">
                <p class="empty-state-text">Error al cargar citas</p>
            </div>
        `;
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
