-- ============================================
-- Script: 12_intermediate_queries.sql
-- Descripción: Consultas intermedias
-- Autor: [francito69]
-- Fecha: 2025-10-30
-- ============================================

-- ===========================================
-- 1. CONSULTAS CON AGREGACIONES
-- ===========================================

-- Estadísticas generales del sistema
SELECT 
    (SELECT COUNT(*) FROM usuario WHERE rol = 'PACIENTE') AS total_pacientes,
    (SELECT COUNT(*) FROM usuario WHERE rol = 'MEDICO') AS total_medicos,
    (SELECT COUNT(*) FROM especialidad WHERE estado = 'ACTIVO') AS total_especialidades,
    (SELECT COUNT(*) FROM consultorio WHERE estado = 'ACTIVO') AS total_consultorios,
    (SELECT COUNT(*) FROM cita) AS total_citas,
    (SELECT COUNT(*) FROM cita WHERE fecha_cita >= CURRENT_DATE) AS citas_futuras;

-- Médicos con más citas atendidas
SELECT 
    m.id_medico,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS citas_atendidas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS citas_canceladas,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) / NULLIF(COUNT(c.id_cita), 0), 2) AS porcentaje_atencion
FROM medico m
LEFT JOIN cita c ON m.id_medico = c.id_medico
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY m.id_medico, m.nombres, m.apellido_paterno
HAVING COUNT(c.id_cita) > 0
ORDER BY citas_atendidas DESC;

-- Especialidades más solicitadas
SELECT 
    e.nombre AS especialidad,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN c.fecha_cita >= CURRENT_DATE THEN 1 END) AS citas_futuras,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS citas_canceladas
FROM especialidad e
LEFT JOIN cita c ON e.id_especialidad = c.id_especialidad
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY e.id_especialidad, e.nombre
ORDER BY total_citas DESC;

-- Pacientes con más citas
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS paciente,
    p.dni,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS citas_atendidas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS inasistencias
FROM paciente p
LEFT JOIN cita c ON p.id_paciente = c.id_paciente
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY p.id_paciente, p.nombres, p.apellido_paterno, p.apellido_materno, p.dni
HAVING COUNT(c.id_cita) > 0
ORDER BY total_citas DESC;

-- Consultorios más utilizados
SELECT 
    co.codigo,
    co.nombre AS consultorio,
    co.piso,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN c.fecha_cita >= CURRENT_DATE THEN 1 END) AS citas_futuras
FROM consultorio co
LEFT JOIN cita c ON co.id_consultorio = c.id_consultorio
GROUP BY co.id_consultorio, co.codigo, co.nombre, co.piso
ORDER BY total_citas DESC;

-- ===========================================
-- 2. CONSULTAS CON FECHAS
-- ===========================================

-- Citas por mes (últimos 6 meses)
SELECT 
    TO_CHAR(c.fecha_cita, 'YYYY-MM') AS mes,
    TO_CHAR(c.fecha_cita, 'TMMonth YYYY') AS mes_nombre,
    COUNT(*) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS atendidas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS canceladas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS no_presentados
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(c.fecha_cita, 'YYYY-MM'), TO_CHAR(c.fecha_cita, 'TMMonth YYYY')
ORDER BY mes DESC;

-- Citas por día de la semana
SELECT 
    TO_CHAR(c.fecha_cita, 'Day') AS dia_semana,
    COUNT(*) AS total_citas,
    ROUND(AVG(COUNT(*)) OVER(), 2) AS promedio_diario
FROM cita c
WHERE c.fecha_cita >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY TO_CHAR(c.fecha_cita, 'Day'), EXTRACT(DOW FROM c.fecha_cita)
ORDER BY EXTRACT(DOW FROM c.fecha_cita);

-- Horarios más solicitados
SELECT 
    EXTRACT(HOUR FROM c.hora_inicio) AS hora,
    COUNT(*) AS cantidad_citas,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cita), 2) AS porcentaje
FROM cita c
GROUP BY EXTRACT(HOUR FROM c.hora_inicio)
ORDER BY hora;

-- ===========================================
-- 3. CONSULTAS CON SUBCONSULTAS
-- ===========================================

-- Médicos sin citas programadas
SELECT 
    m.id_medico,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    m.numero_colegiatura,
    m.email
FROM medico m
WHERE m.estado = 'ACTIVO'
  AND NOT EXISTS (
      SELECT 1 
      FROM cita c 
      WHERE c.id_medico = m.id_medico 
        AND c.fecha_cita >= CURRENT_DATE
        AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
  )
