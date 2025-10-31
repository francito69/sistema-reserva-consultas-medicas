-- =============================================
-- CONSULTAS SQL ÚTILES
-- Sistema de Reserva de Consultas Médicas
-- =============================================

-- =============================================
-- CONSULTAS DE VERIFICACIÓN
-- =============================================

-- Ver resumen de todas las tablas
SELECT 
    'piso' AS tabla, COUNT(*) AS total FROM piso
UNION ALL
SELECT 'especialidad', COUNT(*) FROM especialidad
UNION ALL
SELECT 'consultorio', COUNT(*) FROM consultorio
UNION ALL
SELECT 'paciente', COUNT(*) FROM paciente
UNION ALL
SELECT 'medico', COUNT(*) FROM medico
UNION ALL
SELECT 'horario_atencion', COUNT(*) FROM horario_atencion
UNION ALL
SELECT 'estado_cita', COUNT(*) FROM estado_cita
UNION ALL
SELECT 'cita', COUNT(*) FROM cita
UNION ALL
SELECT 'notificacion', COUNT(*) FROM notificacion
UNION ALL
SELECT 'usuario', COUNT(*) FROM usuario;

-- =============================================
-- CONSULTAS PARA EL MÓDULO DE PACIENTES
-- =============================================

-- Listar todos los pacientes activos
SELECT 
    id_paciente,
    dni,
    nombres || ' ' || apellido_paterno || ' ' || apellido_materno AS nombre_completo,
    CASE sexo 
        WHEN 'M' THEN 'Masculino'
        WHEN 'F' THEN 'Femenino'
    END AS sexo,
    EXTRACT(YEAR FROM AGE(fecha_nacimiento)) AS edad,
    telefono,
    email,
    fecha_registro
FROM paciente
WHERE activo = TRUE
ORDER BY apellido_paterno, apellido_materno, nombres;

-- Buscar paciente por DNI
SELECT * FROM paciente WHERE dni = '12345678';

-- Historial de citas de un paciente
SELECT 
    c.id_cita,
    c.fecha_cita,
    c.hora_cita,
    m.nombres || ' ' || m.apellido_paterno AS medico,
    e.nombre AS especialidad,
    ec.nombre AS estado,
    c.motivo_consulta
FROM cita c
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.id_paciente = 1
ORDER BY c.fecha_cita DESC, c.hora_cita DESC;

-- =============================================
-- CONSULTAS PARA EL MÓDULO DE MÉDICOS
-- =============================================

-- Listar médicos con su especialidad
SELECT 
    m.id_medico,
    m.codigo_medico,
    m.numero_colegiatura,
    m.nombres || ' ' || m.apellido_paterno || ' ' || m.apellido_materno AS nombre_completo,
    e.nombre AS especialidad,
    m.telefono,
    m.email,
    m.activo
FROM medico m
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
ORDER BY e.nombre, m.apellido_paterno;

-- Buscar médicos por especialidad
SELECT 
    m.codigo_medico,
    m.nombres || ' ' || m.apellido_paterno AS medico,
    m.numero_colegiatura,
    m.telefono,
    m.email
FROM medico m
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
WHERE e.codigo = 'CARD' -- Cambiar por el código de especialidad deseado
  AND m.activo = TRUE;

-- Ver agenda completa de un médico
SELECT 
    CASE ha.dia_semana
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS dia,
    ha.hora_inicio,
    ha.hora_fin,
    ha.duracion_cita || ' min' AS duracion,
    ha.cupos_maximos AS cupos,
    c.numero AS consultorio,
    p.numero AS piso
FROM horario_atencion ha
INNER JOIN consultorio c ON ha.id_consultorio = c.id_consultorio
INNER JOIN piso p ON c.id_piso = p.id_piso
WHERE ha.id_medico = 1 -- ID del médico
  AND ha.activo = TRUE
ORDER BY ha.dia_semana, ha.hora_inicio;

-- =============================================
-- CONSULTAS PARA EL MÓDULO DE CITAS
-- =============================================

