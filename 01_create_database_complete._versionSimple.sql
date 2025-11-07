-- =============================================
-- SISTEMA DE RESERVA DE CONSULTAS MÉDICAS EXTERNAS
-- Universidad Nacional de Ingeniería (UNI)
-- Proyecto: Construcción de Software I
-- Autor: FRANZ JOE INGA CHAMPI
-- Fecha: Octubre 2025
-- Motor: PostgreSQL 15
-- =============================================

-- =============================================
-- PASO 1: CREAR BASE DE DATOS
-- =============================================
-- Ejecutar este comando desde psql o pgAdmin:
-- CREATE DATABASE sistema_consultas_medicas
--     WITH 
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'es_PE.UTF-8'
--     LC_CTYPE = 'es_PE.UTF-8'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- =============================================
-- CONECTARSE A LA BASE DE DATOS
-- =============================================
-- \c sistema_consultas_medicas

-- =============================================
-- PASO 2: ELIMINAR TABLAS SI EXISTEN (para recrear)
-- =============================================
DROP TABLE IF EXISTS notificacion CASCADE;
DROP TABLE IF EXISTS cita CASCADE;
DROP TABLE IF EXISTS estado_cita CASCADE;
DROP TABLE IF EXISTS horario_atencion CASCADE;
DROP TABLE IF EXISTS medico CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;
DROP TABLE IF EXISTS consultorio CASCADE;
DROP TABLE IF EXISTS especialidad CASCADE;
DROP TABLE IF EXISTS piso CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;