ORDER BY m.apellido_paterno;

-- Pacientes sin citas recientes (últimos 6 meses)
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    p.dni,
    p.email,
    (SELECT MAX(c.fecha_cita) 
     FROM cita c 
     WHERE c.id_paciente = p.id_paciente) AS ultima_cita
FROM paciente p
WHERE p.estado = 'ACTIVO'
  AND NOT EXISTS (
      SELECT 1 
      FROM cita c 
      WHERE c.id_paciente = p.id_paciente 
        AND c.fecha_cita >= CURRENT_DATE - INTERVAL '6 months'
  )
ORDER BY ultima_cita DESC NULLS LAST;

-- Consultorios disponibles en horario específico
SELECT 
    co.codigo,
    co.nombre,
    co.piso
FROM consultorio co
WHERE co.estado = 'ACTIVO'
  AND NOT EXISTS (
      SELECT 1
      FROM cita c
      WHERE c.id_consultorio = co.id_consultorio
        AND c.fecha_cita = CURRENT_DATE + INTERVAL '7 days'
        AND c.hora_inicio = '10:00'
        AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
  )
ORDER BY co.piso, co.codigo;

-- ===========================================
-- 4. CONSULTAS CON VISTAS
-- ===========================================

-- Usar vista de citas completas
SELECT 
    codigo_cita,
    fecha_cita,
    hora_inicio,
    paciente_nombre_completo,
    medico_nombre_completo,
    especialidad_nombre,
    estado_nombre
FROM v_citas_completas
WHERE fecha_cita BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY fecha_cita, hora_inicio;

-- Usar vista de horarios disponibles
SELECT 
    dia_semana,
    hora_inicio,
    hora_fin,
    medico_nombre,
    especialidad_nombre,
    consultorio_nombre
FROM v_horarios_disponibles
WHERE dia_semana = 'LUNES'
ORDER BY hora_inicio;

-- Usar vista de médicos con especialidades
SELECT 
    nombre_completo,
    numero_colegiatura,
    especialidades,
    cantidad_especialidades
FROM v_medicos_con_especialidades
WHERE estado = 'ACTIVO'
ORDER BY cantidad_especialidades DESC, nombre_completo;

-- ===========================================
-- 5. ANÁLISIS DE CANCELACIONES
-- ===========================================

-- Motivos de cancelación más frecuentes
SELECT 
    c.cancelado_por,
    COUNT(*) AS cantidad,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cita WHERE id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'CANCELADA')), 2) AS porcentaje
FROM cita c
WHERE c.id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'CANCELADA')
  AND c.cancelado_por IS NOT NULL
GROUP BY c.cancelado_por
ORDER BY cantidad DESC;

-- Pacientes con más cancelaciones
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS cancelaciones,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) / NULLIF(COUNT(c.id_cita), 0), 2) AS tasa_cancelacion
FROM paciente p
INNER JOIN cita c ON p.id_paciente = c.id_paciente
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY p.id_paciente, p.nombres, p.apellido_paterno
HAVING COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) > 0
ORDER BY cancelaciones DESC;

-- ===========================================
-- 6. ANÁLISIS DE OCUPACIÓN
-- ===========================================

-- Tasa de ocupación por médico
SELECT 
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    COUNT(ha.id_horario) AS horarios_configurados,
    COUNT(c.id_cita) AS citas_reservadas,
    ROUND(100.0 * COUNT(c.id_cita) / NULLIF(COUNT(ha.id_horario), 0), 2) AS tasa_ocupacion
FROM medico m
LEFT JOIN horario_atencion ha ON m.id_medico = ha.id_medico AND ha.estado = 'ACTIVO'
LEFT JOIN cita c ON m.id_medico = c.id_medico 
    AND c.fecha_cita BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
    AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
GROUP BY m.id_medico, m.nombres, m.apellido_paterno
ORDER BY tasa_ocupacion DESC;

-- ===========================================
-- 7. INDICADORES DE CALIDAD
-- ===========================================

-- Tasa de no presentación por paciente
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS no_presentaciones,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) / NULLIF(COUNT(c.id_cita), 0), 2) AS tasa_no_presentacion
FROM paciente p
INNER JOIN cita c ON p.id_paciente = c.id_paciente
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita < CURRENT_DATE
GROUP BY p.id_paciente, p.nombres, p.apellido_paterno
HAVING COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) > 0
ORDER BY tasa_no_presentacion DESC;