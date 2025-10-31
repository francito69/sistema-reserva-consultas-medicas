-- ============================================
-- Script: 07_create_functions.sql
-- Descripción: Crear funciones almacenadas
-- ============================================

-- Función: Generar código único de cita
CREATE OR REPLACE FUNCTION fn_generar_codigo_cita()
RETURNS VARCHAR(20) AS $$
DECLARE
    nuevo_codigo VARCHAR(20);
    año_actual VARCHAR(4);
    contador INTEGER;
BEGIN
    año_actual := TO_CHAR(CURRENT_DATE, 'YYYY');
    
    SELECT COALESCE(MAX(CAST(SUBSTRING(codigo_cita FROM 11) AS INTEGER)), 0) + 1
    INTO contador
    FROM cita
    WHERE codigo_cita LIKE 'CITA-' || año_actual || '-%';
    
    nuevo_codigo := 'CITA-' || año_actual || '-' || LPAD(contador::TEXT, 4, '0');
    
    RETURN nuevo_codigo;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_generar_codigo_cita() 
    IS 'Genera código único de cita en formato CITA-YYYY-NNNN';

-- Función: Calcular edad desde fecha de nacimiento
CREATE OR REPLACE FUNCTION fn_calcular_edad(fecha_nac DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(fecha_nac));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Función: Validar disponibilidad de horario
CREATE OR REPLACE FUNCTION fn_validar_disponibilidad_horario(
    p_id_medico INTEGER,
    p_fecha DATE,
    p_hora_inicio TIME,
    p_hora_fin TIME
) RETURNS BOOLEAN AS $$
DECLARE
    conflictos INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO conflictos
    FROM cita
    WHERE id_medico = p_id_medico
      AND fecha_cita = p_fecha
      AND id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
      AND (
          (hora_inicio <= p_hora_inicio AND hora_fin > p_hora_inicio)
          OR
          (hora_inicio < p_hora_fin AND hora_fin >= p_hora_fin)
          OR
          (hora_inicio >= p_hora_inicio AND hora_fin <= p_hora_fin)
      );
    
    RETURN conflictos = 0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_disponibilidad_horario 
    IS 'Valida si un médico está disponible en un horario específico';

-- Función: Obtener próximas citas de un paciente
CREATE OR REPLACE FUNCTION fn_proximas_citas_paciente(p_id_paciente INTEGER)
RETURNS TABLE (
    codigo_cita VARCHAR,
    fecha_cita DATE,
    hora_inicio TIME,
    medico_nombre VARCHAR,
    especialidad VARCHAR,
    consultorio VARCHAR,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.codigo_cita,
        c.fecha_cita,
        c.hora_inicio,
        CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno)::VARCHAR,
        e.nombre::VARCHAR,
        co.nombre::VARCHAR,
        ec.nombre::VARCHAR
    FROM cita c
    INNER JOIN medico m ON c.id_medico = m.id_medico
    INNER JOIN especialidad e ON c.id_especialidad = e.id_especialidad
    INNER JOIN consultorio co ON c.id_consultorio = co.id_consultorio
    INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
    WHERE c.id_paciente = p_id_paciente
      AND c.fecha_cita >= CURRENT_DATE
      AND ec.codigo IN ('PENDIENTE', 'CONFIRMADA')
    ORDER BY c.fecha_cita, c.hora_inicio;
END;
$$ LANGUAGE plpgsql;

-- Función: Contar citas pendientes de un paciente
CREATE OR REPLACE FUNCTION fn_contar_citas_pendientes(p_id_paciente INTEGER)
RETURNS INTEGER AS $$
DECLARE
    cantidad INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO cantidad
    FROM cita c
    INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
    WHERE c.id_paciente = p_id_paciente
      AND ec.codigo IN ('PENDIENTE', 'CONFIRMADA')
      AND c.fecha_cita >= CURRENT_DATE;
    
    RETURN cantidad;
END;
$$ LANGUAGE plpgsql;

-- Listar funciones creadas
SELECT 
    routine_name,
    routine_type,
    data_type AS return_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;