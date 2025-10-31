-- ============================================
-- Script: 13_advanced_queries.sql
-- Descripción: Consultas avanzadas
-- Autor: [francito69]
-- Fecha: 2025-10-30
-- ============================================

-- ===========================================
-- 1. CONSULTAS CON WINDOW FUNCTIONS
-- ===========================================

-- Ranking de médicos por cantidad de citas atendidas
SELECT 
    ROW_NUMBER() OVER (ORDER BY COUNT(c.id_cita) DESC) AS ranking,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    m.numero_colegiatura,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS citas_atendidas,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) / NULLIF(COUNT(c.id_cita), 0), 2) AS tasa_atencion,
    ROUND(AVG(COUNT(c.id_cita)) OVER(), 2) AS promedio_general
FROM medico m
LEFT JOIN cita c ON m.id_medico = c.id_medico
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE m.estado = 'ACTIVO'
GROUP BY m.id_medico, m.nombres, m.apellido_paterno, m.numero_colegiatura
HAVING COUNT(c.id_cita) > 0
ORDER BY ranking;

-- Análisis de tendencia de citas por mes
SELECT 
    TO_CHAR(fecha_cita, 'YYYY-MM') AS mes,
    COUNT(*) AS citas_mes,
    LAG(COUNT(*), 1) OVER (ORDER BY TO_CHAR(fecha_cita, 'YYYY-MM')) AS citas_mes_anterior,
    COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY TO_CHAR(fecha_cita, 'YYYY-MM')) AS diferencia,
    ROUND(100.0 * (COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY TO_CHAR(fecha_cita, 'YYYY-MM'))) / 
          NULLIF(LAG(COUNT(*), 1) OVER (ORDER BY TO_CHAR(fecha_cita, 'YYYY-MM')), 0), 2) AS variacion_porcentual
FROM cita
WHERE fecha_cita >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY TO_CHAR(fecha_cita, 'YYYY-MM')
ORDER BY mes DESC;

-- Distribución acumulada de citas por hora
SELECT 
    EXTRACT(HOUR FROM hora_inicio) AS hora,
    COUNT(*) AS citas,
    SUM(COUNT(*)) OVER (ORDER BY EXTRACT(HOUR FROM hora_inicio)) AS citas_acumuladas,
    ROUND(100.0 * SUM(COUNT(*)) OVER (ORDER BY EXTRACT(HOUR FROM hora_inicio)) / 
          SUM(COUNT(*)) OVER(), 2) AS porcentaje_acumulado
FROM cita
GROUP BY EXTRACT(HOUR FROM hora_inicio)
ORDER BY hora;

-- ===========================================
-- 2. CONSULTAS CON CTEs (Common Table Expressions)
-- ===========================================

-- Análisis completo de productividad de médicos
WITH citas_medico AS (
    SELECT 
        m.id_medico,
        CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico_nombre,
        COUNT(c.id_cita) AS total_citas,
        COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS atendidas,
        COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS canceladas,
        COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS no_presentados
    FROM medico m
    LEFT JOIN cita c ON m.id_medico = c.id_medico
    LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
    WHERE m.estado = 'ACTIVO'
    GROUP BY m.id_medico, m.nombres, m.apellido_paterno
),
horarios_medico AS (
    SELECT 
        id_medico,
        COUNT(*) AS dias_atencion,
        SUM(EXTRACT(EPOCH FROM (hora_fin - hora_inicio))/3600) AS horas_semanales
    FROM horario_atencion
    WHERE estado = 'ACTIVO'
    GROUP BY id_medico
)
SELECT 
    cm.medico_nombre,
    cm.total_citas,
    cm.atendidas,
    cm.canceladas,
    cm.no_presentados,
    ROUND(100.0 * cm.atendidas / NULLIF(cm.total_citas, 0), 2) AS tasa_atencion,
    hm.dias_atencion,
    ROUND(hm.horas_semanales, 2) AS horas_semanales,
    ROUND(cm.atendidas::NUMERIC / NULLIF(hm.horas_semanales, 0), 2) AS citas_por_hora
FROM citas_medico cm
LEFT JOIN horarios_medico hm ON cm.id_medico = hm.id_medico
ORDER BY cm.atendidas DESC;

