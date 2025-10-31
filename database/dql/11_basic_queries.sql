-- ============================================
-- Script: 11_basic_queries.sql
-- Descripción: Consultas básicas del sistema
-- Autor: [francito69]
-- Fecha: 2025-10-30
-- ============================================

-- ===========================================
-- 1. CONSULTAS DE VERIFICACIÓN
-- ===========================================

-- Listar todas las tablas con cantidad de registros
SELECT 
    schemaname AS esquema,
    tablename AS tabla,
    (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public') AS total_tablas
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Ver tamaño de cada tabla
SELECT 
    tablename AS tabla,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS tamaño_total,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS tamaño_datos,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - 
                   pg_relation_size(schemaname||'.'||tablename)) AS tamaño_indices
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ===========================================
-- 2. CONSULTAS DE USUARIOS
-- ===========================================

-- Listar todos los usuarios
SELECT 
    id_usuario,
    nombre_usuario,
    email,
    rol,
    estado,
    TO_CHAR(fecha_creacion, 'DD/MM/YYYY HH24:MI') AS fecha_creacion
FROM usuario
ORDER BY rol, nombre_usuario;

-- Contar usuarios por rol
SELECT 
    rol,
    COUNT(*) AS cantidad,
    COUNT(CASE WHEN estado = 'ACTIVO' THEN 1 END) AS activos,
    COUNT(CASE WHEN estado = 'INACTIVO' THEN 1 END) AS inactivos
FROM usuario
GROUP BY rol
ORDER BY rol;

-- ===========================================
-- 3. CONSULTAS DE PACIENTES
-- ===========================================

-- Listar todos los pacientes
SELECT 
    p.id_paciente,
    p.dni,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
    p.genero,
    fn_calcular_edad(p.fecha_nacimiento) AS edad,
    p.email,
    p.estado
FROM paciente p
ORDER BY p.apellido_paterno, p.apellido_materno, p.nombres;

-- Buscar paciente por DNI
SELECT 
    p.id_paciente,
    p.dni,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
    TO_CHAR(p.fecha_nacimiento, 'DD/MM/YYYY') AS fecha_nacimiento,
    fn_calcular_edad(p.fecha_nacimiento) AS edad,
    p.genero,
    p.direccion,
    p.email,
    u.nombre_usuario
FROM paciente p
INNER JOIN usuario u ON p.id_usuario = u.id_usuario
WHERE p.dni = '70123456';

-- Listar teléfonos de un paciente
SELECT 
    pt.tipo,
    pt.numero,
    pt.es_principal
FROM paciente_telefono pt
WHERE pt.id_paciente = 1
ORDER BY pt.es_principal DESC, pt.tipo;

-- ===========================================
-- 4. CONSULTAS DE MÉDICOS
-- ===========================================

-- Listar todos los médicos
SELECT 
    m.id_medico,
    m.numero_colegiatura,
    CONCAT(m.nombres, ' ', m.apellido_paterno, ' ', m.apellido_materno) AS nombre_completo,
    m.email,
    m.telefono,
    m.estado
FROM medico m
ORDER BY m.apellido_paterno, m.apellido_materno;

-- Buscar médico por número de colegiatura
SELECT 
    m.id_medico,
    m.numero_colegiatura,
    CONCAT(m.nombres, ' ', m.apellido_paterno, ' ', m.apellido_materno) AS nombre_completo,
    m.dni,
    m.email,
    m.telefono
FROM medico m
WHERE m.numero_colegiatura = 'CMP-12345';

-- ===========================================
-- 5. CONSULTAS DE ESPECIALIDADES
-- ===========================================

-- Listar todas las especialidades
SELECT 
    id_especialidad,
    codigo,
    nombre,
    descripcion,
    estado
FROM especialidad
ORDER BY nombre;

-- Especialidades de un médico específico
SELECT 
    e.codigo,
    e.nombre,
    me.fecha_certificacion,
    me.institucion_certificadora
FROM medico_especialidad me
INNER JOIN especialidad e ON me.id_especialidad = e.id_especialidad
WHERE me.id_medico = 1
ORDER BY e.nombre;

-- ===========================================
-- 6. CONSULTAS DE CONSULTORIOS
-- ===========================================

-- Listar todos los consultorios
SELECT 
    codigo,
    nombre,
    piso,
    capacidad,
    equipamiento,
    estado
FROM consultorio
ORDER BY piso, codigo;

-- Consultorios por piso
SELECT 
    piso,
    COUNT(*) AS cantidad_consultorios,
    COUNT(CASE WHEN estado = 'ACTIVO' THEN 1 END) AS activos
FROM consultorio
GROUP BY piso
ORDER BY piso;

-- ===========================================
-- 7. CONSULTAS DE HORARIOS
-- ===========================================

-- Horarios de atención de un médico
SELECT 
    ha.dia_semana,
    TO_CHAR(ha.hora_inicio, 'HH24:MI') AS hora_inicio,
    TO_CHAR(ha.hora_fin, 'HH24:MI') AS hora_fin,
    ha.duracion_cita,
    e.nombre AS especialidad,
    c.nombre AS consultorio,
    c.piso
