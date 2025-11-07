// Dashboard Médico
document.addEventListener('DOMContentLoaded', async () => {
    await cargarEstadisticas();
    await cargarCitasHoy();
    await cargarProximasCitas();
});

async function cargarEstadisticas() {
    try {
        const user = JSON.parse(localStorage.getItem('user'));
        const response = await fetch(`${API_BASE_URL}/citas/medico/${user.id}`);

        if (response.ok) {
            const citas = await response.json();

            // Citas de hoy
            const hoy = new Date().toISOString().split('T')[0];
            const citasHoy = citas.filter(c =>
                c.fechaCita === hoy &&
                (c.estado.nombre === 'PENDIENTE' || c.estado.nombre === 'CONFIRMADA')
            ).length;

            // Citas pendientes (futuras)
            const pendientes = citas.filter(c => {
                const fechaCita = new Date(c.fechaCita);
                return fechaCita >= new Date() &&
                       (c.estado.nombre === 'PENDIENTE' || c.estado.nombre === 'CONFIRMADA');
            }).length;

            // Citas atendidas (todas)
            const atendidas = citas.filter(c =>
                c.estado.nombre === 'ATENDIDA'
            ).length;

            document.getElementById('citasHoy').textContent = citasHoy;
            document.getElementById('citasPendientes').textContent = pendientes;
            document.getElementById('citasAtendidas').textContent = atendidas;
        }
    } catch (error) {
        console.error('Error al cargar estadísticas:', error);
    }
}

async function cargarCitasHoy() {
    const container = document.getElementById('citasHoyContainer');

    try {
        const user = JSON.parse(localStorage.getItem('user'));
        const hoy = new Date().toISOString().split('T')[0];
        const response = await fetch(`${API_BASE_URL}/citas/medico/${user.id}/fecha/${hoy}`);

        if (response.ok) {
            const citas = await response.json();

            if (citas.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📅</div>
                        <p class="empty-state-text">No tiene citas programadas para hoy</p>
                    </div>
                `;
                return;
            }

            const tabla = `
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Hora</th>
                            <th>Paciente</th>
                            <th>DNI</th>
                            <th>Motivo</th>
                            <th>Consultorio</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${citas.map(cita => `
                            <tr>
                                <td>${cita.horaInicio}</td>
                                <td>${cita.paciente.nombres} ${cita.paciente.apellidoPaterno}</td>
                                <td>${cita.paciente.dni}</td>
                                <td>${cita.motivoConsulta.substring(0, 50)}...</td>
                                <td>${cita.consultorio.nombre}</td>
                                <td><span class="badge badge-${getBadgeClass(cita.estado.nombre)}">${cita.estado.nombre}</span></td>
                                <td>
                                    ${cita.estado.nombre === 'CONFIRMADA' ? `
                                        <a href="/pages/medico/citas.html" class="btn btn-info btn-sm">
                                            Actualizar
                                        </a>
                                    ` : '-'}
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;

            container.innerHTML = tabla;
        }
    } catch (error) {
        console.error('Error al cargar citas de hoy:', error);
        container.innerHTML = `
            <div class="empty-state">
                <p class="empty-state-text">Error al cargar citas</p>
            </div>
        `;
    }
}

async function cargarProximasCitas() {
    const container = document.getElementById('proximasCitasContainer');

    try {
        const user = JSON.parse(localStorage.getItem('user'));
        const response = await fetch(`${API_BASE_URL}/citas/medico/${user.id}`);

        if (response.ok) {
            const citas = await response.json();

            // Filtrar citas futuras (excluyendo hoy)
            const hoy = new Date();
            hoy.setHours(0, 0, 0, 0);
            const manana = new Date(hoy);
            manana.setDate(manana.getDate() + 1);

            const citasFuturas = citas.filter(c => {
                const fechaCita = new Date(c.fechaCita);
                return fechaCita >= manana &&
                       (c.estado.nombre === 'PENDIENTE' || c.estado.nombre === 'CONFIRMADA');
            }).sort((a, b) => new Date(a.fechaCita) - new Date(b.fechaCita))
              .slice(0, 10);

            if (citasFuturas.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📅</div>
                        <p class="empty-state-text">No hay citas próximas programadas</p>
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
                            <th>Paciente</th>
                            <th>DNI</th>
                            <th>Consultorio</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${citasFuturas.map(cita => `
                            <tr>
                                <td>${formatearFecha(cita.fechaCita)}</td>
                                <td>${cita.horaInicio}</td>
                                <td>${cita.paciente.nombres} ${cita.paciente.apellidoPaterno}</td>
                                <td>${cita.paciente.dni}</td>
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