-- Análisis de pacientes frecuentes vs esporádicos
WITH clasificacion_pacientes AS (
    SELECT 
        p.id_paciente,
        CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente_nombre,
        COUNT(c.id_cita) AS total_citas,
        MIN(c.fecha_cita) AS primera_cita,
        MAX(c.fecha_cita) AS ultima_cita,
        CASE 
            WHEN COUNT(c.id_cita) >= 5 THEN 'FRECUENTE'
            WHEN COUNT(c.id_cita) BETWEEN 2 AND 4 THEN 'REGULAR'
            WHEN COUNT(c.id_cita) = 1 THEN 'ESPORADICO'
            ELSE 'SIN_CITAS'
        END AS clasificacion
    FROM paciente p
    LEFT JOIN cita c ON p.id_paciente = c.id_paciente
    WHERE p.estado = 'ACTIVO'
    GROUP BY p.id_paciente, p.nombres, p.apellido_paterno
)
SELECT 
    clasificacion,
    COUNT(*) AS cantidad_pacientes,
    ROUND(AVG(total_citas), 2) AS promedio_citas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM clasificacion_pacientes
GROUP BY clasificacion
ORDER BY 
    CASE clasificacion
        WHEN 'FRECUENTE' THEN 1
        WHEN 'REGULAR' THEN 2
        WHEN 'ESPORADICO' THEN 3
        WHEN 'SIN_CITAS' THEN 4
    END;

-- ===========================================
-- 3. ANÁLISIS TEMPORAL AVANZADO
-- ===========================================

-- Proyección de demanda por día de la semana y hora
WITH demanda_historica AS (
    SELECT 
        TO_CHAR(fecha_cita, 'Day') AS dia_semana,
        EXTRACT(DOW FROM fecha_cita) AS dia_numero,
        EXTRACT(HOUR FROM hora_inicio) AS hora,
        COUNT(*) AS cantidad_citas
    FROM cita
    WHERE fecha_cita >= CURRENT_DATE - INTERVAL '3 months'
      AND fecha_cita < CURRENT_DATE
    GROUP BY TO_CHAR(fecha_cita, 'Day'), EXTRACT(DOW FROM fecha_cita), EXTRACT(HOUR FROM hora_inicio)
)
SELECT 
    dia_semana,
    hora,
    ROUND(AVG(cantidad_citas), 2) AS promedio_citas,
    MIN(cantidad_citas) AS minimo,
    MAX(cantidad_citas) AS maximo,
    ROUND(STDDEV(cantidad_citas), 2) AS desviacion_estandar
FROM demanda_historica
GROUP BY dia_semana, dia_numero, hora
ORDER BY dia_numero, hora;

-- Identificar slots horarios más y menos demandados
WITH slots_horarios AS (
    SELECT 
        ha.id_medico,
        ha.dia_semana,
        ha.hora_inicio,
        ha.hora_fin,
        e.nombre AS especialidad,
        COUNT(c.id_cita) AS citas_reservadas,
        ROUND(EXTRACT(EPOCH FROM (ha.hora_fin - ha.hora_inicio)) / (ha.duracion_cita * 60), 0) AS capacidad_maxima
    FROM horario_atencion ha
    INNER JOIN especialidad e ON ha.id_especialidad = e.id_especialidad
    LEFT JOIN cita c ON ha.id_medico = c.id_medico 
        AND TO_CHAR(c.fecha_cita, 'Day') = ha.dia_semana
        AND c.hora_inicio >= ha.hora_inicio 
        AND c.hora_fin <= ha.hora_fin
        AND c.fecha_cita >= CURRENT_DATE
        AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
    WHERE ha.estado = 'ACTIVO'
    GROUP BY ha.id_medico, ha.dia_semana, ha.hora_inicio, ha.hora_fin, e.nombre, ha.duracion_cita
)
SELECT 
    dia_semana,
    TO_CHAR(hora_inicio, 'HH24:MI') || ' - ' || TO_CHAR(hora_fin, 'HH24:MI') AS horario,
    especialidad,
    citas_reservadas,
    capacidad_maxima,
    ROUND(100.0 * citas_reservadas / NULLIF(capacidad_maxima, 0), 2) AS porcentaje_ocupacion,
    CASE 
        WHEN ROUND(100.0 * citas_reservadas / NULLIF(capacidad_maxima, 0), 2) >= 80 THEN 'ALTA DEMANDA'
        WHEN ROUND(100.0 * citas_reservadas / NULLIF(capacidad_maxima, 0), 2) >= 50 THEN 'DEMANDA MEDIA'
        ELSE 'BAJA DEMANDA'
    END AS nivel_demanda
