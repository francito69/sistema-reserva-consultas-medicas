// Dashboard Administrador
document.addEventListener('DOMContentLoaded', async () => {
    await cargarEstadisticas();
    await cargarResumenCitas();
});

async function cargarEstadisticas() {
    try {
        // Cargar total de pacientes
        const pacientesResponse = await fetch(`${API_BASE_URL}/pacientes`);
        if (pacientesResponse.ok) {
            const pacientes = await pacientesResponse.json();
            document.getElementById('totalPacientes').textContent = pacientes.length;
        }

        // Cargar total de médicos
        const medicosResponse = await fetch(`${API_BASE_URL}/medicos`);
        if (medicosResponse.ok) {
            const medicos = await medicosResponse.json();
            document.getElementById('totalMedicos').textContent = medicos.length;
        }

        // Cargar total de especialidades
        const especialidadesResponse = await fetch(`${API_BASE_URL}/especialidades`);
        if (especialidadesResponse.ok) {
            const especialidades = await especialidadesResponse.json();
            document.getElementById('totalEspecialidades').textContent = especialidades.length;
        }

        // Cargar citas de hoy
        const hoy = new Date().toISOString().split('T')[0];
        const citasResponse = await fetch(`${API_BASE_URL}/citas/fecha/${hoy}`);
        if (citasResponse.ok) {
            const citas = await citasResponse.json();
            document.getElementById('citasHoy').textContent = citas.length;
        }

    } catch (error) {
        console.error('Error al cargar estadísticas:', error);
    }
}

async function cargarResumenCitas() {
    const container = document.getElementById('estadisticasContainer');

    try {
        // Obtener citas de los últimos 7 días
        const fechaInicio = new Date();
        fechaInicio.setDate(fechaInicio.getDate() - 7);

        const hoy = new Date().toISOString().split('T')[0];
        const citasResponse = await fetch(`${API_BASE_URL}/citas/fecha/${hoy}`);

        if (citasResponse.ok) {
            const citas = await citasResponse.json();

            // Contar por estado
            const estadisticas = {
                'PENDIENTE': 0,
                'CONFIRMADA': 0,
                'ATENDIDA': 0,
                'CANCELADA': 0,
                'NO_PRESENTADO': 0
            };

            citas.forEach(cita => {
                if (estadisticas.hasOwnProperty(cita.estado.nombre)) {
                    estadisticas[cita.estado.nombre]++;
                }
            });

            const html = `
                <div class="cards-grid">
                    <div class="dashboard-card">
                        <h4>Pendientes</h4>
                        <div class="card-value" style="color: #ffc107;">${estadisticas.PENDIENTE}</div>
                    </div>
                    <div class="dashboard-card">
                        <h4>Confirmadas</h4>
                        <div class="card-value" style="color: #17a2b8;">${estadisticas.CONFIRMADA}</div>
                    </div>
                    <div class="dashboard-card">
                        <h4>Atendidas</h4>
                        <div class="card-value" style="color: #28a745;">${estadisticas.ATENDIDA}</div>
                    </div>
                    <div class="dashboard-card">
                        <h4>Canceladas</h4>
                        <div class="card-value" style="color: #dc3545;">${estadisticas.CANCELADA}</div>
                    </div>
                    <div class="dashboard-card">
                        <h4>No Presentado</h4>
                        <div class="card-value" style="color: #6c757d;">${estadisticas.NO_PRESENTADO}</div>
                    </div>
                </div>
            `;

            container.innerHTML = html;
        }
    } catch (error) {
        console.error('Error al cargar resumen de citas:', error);
        container.innerHTML = `
            <div class="empty-state">
                <p class="empty-state-text">Error al cargar estadísticas</p>
            </div>
        `;
    }
}
