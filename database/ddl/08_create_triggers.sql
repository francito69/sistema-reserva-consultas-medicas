-- ============================================
-- Script: 08_create_triggers.sql
-- Descripción: Crear triggers del sistema
-- ============================================

-- Trigger: Generar código de cita automáticamente
CREATE OR REPLACE FUNCTION trg_fn_generar_codigo_cita()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.codigo_cita IS NULL OR NEW.codigo_cita = '' THEN
        NEW.codigo_cita := fn_generar_codigo_cita();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generar_codigo_cita
BEFORE INSERT ON cita
FOR EACH ROW
EXECUTE FUNCTION trg_fn_generar_codigo_cita();

-- Trigger: Validar límite de citas pendientes
CREATE OR REPLACE FUNCTION trg_fn_validar_limite_citas()
RETURNS TRIGGER AS $$
DECLARE
    cantidad_pendientes INTEGER;
BEGIN
    cantidad_pendientes := fn_contar_citas_pendientes(NEW.id_paciente);
    
    IF cantidad_pendientes >= 3 THEN
        RAISE EXCEPTION 'El paciente ya tiene % citas pendientes. Máximo permitido: 3', cantidad_pendientes;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_limite_citas
BEFORE INSERT ON cita
FOR EACH ROW
EXECUTE FUNCTION trg_fn_validar_limite_citas();

-- Trigger: Actualizar fecha_actualizacion en CITA
CREATE OR REPLACE FUNCTION trg_fn_actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_fecha_cita
BEFORE UPDATE ON cita
FOR EACH ROW
EXECUTE FUNCTION trg_fn_actualizar_fecha_modificacion();

-- Trigger: Insertar notificación al confirmar cita
CREATE OR REPLACE FUNCTION trg_fn_crear_notificacion_confirmacion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'CONFIRMADA') THEN
        -- Notificación al paciente
        INSERT INTO notificacion (
            id_cita, tipo_notificacion, destinatario_email, destinatario_nombre,
            asunto, mensaje, estado_envio
        )
        SELECT 
            NEW.id_cita,
            'CONFIRMACION',
            p.email,
            CONCAT(p.nombres, ' ', p.apellido_paterno),
            'Confirmación de Cita Médica - ' || NEW.codigo_cita,
            'Su cita ha sido confirmada exitosamente.',
            'PENDIENTE'
        FROM paciente p
        WHERE p.id_paciente = NEW.id_paciente;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notificacion_confirmacion
AFTER INSERT ON cita
FOR EACH ROW
EXECUTE FUNCTION trg_fn_crear_notificacion_confirmacion();

-- Trigger: Insertar notificación al cancelar cita
CREATE OR REPLACE FUNCTION trg_fn_crear_notificacion_cancelacion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'CANCELADA')
       AND OLD.id_estado != NEW.id_estado THEN
        
        INSERT INTO notificacion (
            id_cita, tipo_notificacion, destinatario_email, destinatario_nombre,
            asunto, mensaje, estado_envio
        )
        SELECT 
            NEW.id_cita,
            'CANCELACION',
            p.email,
            CONCAT(p.nombres, ' ', p.apellido_paterno),
            'Cita Médica Cancelada - ' || NEW.codigo_cita,
            'Su cita ha sido cancelada.',
            'PENDIENTE'
        FROM paciente p
        WHERE p.id_paciente = NEW.id_paciente;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notificacion_cancelacion
AFTER UPDATE ON cita
FOR EACH ROW
EXECUTE FUNCTION trg_fn_crear_notificacion_cancelacion();

-- Verificar triggers creados
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;