FROM slots_horarios
ORDER BY porcentaje_ocupacion DESC;

-- ===========================================
-- 4. ANÁLISIS DE COHORTES
-- ===========================================

-- Retención de pacientes por mes de registro
WITH pacientes_cohorte AS (
    SELECT 
        p.id_paciente,
        DATE_TRUNC('month', p.fecha_registro) AS mes_registro,
        DATE_TRUNC('month', c.fecha_cita) AS mes_cita
    FROM paciente p
    LEFT JOIN cita c ON p.id_paciente = c.id_paciente
    WHERE p.fecha_registro >= CURRENT_DATE - INTERVAL '12 months'
),
cohorte_actividad AS (
    SELECT 
        TO_CHAR(mes_registro, 'YYYY-MM') AS cohorte,
        EXTRACT(MONTH FROM AGE(mes_cita, mes_registro)) AS meses_desde_registro,
        COUNT(DISTINCT id_paciente) AS pacientes_activos
    FROM pacientes_cohorte
    WHERE mes_cita IS NOT NULL
    GROUP BY mes_registro, EXTRACT(MONTH FROM AGE(mes_cita, mes_registro))
)
SELECT 
    cohorte,
    meses_desde_registro,
    pacientes_activos,
    LAG(pacientes_activos, 1) OVER (PARTITION BY cohorte ORDER BY meses_desde_registro) AS mes_anterior,
    ROUND(100.0 * pacientes_activos / 
          FIRST_VALUE(pacientes_activos) OVER (PARTITION BY cohorte ORDER BY meses_desde_registro), 2) AS tasa_retencion
FROM cohorte_actividad
WHERE meses_desde_registro BETWEEN 0 AND 6
ORDER BY cohorte DESC, meses_desde_registro;

-- ===========================================
-- 5. DETECCIÓN DE PATRONES ANÓMALOS
-- ===========================================

-- Identificar médicos con alta tasa de cancelación
WITH estadisticas_medico AS (
    SELECT 
        m.id_medico,
        CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
        COUNT(c.id_cita) AS total_citas,
        COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS cancelaciones,
        ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) / 
              NULLIF(COUNT(c.id_cita), 0), 2) AS tasa_cancelacion,
        ROUND(AVG(COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END)) OVER() / 
              NULLIF(AVG(COUNT(c.id_cita)) OVER(), 0) * 100, 2) AS tasa_promedio_sistema
    FROM medico m
    LEFT JOIN cita c ON m.id_medico = c.id_medico
    LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
    WHERE m.estado = 'ACTIVO'
    GROUP BY m.id_medico, m.nombres, m.apellido_paterno
    HAVING COUNT(c.id_cita) >= 5
)
SELECT 
    medico,
    total_citas,
    cancelaciones,
    tasa_cancelacion,
    tasa_promedio_sistema,
    CASE 
        WHEN tasa_cancelacion > tasa_promedio_sistema * 1.5 THEN 'ALERTA'
        WHEN tasa_cancelacion > tasa_promedio_sistema * 1.2 THEN 'ATENCIÓN'
        ELSE 'NORMAL'
    END AS estado_alerta
FROM estadisticas_medico
WHERE tasa_cancelacion > tasa_promedio_sistema
ORDER BY tasa_cancelacion DESC;

-- Pacientes con patrón de múltiples inasistencias
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    p.dni,
    p.email,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS total_inasistencias,
    COUNT(c.id_cita) AS total_citas,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) / 
          NULLIF(COUNT(c.id_cita), 0), 2) AS tasa_inasistencia,
    MAX(c.fecha_cita) FILTER (WHERE ec.codigo = 'NO_PRESENTADO') AS ultima_inasistencia
FROM paciente p
INNER JOIN cita c ON p.id_paciente = c.id_paciente
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE p.estado = 'ACTIVO'
  AND c.fecha_cita < CURRENT_DATE
GROUP BY p.id_paciente, p.nombres, p.apellido_paterno, p.dni, p.email
HAVING COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) >= 2
ORDER BY tasa_inasistencia DESC, total_inasistencias DESC;

