-- ============================================
-- Script: 06_create_views.sql
-- Descripción: Crear vistas para consultas
-- ============================================

-- Vista: v_citas_completas
CREATE OR REPLACE VIEW v_citas_completas AS
SELECT 
    c.id_cita,
    c.codigo_cita,
    c.fecha_cita,
    c.hora_inicio,
    c.hora_fin,
    c.motivo_consulta,
    c.observaciones,
    
    -- Paciente
    p.id_paciente,
    p.dni AS paciente_dni,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS paciente_nombre_completo,
    p.email AS paciente_email,
    EXTRACT(YEAR FROM AGE(p.fecha_nacimiento)) AS paciente_edad,
    
    -- Médico
    m.id_medico,
    m.numero_colegiatura,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico_nombre_completo,
    m.email AS medico_email,
    
    -- Especialidad
    e.nombre AS especialidad_nombre,
    
    -- Consultorio
    co.codigo AS consultorio_codigo,
    co.nombre AS consultorio_nombre,
    co.piso AS consultorio_piso,
    
    -- Estado
    ec.codigo AS estado_codigo,
    ec.nombre AS estado_nombre,
    ec.color AS estado_color,
    
    -- Metadatos
    c.fecha_registro,
    c.fecha_actualizacion,
    c.recordatorio_enviado
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON c.id_especialidad = e.id_especialidad
INNER JOIN consultorio co ON c.id_consultorio = co.id_consultorio
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado;

COMMENT ON VIEW v_citas_completas IS 'Vista con información completa de citas';

-- Vista: v_horarios_disponibles
CREATE OR REPLACE VIEW v_horarios_disponibles AS
SELECT 
    ha.id_horario,
    ha.dia_semana,
    ha.hora_inicio,
    ha.hora_fin,
    ha.duracion_cita,
    
    m.id_medico,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico_nombre,
    m.numero_colegiatura,
    
    e.nombre AS especialidad_nombre,
    
    c.codigo AS consultorio_codigo,
    c.nombre AS consultorio_nombre,
    c.piso AS consultorio_piso
FROM horario_atencion ha
INNER JOIN medico m ON ha.id_medico = m.id_medico
INNER JOIN especialidad e ON ha.id_especialidad = e.id_especialidad
INNER JOIN consultorio c ON ha.id_consultorio = c.id_consultorio
WHERE ha.estado = 'ACTIVO'
  AND m.estado = 'ACTIVO';

-- Vista: v_medicos_con_especialidades
CREATE OR REPLACE VIEW v_medicos_con_especialidades AS
SELECT 
    m.id_medico,
    m.dni,
    CONCAT(m.nombres, ' ', m.apellido_paterno, ' ', m.apellido_materno) AS nombre_completo,
    m.numero_colegiatura,
    m.email,
    m.telefono,
    m.estado,
    STRING_AGG(e.nombre, ', ' ORDER BY e.nombre) AS especialidades,
    COUNT(me.id_especialidad) AS cantidad_especialidades
FROM medico m
LEFT JOIN medico_especialidad me ON m.id_medico = me.id_medico
LEFT JOIN especialidad e ON me.id_especialidad = e.id_especialidad
GROUP BY m.id_medico, m.dni, m.nombres, m.apellido_paterno, m.apellido_materno, 
         m.numero_colegiatura, m.email, m.telefono, m.estado;

-- Vista: v_estadisticas_citas
CREATE OR REPLACE VIEW v_estadisticas_citas AS
SELECT 
    COUNT(*) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'PENDIENTE' THEN 1 END) AS citas_pendientes,
    COUNT(CASE WHEN ec.codigo = 'CONFIRMADA' THEN 1 END) AS citas_confirmadas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS citas_atendidas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS citas_canceladas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS citas_no_presentadas,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) / NULLIF(COUNT(*), 0), 2) AS tasa_cancelacion,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) / NULLIF(COUNT(*), 0), 2) AS tasa_no_presentacion
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado;

-- Verificar vistas creadas
SELECT 
    schemaname, 
    viewname, 
    viewowner,
    definition 
FROM pg_views 
WHERE schemaname = 'public'
ORDER BY viewname;