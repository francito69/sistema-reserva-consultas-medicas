-- ============================================
-- Script: 05_create_associative_tables.sql
-- Descripción: Crear tablas asociativas y CITA
-- ============================================

-- Tabla: MEDICO_ESPECIALIDAD (N:M)
CREATE TABLE IF NOT EXISTS medico_especialidad (
    id_medico_especialidad SERIAL PRIMARY KEY,
    id_medico INTEGER NOT NULL,
    id_especialidad INTEGER NOT NULL,
    fecha_certificacion DATE,
    institucion_certificadora VARCHAR(200),
    CONSTRAINT fk_medico_esp_medico FOREIGN KEY (id_medico) 
        REFERENCES medico(id_medico) ON DELETE CASCADE,
    CONSTRAINT fk_medico_esp_especialidad FOREIGN KEY (id_especialidad) 
        REFERENCES especialidad(id_especialidad) ON DELETE RESTRICT,
    CONSTRAINT uk_medico_especialidad UNIQUE (id_medico, id_especialidad)
);

COMMENT ON TABLE medico_especialidad IS 'Relación N:M entre médicos y especialidades';

-- Tabla: HORARIO_ATENCION
CREATE TABLE IF NOT EXISTS horario_atencion (
    id_horario SERIAL PRIMARY KEY,
    id_medico INTEGER NOT NULL,
    id_consultorio INTEGER NOT NULL,
    id_especialidad INTEGER NOT NULL,
    dia_semana VARCHAR(10) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_cita INTEGER NOT NULL DEFAULT 30,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_horario_medico FOREIGN KEY (id_medico) 
        REFERENCES medico(id_medico) ON DELETE CASCADE,
    CONSTRAINT fk_horario_consultorio FOREIGN KEY (id_consultorio) 
        REFERENCES consultorio(id_consultorio) ON DELETE RESTRICT,
    CONSTRAINT fk_horario_especialidad FOREIGN KEY (id_especialidad) 
        REFERENCES especialidad(id_especialidad) ON DELETE RESTRICT,
    CONSTRAINT chk_horario_dia CHECK (dia_semana IN ('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO')),
    CONSTRAINT chk_horario_horas CHECK (hora_inicio < hora_fin),
    CONSTRAINT chk_horario_duracion CHECK (duracion_cita > 0 AND duracion_cita <= 120)
);

COMMENT ON TABLE horario_atencion IS 'Horarios de atención de médicos';
COMMENT ON COLUMN horario_atencion.duracion_cita IS 'Duración de cada cita en minutos';

-- Tabla: CITA
CREATE TABLE IF NOT EXISTS cita (
    id_cita SERIAL PRIMARY KEY,
    codigo_cita VARCHAR(20) UNIQUE NOT NULL,
    id_paciente INTEGER NOT NULL,
    id_medico INTEGER NOT NULL,
    id_consultorio INTEGER NOT NULL,
    id_especialidad INTEGER NOT NULL,
    id_estado INTEGER NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    motivo_consulta TEXT NOT NULL,
    observaciones TEXT,
    motivo_cancelacion TEXT,
    cancelado_por VARCHAR(20),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    recordatorio_enviado BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_cita_paciente FOREIGN KEY (id_paciente) 
        REFERENCES paciente(id_paciente) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_medico FOREIGN KEY (id_medico) 
        REFERENCES medico(id_medico) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_consultorio FOREIGN KEY (id_consultorio) 
        REFERENCES consultorio(id_consultorio) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_especialidad FOREIGN KEY (id_especialidad) 
        REFERENCES especialidad(id_especialidad) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_estado FOREIGN KEY (id_estado) 
        REFERENCES estado_cita(id_estado) ON DELETE RESTRICT,
    CONSTRAINT chk_cita_fecha CHECK (fecha_cita >= CURRENT_DATE),
    CONSTRAINT chk_cita_horas CHECK (hora_inicio < hora_fin),
    CONSTRAINT chk_cita_motivo CHECK (LENGTH(motivo_consulta) >= 10),
    CONSTRAINT chk_cita_cancelado CHECK (cancelado_por IN ('PACIENTE', 'MEDICO', 'SISTEMA') OR cancelado_por IS NULL),
    CONSTRAINT uk_cita_medico_horario UNIQUE (id_medico, fecha_cita, hora_inicio),
    CONSTRAINT uk_cita_consultorio_horario UNIQUE (id_consultorio, fecha_cita, hora_inicio)
);