-- Listar todas las citas programadas
SELECT 
    c.id_cita,
    c.fecha_cita,
    c.hora_cita,
    p.nombres || ' ' || p.apellido_paterno AS paciente,
    p.dni,
    m.nombres || ' ' || m.apellido_paterno AS medico,
    e.nombre AS especialidad,
    cons.numero AS consultorio,
    ec.nombre AS estado,
    c.motivo_consulta
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
INNER JOIN consultorio cons ON c.id_consultorio = cons.id_consultorio
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
ORDER BY c.fecha_cita, c.hora_cita;

-- Citas del día de hoy
SELECT 
    c.hora_cita,
    p.nombres || ' ' || p.apellido_paterno AS paciente,
    m.nombres || ' ' || m.apellido_paterno AS medico,
    cons.numero AS consultorio,
    ec.nombre AS estado
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN consultorio cons ON c.id_consultorio = cons.id_consultorio
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita = CURRENT_DATE
ORDER BY c.hora_cita;

-- Citas pendientes de confirmar
SELECT 
    c.id_cita,
    c.fecha_cita,
    c.hora_cita,
    p.nombres || ' ' || p.apellido_paterno AS paciente,
    p.telefono,
    p.email,
    m.nombres || ' ' || m.apellido_paterno AS medico
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE ec.codigo = 'PEND'
ORDER BY c.fecha_cita, c.hora_cita;

-- Verificar disponibilidad de horario para nueva cita
-- (Cuántos cupos quedan disponibles)
SELECT 
    ha.cupos_maximos,
    COUNT(c.id_cita) AS citas_reservadas,
    ha.cupos_maximos - COUNT(c.id_cita) AS cupos_disponibles
FROM horario_atencion ha
LEFT JOIN cita c ON c.id_medico = ha.id_medico 
    AND EXTRACT(DOW FROM c.fecha_cita) + 1 = ha.dia_semana
    AND c.hora_cita BETWEEN ha.hora_inicio AND ha.hora_fin
    AND c.fecha_cita = '2025-11-04' -- Fecha deseada
WHERE ha.id_medico = 1 -- ID del médico
  AND ha.dia_semana = 2 -- Día de la semana (1=Lunes, 2=Martes, etc.)
GROUP BY ha.id_horario, ha.cupos_maximos;

-- =============================================
-- CONSULTAS PARA REPORTES Y ESTADÍSTICAS
-- =============================================

-- Total de citas por estado
SELECT 
    ec.nombre AS estado,
    ec.color,
    COUNT(*) AS total_citas,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) || '%' AS porcentaje
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY ec.id_estado, ec.nombre, ec.color
ORDER BY total_citas DESC;

-- Médicos con más citas atendidas
SELECT 
    m.nombres || ' ' || m.apellido_paterno AS medico,
    e.nombre AS especialidad,
    COUNT(*) AS total_citas_atendidas
FROM cita c
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE ec.codigo = 'ATEN'
GROUP BY m.id_medico, m.nombres, m.apellido_paterno, e.nombre
ORDER BY total_citas_atendidas DESC;

-- Especialidades más solicitadas
SELECT 
    e.nombre AS especialidad,
    COUNT(*) AS total_citas
FROM cita c
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
GROUP BY e.id_especialidad, e.nombre
ORDER BY total_citas DESC;

-- Citas por mes (últimos 6 meses)
SELECT 
    TO_CHAR(c.fecha_cita, 'YYYY-MM') AS mes,
    COUNT(*) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATEN' THEN 1 END) AS atendidas,
    COUNT(CASE WHEN ec.codigo = 'CANC' THEN 1 END) AS canceladas,
    COUNT(CASE WHEN ec.codigo = 'NOAS' THEN 1 END) AS no_asistio
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(c.fecha_cita, 'YYYY-MM')
ORDER BY mes DESC;