-- =============================================
-- PASO 3: CREAR EXTENSIONES NECESARIAS
-- =============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- TABLA: piso
-- =============================================
CREATE TABLE piso (
    id_piso SERIAL PRIMARY KEY,
    numero INTEGER NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE piso IS 'Pisos del hospital donde se ubican los consultorios';
COMMENT ON COLUMN piso.numero IS 'Número del piso (ej: 1, 2, 3)';
COMMENT ON COLUMN piso.nombre IS 'Nombre descriptivo del piso (ej: Primer Piso, Segundo Piso)';

-- =============================================
-- TABLA: especialidad
-- =============================================
CREATE TABLE especialidad (
    id_especialidad SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE especialidad IS 'Especialidades médicas disponibles en el hospital';
COMMENT ON COLUMN especialidad.codigo IS 'Código único de la especialidad (ej: CARD, NEUR, PEDI)';

-- =============================================
-- TABLA: paciente
-- =============================================
CREATE TABLE paciente (
    id_paciente SERIAL PRIMARY KEY,
    dni VARCHAR(8) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F')),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    numero_seguro VARCHAR(20),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    CONSTRAINT chk_paciente_edad CHECK (fecha_nacimiento < CURRENT_DATE)
);

COMMENT ON TABLE paciente IS 'Información de pacientes registrados en el sistema';
COMMENT ON COLUMN paciente.dni IS 'Documento Nacional de Identidad (8 dígitos)';
COMMENT ON COLUMN paciente.sexo IS 'Sexo biológico: M = Masculino, F = Femenino';
COMMENT ON COLUMN paciente.numero_seguro IS 'Número de seguro médico si aplica';

-- =============================================
-- TABLA: medico
-- =============================================
CREATE TABLE medico (
    id_medico SERIAL PRIMARY KEY,
    id_especialidad INTEGER NOT NULL,
    codigo_medico VARCHAR(20) NOT NULL UNIQUE,
    numero_colegiatura VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    observaciones TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    CONSTRAINT fk_medico_especialidad FOREIGN KEY (id_especialidad) 
        REFERENCES especialidad(id_especialidad) ON DELETE RESTRICT
); 
 
COMMENT ON TABLE medico IS 'Información de médicos del hospital';
COMMENT ON COLUMN medico.codigo_medico IS 'Código interno del médico en el hospital';
COMMENT ON COLUMN medico.numero_colegiatura IS 'Número de colegiatura profesional (CMP)';

-- =============================================
-- TABLA: consultorio
-- =============================================
CREATE TABLE consultorio (
    id_consultorio SERIAL PRIMARY KEY,
    id_piso INTEGER NOT NULL,
    numero VARCHAR(10) NOT NULL,
    nombre VARCHAR(100),
    ubicacion VARCHAR(200),
    capacidad INTEGER NOT NULL DEFAULT 1,
    equipamiento TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_consultorio_piso FOREIGN KEY (id_piso) 
        REFERENCES piso(id_piso) ON DELETE RESTRICT,
    CONSTRAINT uq_consultorio_numero_piso UNIQUE (numero, id_piso)
);

COMMENT ON TABLE consultorio IS 'Consultorios del hospital';
COMMENT ON COLUMN consultorio.capacidad IS 'Capacidad de personas en el consultorio';
COMMENT ON COLUMN consultorio.equipamiento IS 'Descripción del equipamiento médico disponible';

-- =============================================
-- TABLA: horario_atencion
-- =============================================
CREATE TABLE horario_atencion (
    id_horario SERIAL PRIMARY KEY,
    id_medico INTEGER NOT NULL,
    id_consultorio INTEGER NOT NULL,
    dia_semana INTEGER NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_cita INTEGER NOT NULL DEFAULT 30,
    cupos_maximos INTEGER NOT NULL DEFAULT 10,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    CONSTRAINT fk_horario_medico FOREIGN KEY (id_medico) 
        REFERENCES medico(id_medico) ON DELETE CASCADE,
    CONSTRAINT fk_horario_consultorio FOREIGN KEY (id_consultorio) 
        REFERENCES consultorio(id_consultorio) ON DELETE RESTRICT,
    CONSTRAINT chk_horario_horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT chk_duracion_positiva CHECK (duracion_cita > 0),
    CONSTRAINT uq_horario_medico_dia UNIQUE (id_medico, dia_semana, hora_inicio)
);

COMMENT ON TABLE horario_atencion IS 'Horarios de atención configurados por cada médico';
COMMENT ON COLUMN horario_atencion.dia_semana IS 'Día de la semana: 1=Lunes, 2=Martes, ..., 7=Domingo';
COMMENT ON COLUMN horario_atencion.duracion_cita IS 'Duración de cada cita en minutos';
COMMENT ON COLUMN horario_atencion.cupos_maximos IS 'Cantidad máxima de citas para ese horario';

-- =============================================
-- TABLA: estado_cita (Lookup Table)
-- =============================================
CREATE TABLE estado_cita (
    id_estado SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    color VARCHAR(7) DEFAULT '#000000',
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE estado_cita IS 'Estados posibles de una cita médica (tabla lookup)';
COMMENT ON COLUMN estado_cita.color IS 'Color hexadecimal para UI (ej: #28a745 para verde)';

-- =============================================
-- TABLA: cita
-- =============================================
CREATE TABLE cita (
    id_cita SERIAL PRIMARY KEY,
    id_paciente INTEGER NOT NULL,
    id_medico INTEGER NOT NULL,
    id_consultorio INTEGER NOT NULL,
    id_estado INTEGER NOT NULL DEFAULT 1,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    motivo_consulta TEXT,
    observaciones TEXT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    fecha_cancelacion TIMESTAMP,
    motivo_cancelacion TEXT,
    CONSTRAINT fk_cita_paciente FOREIGN KEY (id_paciente) 
        REFERENCES paciente(id_paciente) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_medico FOREIGN KEY (id_medico) 
        REFERENCES medico(id_medico) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_consultorio FOREIGN KEY (id_consultorio) 
        REFERENCES consultorio(id_consultorio) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_estado FOREIGN KEY (id_estado) 
        REFERENCES estado_cita(id_estado) ON DELETE RESTRICT,
    CONSTRAINT chk_fecha_futura CHECK (fecha_cita >= CURRENT_DATE),
    CONSTRAINT uq_cita_paciente_fecha UNIQUE (id_paciente, fecha_cita, hora_cita)
);

COMMENT ON TABLE cita IS 'Reservas de citas médicas realizadas por pacientes';
COMMENT ON COLUMN cita.motivo_consulta IS 'Razón por la cual el paciente solicita la cita';
COMMENT ON COLUMN cita.fecha_cancelacion IS 'Fecha en que se canceló la cita (si aplica)';

-- =============================================
-- TABLA: notificacion
-- =============================================
CREATE TABLE notificacion (
    id_notificacion SERIAL PRIMARY KEY,
    id_cita INTEGER NOT NULL,
    tipo_notificacion VARCHAR(50) NOT NULL,
    destinatario VARCHAR(100) NOT NULL,
    asunto VARCHAR(200),
    mensaje TEXT NOT NULL,
    fecha_envio TIMESTAMP,
    enviado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notificacion_cita FOREIGN KEY (id_cita) 
        REFERENCES cita(id_cita) ON DELETE CASCADE,
    CONSTRAINT chk_tipo_notificacion CHECK (tipo_notificacion IN ('EMAIL', 'SMS', 'PUSH', 'ALERTA'))
);

COMMENT ON TABLE notificacion IS 'Notificaciones enviadas a pacientes y médicos';
COMMENT ON COLUMN notificacion.tipo_notificacion IS 'Tipo: EMAIL, SMS, PUSH, ALERTA';
COMMENT ON COLUMN notificacion.destinatario IS 'Email o teléfono del destinatario';

-- =============================================
-- TABLA: usuario (para autenticación)
-- =============================================
CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('PACIENTE', 'MEDICO', 'ADMIN')),
    id_referencia INTEGER,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acceso TIMESTAMP,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP
);

COMMENT ON TABLE usuario IS 'Usuarios del sistema para autenticación';
COMMENT ON COLUMN usuario.id_referencia IS 'ID del paciente o médico según el rol';
COMMENT ON COLUMN usuario.password_hash IS 'Contraseña encriptada con bcrypt';

-- =============================================
-- PASO 4: CREAR ÍNDICES PARA OPTIMIZAR CONSULTAS
-- =============================================

-- Índices para búsquedas frecuentes
CREATE INDEX idx_paciente_dni ON paciente(dni);
CREATE INDEX idx_paciente_email ON paciente(email);
CREATE INDEX idx_medico_especialidad ON medico(id_especialidad);
CREATE INDEX idx_medico_codigo ON medico(codigo_medico);
CREATE INDEX idx_cita_paciente ON cita(id_paciente);
CREATE INDEX idx_cita_medico ON cita(id_medico);
CREATE INDEX idx_cita_fecha ON cita(fecha_cita);
CREATE INDEX idx_cita_estado ON cita(id_estado);
CREATE INDEX idx_horario_medico ON horario_atencion(id_medico);
CREATE INDEX idx_horario_dia ON horario_atencion(dia_semana);
CREATE INDEX idx_notificacion_enviado ON notificacion(enviado);
CREATE INDEX idx_usuario_username ON usuario(username);

-- Índices compuestos para consultas complejas
CREATE INDEX idx_cita_medico_fecha ON cita(id_medico, fecha_cita);
CREATE INDEX idx_cita_paciente_fecha ON cita(id_paciente, fecha_cita);
CREATE INDEX idx_horario_medico_dia ON horario_atencion(id_medico, dia_semana);

-- =============================================
-- PASO 5: INSERTAR DATOS INICIALES (LOOKUP)
-- =============================================

-- Estados de cita
INSERT INTO estado_cita (codigo, nombre, descripcion, color) VALUES
('PEND', 'Pendiente', 'Cita reservada pero no confirmada', '#ffc107'),
('CONF', 'Confirmada', 'Cita confirmada por el sistema', '#28a745'),
('ATEN', 'Atendida', 'Paciente fue atendido', '#17a2b8'),
('CANC', 'Cancelada', 'Cita cancelada por paciente o médico', '#dc3545'),
('NOAS', 'No Asistió', 'Paciente no se presentó a la cita', '#6c757d');

-- Pisos del hospital
INSERT INTO piso (numero, nombre, descripcion) VALUES
(1, 'Primer Piso', 'Consultorio de medicina general y pediatría'),
(2, 'Segundo Piso', 'Consultorios de especialidades'),
(3, 'Tercer Piso', 'Consultorios de cirugía y traumatología');

-- Especialidades médicas
INSERT INTO especialidad (codigo, nombre, descripcion) VALUES
('CARD', 'Cardiología', 'Especialidad médica del corazón y sistema cardiovascular'),
('NEUR', 'Neurología', 'Especialidad médica del sistema nervioso'),
('PEDI', 'Pediatría', 'Especialidad médica infantil'),
('GINE', 'Ginecología', 'Especialidad médica de la mujer'),
('DERM', 'Dermatología', 'Especialidad médica de la piel'),
('TRAU', 'Traumatología', 'Especialidad médica de lesiones músculo-esqueléticas'),
('OFTA', 'Oftalmología', 'Especialidad médica de los ojos'),
('ONCO', 'Oncología', 'Especialidad médica del cáncer'),
('PSIQ', 'Psiquiatría', 'Especialidad médica de salud mental'),
('MGEN', 'Medicina General', 'Atención médica general');

-- Consultorios
INSERT INTO consultorio (id_piso, numero, nombre, ubicacion, capacidad) VALUES
(1, '101', 'Consultorio Medicina General 1', 'Ala A, Primer Piso', 2),
(1, '102', 'Consultorio Pediatría 1', 'Ala A, Primer Piso', 3),
(2, '201', 'Consultorio Cardiología', 'Ala B, Segundo Piso', 2),
(2, '202', 'Consultorio Neurología', 'Ala B, Segundo Piso', 2),
(2, '203', 'Consultorio Ginecología', 'Ala B, Segundo Piso', 2),
(3, '301', 'Consultorio Traumatología', 'Ala C, Tercer Piso', 2),
(3, '302', 'Consultorio Dermatología', 'Ala C, Tercer Piso', 2);

-- =============================================
-- PASO 6: DATOS DE PRUEBA
-- =============================================

-- Pacientes de prueba
INSERT INTO paciente (dni, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, sexo, telefono, email, direccion) VALUES
('12345678', 'Juan Carlos', 'Pérez', 'García', '1990-05-15', 'M', '987654321', 'juan.perez@email.com', 'Av. Universitaria 123, Lima'),
('23456789', 'María Elena', 'López', 'Torres', '1985-08-20', 'F', '987654322', 'maria.lopez@email.com', 'Jr. Los Olivos 456, Lima'),
('34567890', 'Pedro Luis', 'Rodríguez', 'Silva', '1995-03-10', 'M', '987654323', 'pedro.rodriguez@email.com', 'Av. La Marina 789, Callao');

-- Médicos de prueba
INSERT INTO medico (id_especialidad, codigo_medico, numero_colegiatura, nombres, apellido_paterno, apellido_materno, telefono, email) VALUES
(1, 'MED001', 'CMP12345', 'Roberto', 'Sánchez', 'Díaz', '999111222', 'roberto.sanchez@hospital.com'),
(3, 'MED002', 'CMP23456', 'Ana María', 'Flores', 'Vega', '999222333', 'ana.flores@hospital.com'),
(2, 'MED003', 'CMP34567', 'Carlos Alberto', 'Mendoza', 'Ruiz', '999333444', 'carlos.mendoza@hospital.com');

-- Horarios de atención (Lunes a Viernes de 8am a 12pm)
INSERT INTO horario_atencion (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, duracion_cita, cupos_maximos) VALUES
-- Dr. Sánchez (Cardiólogo) - Lunes a Viernes
(1, 3, 1, '08:00', '12:00', 30, 8),
(1, 3, 2, '08:00', '12:00', 30, 8),
(1, 3, 3, '08:00', '12:00', 30, 8),
(1, 3, 4, '08:00', '12:00', 30, 8),
(1, 3, 5, '08:00', '12:00', 30, 8),
-- Dra. Flores (Pediatra) - Lunes, Miércoles, Viernes
(2, 2, 1, '14:00', '18:00', 20, 12),
(2, 2, 3, '14:00', '18:00', 20, 12),
(2, 2, 5, '14:00', '18:00', 20, 12),
-- Dr. Mendoza (Neurólogo) - Martes y Jueves
(3, 4, 2, '09:00', '13:00', 45, 6),
(3, 4, 4, '09:00', '13:00', 45, 6);

-- Usuarios del sistema (contraseña: 'password123' hasheada con bcrypt)
-- En producción, las contraseñas DEBEN ser hasheadas con bcrypt
INSERT INTO usuario (username, password_hash, rol, id_referencia) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', NULL),
('juan.perez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'PACIENTE', 1),
('maria.lopez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'PACIENTE', 2),
('roberto.sanchez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MEDICO', 1),
('ana.flores', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MEDICO', 2);

-- Citas de prueba
INSERT INTO cita (id_paciente, id_medico, id_consultorio, id_estado, fecha_cita, hora_cita, motivo_consulta) VALUES
(1, 1, 3, 2, CURRENT_DATE + 1, '09:00', 'Control de presión arterial'),
(2, 2, 2, 2, CURRENT_DATE + 2, '15:00', 'Control pediátrico de rutina'),
(3, 3, 4, 1, CURRENT_DATE + 3, '10:00', 'Dolor de cabeza frecuente');

-- =============================================
-- FIN DEL SCRIPT
-- =============================================

-- Verificar instalación
SELECT 'Base de datos creada exitosamente!' AS status;
SELECT COUNT(*) AS total_especialidades FROM especialidad;
SELECT COUNT(*) AS total_consultorios FROM consultorio;
SELECT COUNT(*) AS total_medicos FROM medico;
SELECT COUNT(*) AS total_pacientes FROM paciente;
SELECT COUNT(*) AS total_citas FROM cita;

-----------------------------------------