FROM horario_atencion ha
INNER JOIN especialidad e ON ha.id_especialidad = e.id_especialidad
INNER JOIN consultorio c ON ha.id_consultorio = c.id_consultorio
WHERE ha.id_medico = 1 AND ha.estado = 'ACTIVO'
ORDER BY 
    CASE ha.dia_semana
        WHEN 'LUNES' THEN 1
        WHEN 'MARTES' THEN 2
        WHEN 'MIERCOLES' THEN 3
        WHEN 'JUEVES' THEN 4
        WHEN 'VIERNES' THEN 5
        WHEN 'SABADO' THEN 6
    END,
    ha.hora_inicio;

-- Todos los horarios disponibles hoy
SELECT 
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    e.nombre AS especialidad,
    c.nombre AS consultorio,
    TO_CHAR(ha.hora_inicio, 'HH24:MI') || ' - ' || TO_CHAR(ha.hora_fin, 'HH24:MI') AS horario
FROM horario_atencion ha
INNER JOIN medico m ON ha.id_medico = m.id_medico
INNER JOIN especialidad e ON ha.id_especialidad = e.id_especialidad
INNER JOIN consultorio c ON ha.id_consultorio = c.id_consultorio
WHERE ha.dia_semana = TO_CHAR(CURRENT_DATE, 'DAY', 'es_PE.UTF-8')
  AND ha.estado = 'ACTIVO'
  AND m.estado = 'ACTIVO'
ORDER BY ha.hora_inicio, m.apellido_paterno;

-- ===========================================
-- 8. CONSULTAS DE CITAS
-- ===========================================

-- Listar todas las citas con información básica
SELECT 
    c.codigo_cita,
    TO_CHAR(c.fecha_cita, 'DD/MM/YYYY') AS fecha,
    TO_CHAR(c.hora_inicio, 'HH24:MI') AS hora,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    ec.nombre AS estado
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
ORDER BY c.fecha_cita DESC, c.hora_inicio DESC
LIMIT 20;

-- Buscar cita por código
SELECT 
    c.codigo_cita,
    TO_CHAR(c.fecha_cita, 'DD/MM/YYYY') AS fecha_cita,
    TO_CHAR(c.hora_inicio, 'HH24:MI') || ' - ' || TO_CHAR(c.hora_fin, 'HH24:MI') AS horario,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS paciente,
    p.dni AS paciente_dni,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    e.nombre AS especialidad,
    co.nombre AS consultorio,
    ec.nombre AS estado,
    c.motivo_consulta
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON c.id_especialidad = e.id_especialidad
INNER JOIN consultorio co ON c.id_consultorio = co.id_consultorio
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.codigo_cita = 'CITA-2025-0001';

-- Citas de un paciente específico
SELECT 
    c.codigo_cita,
    TO_CHAR(c.fecha_cita, 'DD/MM/YYYY') AS fecha,
    TO_CHAR(c.hora_inicio, 'HH24:MI') AS hora,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    e.nombre AS especialidad,
    ec.nombre AS estado
FROM cita c
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON c.id_especialidad = e.id_especialidad
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.id_paciente = 1
ORDER BY c.fecha_cita DESC, c.hora_inicio DESC;

-- Próximas citas de hoy
SELECT 
    c.codigo_cita,
    TO_CHAR(c.hora_inicio, 'HH24:MI') AS hora,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    co.nombre AS consultorio,
    ec.nombre AS estado
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN consultorio co ON c.id_consultorio = co.id_consultorio
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita = CURRENT_DATE
  AND ec.codigo IN ('PENDIENTE', 'CONFIRMADA')
ORDER BY c.hora_inicio;

-- ===========================================
-- 9. CONSULTAS DE ESTADOS
-- ===========================================

-- Conteo de citas por estado
SELECT 
    ec.nombre AS estado,
    ec.color,
    COUNT(c.id_cita) AS cantidad
FROM estado_cita ec
LEFT JOIN cita c ON ec.id_estado = c.id_estado
GROUP BY ec.id_estado, ec.nombre, ec.color
ORDER BY ec.id_estado;

-- ===========================================
-- 10. CONSULTAS DE NOTIFICACIONES
-- ===========================================

-- Últimas notificaciones
SELECT 
    n.tipo_notificacion,
    n.destinatario_nombre,
    n.destinatario_email,
    n.asunto,
    n.estado_envio,
    TO_CHAR(n.fecha_creacion, 'DD/MM/YYYY HH24:MI:SS') AS fecha_creacion,
    c.codigo_cita
FROM notificacion n
INNER JOIN cita c ON n.id_cita = c.id_cita
ORDER BY n.fecha_creacion DESC
LIMIT 10;

-- Notificaciones pendientes de envío
SELECT 
    n.id_notificacion,
    n.tipo_notificacion,
    n.destinatario_email,
    n.asunto,
    n.intentos_envio,
    c.codigo_cita
FROM notificacion n
INNER JOIN cita c ON n.id_cita = c.id_cita
WHERE n.estado_envio = 'PENDIENTE'
ORDER BY n.fecha_creacion;

-- Notificaciones con error
SELECT 
    n.id_notificacion,
    n.tipo_notificacion,
    n.destinatario_email,
    n.intentos_envio,
    n.mensaje_error,
    c.codigo_cita
FROM notificacion n
INNER JOIN cita c ON n.id_cita = c.id_cita
WHERE n.estado_envio = 'ERROR'
ORDER BY n.fecha_creacion DESC;