COMMENT ON TABLE cita IS 'Reservas de consultas médicas';
COMMENT ON COLUMN cita.codigo_cita IS 'Código único generado para la cita (ej: CITA-2025-0001)';
COMMENT ON CONSTRAINT uk_cita_medico_horario ON cita IS 'Evita que un médico tenga dos citas simultáneas';
COMMENT ON CONSTRAINT uk_cita_consultorio_horario ON cita IS 'Evita que un consultorio tenga dos citas simultáneas';

-- Tabla: NOTIFICACION
CREATE TABLE IF NOT EXISTS notificacion (
    id_notificacion SERIAL PRIMARY KEY,
    id_cita INTEGER NOT NULL,
    tipo_notificacion VARCHAR(50) NOT NULL,
    destinatario_email VARCHAR(100) NOT NULL,
    destinatario_nombre VARCHAR(200) NOT NULL,
    asunto VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    estado_envio VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    fecha_envio TIMESTAMP,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    intentos_envio INTEGER DEFAULT 0,
    mensaje_error TEXT,
    CONSTRAINT fk_notificacion_cita FOREIGN KEY (id_cita) 
        REFERENCES cita(id_cita) ON DELETE CASCADE,
    CONSTRAINT chk_notificacion_tipo CHECK (tipo_notificacion IN ('CONFIRMACION', 'RECORDATORIO', 'CANCELACION')),
    CONSTRAINT chk_notificacion_estado CHECK (estado_envio IN ('ENVIADO', 'ERROR', 'PENDIENTE')),
    CONSTRAINT chk_notificacion_intentos CHECK (intentos_envio >= 0 AND intentos_envio <= 5)
);

COMMENT ON TABLE notificacion IS 'Registro de notificaciones enviadas';
COMMENT ON COLUMN notificacion.intentos_envio IS 'Número de intentos de envío realizados';

-- Crear índices para tablas asociativas
CREATE INDEX idx_medico_esp_medico ON medico_especialidad(id_medico);
CREATE INDEX idx_medico_esp_especialidad ON medico_especialidad(id_especialidad);

CREATE INDEX idx_horario_medico ON horario_atencion(id_medico);
CREATE INDEX idx_horario_consultorio ON horario_atencion(id_consultorio);
CREATE INDEX idx_horario_dia ON horario_atencion(dia_semana);
CREATE INDEX idx_horario_medico_dia ON horario_atencion(id_medico, dia_semana);

CREATE INDEX idx_cita_paciente ON cita(id_paciente);
CREATE INDEX idx_cita_medico ON cita(id_medico);
CREATE INDEX idx_cita_fecha ON cita(fecha_cita);
CREATE INDEX idx_cita_estado ON cita(id_estado);
CREATE INDEX idx_cita_codigo ON cita(codigo_cita);
CREATE INDEX idx_cita_medico_fecha ON cita(id_medico, fecha_cita);
CREATE INDEX idx_cita_recordatorio ON cita(recordatorio_enviado, fecha_cita) 
    WHERE recordatorio_enviado = FALSE;

CREATE INDEX idx_notificacion_cita ON notificacion(id_cita);
CREATE INDEX idx_notificacion_tipo ON notificacion(tipo_notificacion);
CREATE INDEX idx_notificacion_estado ON notificacion(estado_envio);

-- Verificar integridad referencial
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;