-- Tasa de ocupación por médico (últimos 30 días)
SELECT 
    m.nombres || ' ' || m.apellido_paterno AS medico,
    e.nombre AS especialidad,
    COUNT(c.id_cita) AS citas_programadas,
    COUNT(CASE WHEN ec.codigo = 'ATEN' THEN 1 END) AS citas_atendidas,
    ROUND(COUNT(CASE WHEN ec.codigo = 'ATEN' THEN 1 END) * 100.0 / NULLIF(COUNT(c.id_cita), 0), 2) AS porcentaje_atencion
FROM medico m
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
LEFT JOIN cita c ON c.id_medico = m.id_medico 
    AND c.fecha_cita >= CURRENT_DATE - 30
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE m.activo = TRUE
GROUP BY m.id_medico, m.nombres, m.apellido_paterno, e.nombre
ORDER BY porcentaje_atencion DESC;

-- =============================================
-- CONSULTAS DE ADMINISTRACIÓN
-- =============================================

-- Usuarios del sistema
SELECT 
    u.username,
    u.rol,
    CASE 
        WHEN u.rol = 'PACIENTE' THEN p.nombres || ' ' || p.apellido_paterno
        WHEN u.rol = 'MEDICO' THEN m.nombres || ' ' || m.apellido_paterno
        ELSE 'Administrador'
    END AS nombre_completo,
    u.activo,
    u.ultimo_acceso,
    u.fecha_creacion
FROM usuario u
LEFT JOIN paciente p ON u.rol = 'PACIENTE' AND u.id_referencia = p.id_paciente
LEFT JOIN medico m ON u.rol = 'MEDICO' AND u.id_referencia = m.id_medico
ORDER BY u.rol, u.username;

-- Notificaciones pendientes de enviar
SELECT 
    n.id_notificacion,
    n.tipo_notificacion,
    n.destinatario,
    n.asunto,
    c.fecha_cita,
    c.hora_cita,
    p.nombres || ' ' || p.apellido_paterno AS paciente
FROM notificacion n
INNER JOIN cita c ON n.id_cita = c.id_cita
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
WHERE n.enviado = FALSE
ORDER BY c.fecha_cita, c.hora_cita;

-- =============================================
-- CONSULTAS DE MANTENIMIENTO
-- =============================================

-- Eliminar citas antiguas canceladas (más de 1 año)
-- PRECAUCIÓN: Ejecutar solo si estás seguro
/*
DELETE FROM cita 
WHERE id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'CANC')
  AND fecha_cita < CURRENT_DATE - INTERVAL '1 year';
*/

-- Actualizar última modificación de paciente
/*
UPDATE paciente 
SET fecha_actualizacion = CURRENT_TIMESTAMP 
WHERE id_paciente = ?;
*/

-- Desactivar médico
/*
UPDATE medico 
SET activo = FALSE, fecha_actualizacion = CURRENT_TIMESTAMP 
WHERE id_medico = ?;
*/

-- =============================================
-- VISTAS ÚTILES (OPCIONAL)
-- =============================================

-- Vista: Próximas citas (siguientes 7 días)
CREATE OR REPLACE VIEW v_proximas_citas AS
SELECT 
    c.id_cita,
    c.fecha_cita,
    c.hora_cita,
    p.nombres || ' ' || p.apellido_paterno AS paciente,
    p.telefono AS telefono_paciente,
    p.email AS email_paciente,
    m.nombres || ' ' || m.apellido_paterno AS medico,
    e.nombre AS especialidad,
    cons.numero AS consultorio,
    ec.nombre AS estado,
    ec.color AS color_estado
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad
INNER JOIN consultorio cons ON c.id_consultorio = cons.id_consultorio
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita BETWEEN CURRENT_DATE AND CURRENT_DATE + 7
  AND ec.codigo IN ('PEND', 'CONF')
ORDER BY c.fecha_cita, c.hora_cita;

-- Usar la vista:
-- SELECT * FROM v_proximas_citas;

-- =============================================
-- FIN DE CONSULTAS ÚTILES
-- =============================================