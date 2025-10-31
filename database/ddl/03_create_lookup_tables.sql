-- ============================================
-- Script: 03_create_lookup_tables.sql
-- Descripción: Crear tablas de catálogo
-- ============================================

-- Tabla: ESTADO_CITA
CREATE TABLE IF NOT EXISTS estado_cita (
    id_estado SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    color VARCHAR(7),
    CONSTRAINT chk_estado_codigo CHECK (codigo ~ '^[A-Z_]+$')
);

COMMENT ON TABLE estado_cita IS 'Catálogo de estados posibles de una cita';
COMMENT ON COLUMN estado_cita.codigo IS 'Código único del estado (ej: PENDIENTE)';
COMMENT ON COLUMN estado_cita.color IS 'Color hexadecimal para UI (ej: #FF0000)';

-- Tabla: ESPECIALIDAD
CREATE TABLE IF NOT EXISTS especialidad (
    id_especialidad SERIAL PRIMARY KEY,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_especialidad_estado CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

COMMENT ON TABLE especialidad IS 'Catálogo de especialidades médicas';
COMMENT ON COLUMN especialidad.codigo IS 'Código único de la especialidad (ej: CARD-01)';

-- Tabla: CONSULTORIO
CREATE TABLE IF NOT EXISTS consultorio (
    id_consultorio SERIAL PRIMARY KEY,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    piso INTEGER NOT NULL,
    capacidad INTEGER DEFAULT 1,
    equipamiento TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT chk_consultorio_piso CHECK (piso BETWEEN -2 AND 20),
    CONSTRAINT chk_consultorio_capacidad CHECK (capacidad > 0),
    CONSTRAINT chk_consultorio_estado CHECK (estado IN ('ACTIVO', 'INACTIVO', 'MANTENIMIENTO'))
);

COMMENT ON TABLE consultorio IS 'Consultorios disponibles para atención médica';
COMMENT ON COLUMN consultorio.piso IS 'Número de piso (-2=Sótano 2, -1=Sótano 1, 0=Planta baja)';

-- Crear índices
CREATE INDEX idx_especialidad_codigo ON especialidad(codigo);
CREATE INDEX idx_especialidad_nombre ON especialidad(nombre);
CREATE INDEX idx_consultorio_codigo ON consultorio(codigo);
CREATE INDEX idx_consultorio_piso ON consultorio(piso);

-- Verificar tablas creadas
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;