-- ===========================================
-- 6. REPORTES EJECUTIVOS
-- ===========================================

-- Dashboard ejecutivo completo
SELECT 
    'RESUMEN GENERAL' AS seccion,
    NULL::TEXT AS metrica,
    NULL::NUMERIC AS valor,
    NULL::TEXT AS observacion
UNION ALL
SELECT 
    'Pacientes',
    'Total Activos',
    COUNT(*)::NUMERIC,
    'Registrados en sistema'
FROM paciente WHERE estado = 'ACTIVO'
UNION ALL
SELECT 
    'Médicos',
    'Total Activos',
    COUNT(*)::NUMERIC,
    'Disponibles para atención'
FROM medico WHERE estado = 'ACTIVO'
UNION ALL
SELECT 
    'Citas',
    'Total Programadas',
    COUNT(*)::NUMERIC,
    'Próximos 30 días'
FROM cita 
WHERE fecha_cita BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
  AND id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
UNION ALL
SELECT 
    'Ocupación',
    'Tasa Promedio',
    ROUND(AVG(ocupacion), 2),
    'Últimos 30 días'
FROM (
    SELECT 
        DATE(fecha_cita) AS fecha,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM horario_atencion WHERE estado = 'ACTIVO'), 2) AS ocupacion
    FROM cita
    WHERE fecha_cita >= CURRENT_DATE - INTERVAL '30 days'
      AND fecha_cita < CURRENT_DATE
    GROUP BY DATE(fecha_cita)
) AS ocupacion_diaria
UNION ALL
SELECT 
    'Satisfacción',
    'Tasa de Atención',
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) / NULLIF(COUNT(*), 0), 2),
    'Últimos 3 meses'
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita >= CURRENT_DATE - INTERVAL '3 months'
  AND c.fecha_cita < CURRENT_DATE;

-- ===========================================
-- 7. OPTIMIZACIÓN Y RECOMENDACIONES
-- ===========================================

-- Identificar horarios con baja ocupación para redistribución
WITH ocupacion_horarios AS (
    SELECT 
        m.id_medico,
        CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
        ha.dia_semana,
        TO_CHAR(ha.hora_inicio, 'HH24:MI') || ' - ' || TO_CHAR(ha.hora_fin, 'HH24:MI') AS horario,
        e.nombre AS especialidad,
        COUNT(c.id_cita) AS citas_reservadas,
        ROUND(EXTRACT(EPOCH FROM (ha.hora_fin - ha.hora_inicio)) / (ha.duracion_cita * 60), 0) AS capacidad,
        ROUND(100.0 * COUNT(c.id_cita) / 
              NULLIF(ROUND(EXTRACT(EPOCH FROM (ha.hora_fin - ha.hora_inicio)) / (ha.duracion_cita * 60), 0), 0), 2) AS ocupacion
    FROM medico m
    INNER JOIN horario_atencion ha ON m.id_medico = ha.id_medico
    INNER JOIN especialidad e ON ha.id_especialidad = e.id_especialidad
    LEFT JOIN cita c ON ha.id_medico = c.id_medico 
        AND TO_CHAR(c.fecha_cita, 'Day') = ha.dia_semana
        AND c.hora_inicio >= ha.hora_inicio 
        AND c.hora_fin <= ha.hora_fin
        AND c.fecha_cita >= CURRENT_DATE - INTERVAL '60 days'
        AND c.fecha_cita < CURRENT_DATE
        AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA', 'ATENDIDA'))
    WHERE ha.estado = 'ACTIVO'
    GROUP BY m.id_medico, m.nombres, m.apellido_paterno, ha.dia_semana, ha.hora_inicio, ha.hora_fin, e.nombre, ha.duracion_cita
)
SELECT 
    medico,
    dia_semana,
    horario,
    especialidad,
    citas_reservadas,
    capacidad,
    ocupacion,
    CASE 
        WHEN ocupacion < 30 THEN 'CONSIDERAR REDISTRIBUCIÓN'
        WHEN ocupacion < 50 THEN 'BAJA OCUPACIÓN'
        WHEN ocupacion < 80 THEN 'OCUPACIÓN NORMAL'
        ELSE 'ALTA DEMANDA'
    END AS recomendacion
FROM ocupacion_horarios
WHERE ocupacion < 50
ORDER BY ocupacion ASC, medico;