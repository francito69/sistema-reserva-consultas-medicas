-- ============================================
-- Script: 04_create_main_tables.sql
-- Descripción: Crear tablas principales
-- ============================================

-- Tabla: USUARIO
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP,
    CONSTRAINT chk_usuario_rol CHECK (rol IN ('PACIENTE', 'MEDICO', 'ADMIN')),
    CONSTRAINT chk_usuario_estado CHECK (estado IN ('ACTIVO', 'INACTIVO', 'BLOQUEADO')),
    CONSTRAINT chk_usuario_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

COMMENT ON TABLE usuario IS 'Cuentas de acceso al sistema';
COMMENT ON COLUMN usuario.contraseña IS 'Hash BCrypt de la contraseña';
COMMENT ON COLUMN usuario.rol IS 'Rol del usuario en el sistema';

-- Tabla: PACIENTE
CREATE TABLE IF NOT EXISTS paciente (
    id_paciente SERIAL PRIMARY KEY,
    dni CHAR(8) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL,
    direccion VARCHAR(200),
    email VARCHAR(100) UNIQUE NOT NULL,
    id_usuario INTEGER UNIQUE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_paciente_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_paciente_dni CHECK (dni ~ '^[0-9]{8}$'),
    CONSTRAINT chk_paciente_genero CHECK (genero IN ('M', 'F', 'O')),
    CONSTRAINT chk_paciente_fecha_nac CHECK (fecha_nacimiento < CURRENT_DATE),
    CONSTRAINT chk_paciente_edad CHECK (EXTRACT(YEAR FROM AGE(fecha_nacimiento)) BETWEEN 0 AND 120),
    CONSTRAINT chk_paciente_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

COMMENT ON TABLE paciente IS 'Información de pacientes registrados';
COMMENT ON COLUMN paciente.dni IS 'Documento Nacional de Identidad (8 dígitos)';

-- Tabla: PACIENTE_TELEFONO
CREATE TABLE IF NOT EXISTS paciente_telefono (
    id_telefono SERIAL PRIMARY KEY,
    id_paciente INTEGER NOT NULL,
    numero VARCHAR(15) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_telefono_paciente FOREIGN KEY (id_paciente) 
        REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    CONSTRAINT chk_telefono_tipo CHECK (tipo IN ('MOVIL', 'FIJO', 'TRABAJO')),
    CONSTRAINT chk_telefono_numero CHECK (numero ~ '^[0-9]{7,15}$')
);

COMMENT ON TABLE paciente_telefono IS 'Números telefónicos de pacientes';
COMMENT ON COLUMN paciente_telefono.es_principal IS 'Indica si es el número principal de contacto';

-- Tabla: MEDICO
CREATE TABLE IF NOT EXISTS medico (
    id_medico SERIAL PRIMARY KEY,
    dni CHAR(8) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    numero_colegiatura VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    id_usuario INTEGER UNIQUE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_medico_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_medico_dni CHECK (dni ~ '^[0-9]{8}$'),
    CONSTRAINT chk_medico_colegiatura CHECK (numero_colegiatura ~ '^CMP-[0-9]{5}$'),
    CONSTRAINT chk_medico_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_medico_telefono CHECK (telefono ~ '^[0-9]{7,15}$')
);

COMMENT ON TABLE medico IS 'Información de médicos registrados';
COMMENT ON COLUMN medico.numero_colegiatura IS 'Número de colegiatura médica CMP-XXXXX';

-- Crear índices para tablas principales
CREATE INDEX idx_usuario_email ON usuario(email);
CREATE INDEX idx_usuario_nombre ON usuario(nombre_usuario);
CREATE INDEX idx_usuario_rol ON usuario(rol);

CREATE INDEX idx_paciente_dni ON paciente(dni);
CREATE INDEX idx_paciente_email ON paciente(email);
CREATE INDEX idx_paciente_nombres ON paciente(nombres, apellido_paterno, apellido_materno);
CREATE INDEX idx_paciente_usuario ON paciente(id_usuario);

CREATE INDEX idx_telefono_paciente ON paciente_telefono(id_paciente);

CREATE INDEX idx_medico_dni ON medico(dni);
CREATE INDEX idx_medico_colegiatura ON medico(numero_colegiatura);
CREATE INDEX idx_medico_nombres ON medico(nombres, apellido_paterno);
CREATE INDEX idx_medico_usuario ON medico(id_usuario);

-- Verificar creación
SELECT tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;