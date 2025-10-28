# 6. Implementación de Base de Datos

## Sistema de Reserva de Consultas Médicas Externas

---

## 6.1. Introducción

Este documento describe la implementación física de la base de datos en PostgreSQL. Incluye:

- Scripts DDL (Data Definition Language) para crear estructuras
- Scripts DML (Data Manipulation Language) para insertar datos
- Scripts DQL (Data Query Language) para consultas
- Funciones almacenadas y triggers
- Procedimientos de respaldo y recuperación

---

## 6.2. Estructura de Scripts SQL

Los scripts están organizados en la siguiente estructura:

```
database/
├── ddl/                           # Definición de  estructuras
│   ├── 01_create_database.sql
│   ├── 02_create_schemas.sql
│   ├── 03_create_lookup_tables.sql
│   ├── 04_create_main_tables.sql
│   ├── 05_create_associative_tables.sql
│   ├── 06_create_views.sql
│   ├── 07_create_functions.sql
│   └── 08_create_triggers.sql
├── dml/                           # Inserción de datos
│   ├── 09_insert_lookup_data.sql
│   └── 10_insert_test_data.sql
└── dql/                           # Consultas
    ├── 11_basic_queries.sql
    ├── 12_intermediate_queries.sql
    └── 13_advanced_queries.sql
```

---

## 6.3. Orden de Ejecución de Scripts

**IMPORTANTE:** Los scripts deben ejecutarse en el orden especificado:

```bash
# Paso 1: Conectarse a PostgreSQL
psql -U postgres

# Paso 2: Crear la base de datos
\i database/ddl/01_create_database.sql

# Paso 3: Conectarse a la nueva base de datos
\c sistema_consultas_medicas

# Paso 4: Ejecutar scripts DDL en orden
\i database/ddl/02_create_schemas.sql
\i database/ddl/03_create_lookup_tables.sql
\i database/ddl/04_create_main_tables.sql
\i database/ddl/05_create_associative_tables.sql
\i database/ddl/06_create_views.sql
\i database/ddl/07_create_functions.sql
\i database/ddl/08_create_triggers.sql

# Paso 5: Insertar datos de catálogo
\i database/dml/09_insert_lookup_data.sql

# Paso 6: Insertar datos de prueba (opcional)
\i database/dml/10_insert_test_data.sql
```

---

## 6.4. Scripts DDL (Data Definition Language)

### 6.4.1. Script 01: Crear Base de Datos

**Ubicación:** `database/ddl/01_create_database.sql`

**Propósito:** Crear la base de datos principal con configuración UTF-8.

```sql
-- ============================================
-- Script: 01_create_database.sql
-- Descripción: Crear base de datos principal
-- Autor: [francito69]
-- Fecha: 2025-10-27
-- ============================================

-- Eliminar base de datos si existe (CUIDADO en producción)
DROP DATABASE IF EXISTS sistema_consultas_medicas;

-- Crear base de datos
CREATE DATABASE sistema_consultas_medicas
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_PE.UTF-8'
    LC_CTYPE = 'es_PE.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE sistema_consultas_medicas 
    IS 'Base de datos para el Sistema de Reserva de Consultas Médicas Externas';

-- Conectarse a la base de datos
\c sistema_consultas_medicas

-- Verificar conexión
SELECT current_database(), version();
```

---

### 6.4.2. Script 02: Crear Esquemas

**Ubicación:** `database/ddl/02_create_schemas.sql`

**Propósito:** Crear esquemas para organizar las tablas.

```sql
-- ============================================
-- Script: 02_create_schemas.sql
-- Descripción: Crear esquemas de organización
-- ============================================

-- Esquema público (ya existe, pero lo documentamos)
COMMENT ON SCHEMA public 
    IS 'Esquema principal del sistema';

-- Crear esquema para auditoría (futuro)
CREATE SCHEMA IF NOT EXISTS auditoria;
COMMENT ON SCHEMA auditoria 
    IS 'Esquema para tablas de auditoría y logs';

-- Crear esquema para reportes (futuro)
CREATE SCHEMA IF NOT EXISTS reportes;
COMMENT ON SCHEMA reportes 
    IS 'Esquema para vistas y tablas de reportes';

-- Listar esquemas creados
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name NOT IN ('pg_catalog', 'information_schema');
```

---

### 6.4.3. Script 03: Crear Tablas Lookup

**Ubicación:** `database/ddl/03_create_lookup_tables.sql`

**Propósito:** Crear tablas de catálogo (Lookup tables).

```sql
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
```

---

### 6.4.4. Script 04: Crear Tablas Principales

**Ubicación:** `database/ddl/04_create_main_tables.sql`

**Propósito:** Crear tablas principales del sistema.

```sql
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
```

---

### 6.4.5. Script 05: Crear Tablas Asociativas

**Ubicación:** `database/ddl/05_create_associative_tables.sql`

**Propósito:** Crear tablas de relación y la tabla principal CITA.

```sql
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
```

---

### 6.4.6. Script 06: Crear Vistas

**Ubicación:** `database/ddl/06_create_views.sql`

```sql
-- ============================================
-- Script: 06_create_views.sql
-- Descripción: Crear vistas para consultas
-- ============================================

-- Vista: v_citas_completas
CREATE OR REPLACE VIEW v_citas_completas AS
SELECT 
    c.id_cita,
    c.codigo_cita,
    c.fecha_cita,
    c.hora_inicio,
    c.hora_fin,
    c.motivo_consulta,
    c.observaciones,
    
    -- Paciente
    p.id_paciente,
    p.dni AS paciente_dni,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS paciente_nombre_completo,
    p.email AS paciente_email,
    EXTRACT(YEAR FROM AGE(p.fecha_nacimiento)) AS paciente_edad,
    
    -- Médico
    m.id_medico,
    m.numero_colegiatura,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico_nombre_completo,
    m.email AS medico_email,
    
    -- Especialidad
    e.nombre AS especialidad_nombre,
    
    -- Consultorio
    co.codigo AS consultorio_codigo,
    co.nombre AS consultorio_nombre,
    co.piso AS consultorio_piso,
    
    -- Estado
    ec.codigo AS estado_codigo,
    ec.nombre AS estado_nombre,
    ec.color AS estado_color,
    
    -- Metadatos
    c.fecha_registro,
    c.fecha_actualizacion,
    c.recordatorio_enviado
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN especialidad e ON c.id_especialidad = e.id_especialidad
INNER JOIN consultorio co ON c.id_consultorio = co.id_consultorio
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado;

COMMENT ON VIEW v_citas_completas IS 'Vista con información completa de citas';

-- Vista: v_horarios_disponibles
CREATE OR REPLACE VIEW v_horarios_disponibles AS
SELECT 
    ha.id_horario,
    ha.dia_semana,
    ha.hora_inicio,
    ha.hora_fin,
    ha.duracion_cita,
    
    m.id_medico,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico_nombre,
    m.numero_colegiatura,
    
    e.nombre AS especialidad_nombre,
    
    c.codigo AS consultorio_codigo,
    c.nombre AS consultorio_nombre,
    c.piso AS consultorio_piso
FROM horario_atencion ha
INNER JOIN medico m ON ha.id_medico = m.id_medico
INNER JOIN especialidad e ON ha.id_especialidad = e.id_especialidad
INNER JOIN consultorio c ON ha.id_consultorio = c.id_consultorio
WHERE ha.estado = 'ACTIVO'
  AND m.estado = 'ACTIVO';

-- Vista: v_medicos_con_especialidades
CREATE OR REPLACE VIEW v_medicos_con_especialidades AS
SELECT 
    m.id_medico,
    m.dni,
    CONCAT(m.nombres, ' ', m.apellido_paterno, ' ', m.apellido_materno) AS nombre_completo,
    m.numero_colegiatura,
    m.email,
    m.telefono,
    m.estado,
    STRING_AGG(e.nombre, ', ' ORDER BY e.nombre) AS especialidades,
    COUNT(me.id_especialidad) AS cantidad_especialidades
FROM medico m
LEFT JOIN medico_especialidad me ON m.id_medico = me.id_medico
LEFT JOIN especialidad e ON me.id_especialidad = e.id_especialidad
GROUP BY m.id_medico, m.dni, m.nombres, m.apellido_paterno, m.apellido_materno, 
         m.numero_colegiatura, m.email, m.telefono, m.estado;

-- Vista: v_estadisticas_citas
CREATE OR REPLACE VIEW v_estadisticas_citas AS
SELECT 
    COUNT(*) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'PENDIENTE' THEN 1 END) AS citas_pendientes,
    COUNT(CASE WHEN ec.codigo = 'CONFIRMADA' THEN 1 END) AS citas_confirmadas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS citas_atendidas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS citas_canceladas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS citas_no_presentadas,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) / NULLIF(COUNT(*), 0), 2) AS tasa_cancelacion,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) / NULLIF(COUNT(*), 0), 2) AS tasa_no_presentacion
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado;

-- Verificar vistas creadas
SELECT 
    schemaname, 
    viewname, 
    viewowner,
    definition 
FROM pg_views 
WHERE schemaname = 'public'
ORDER BY viewname;
```

---

### 6.4.7. Script 07: Crear Funciones

**Ubicación:** `database/ddl/07_create_functions.sql`

```sql
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
```

---

### 6.4.8. Script 08: Crear Triggers

**Ubicación:** `database/ddl/08_create_triggers.sql`

```sql
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
```

---

## 6.5. Scripts DML (Data Manipulation Language)

### 6.5.1. Script 09: Insertar Datos de Catálogo

**Ubicación:** `database/dml/09_insert_lookup_data.sql`

```sql
-- ============================================
-- Script: 09_insert_lookup_data.sql
-- Descripción: Insertar datos de catálogo
-- ============================================

-- Insertar estados de cita
INSERT INTO estado_cita (id_estado, codigo, nombre, descripcion, color) VALUES
(1, 'PENDIENTE', 'Pendiente', 'Cita recién creada, pendiente de confirmación', '#FFA500'),
(2, 'CONFIRMADA', 'Confirmada', 'Cita confirmada por el sistema', '#00FF00'),
(3, 'ATENDIDA', 'Atendida', 'Paciente fue atendido exitosamente', '#0000FF'),
(4, 'CANCELADA', 'Cancelada', 'Cita fue cancelada por el paciente o médico', '#FF0000'),
(5, 'NO_PRESENTADO', 'No Presentado', 'Paciente no asistió a la cita', '#808080');

-- Reiniciar secuencia
SELECT setval('estado_cita_id_estado_seq', 5, true);

-- Insertar especialidades médicas
INSERT INTO especialidad (codigo, nombre, descripcion, estado) VALUES
('CARD-01', 'Cardiología', 'Especialidad médica que se encarga del estudio, diagnóstico y tratamiento de las enfermedades del corazón', 'ACTIVO'),
('PEDI-01', 'Pediatría', 'Especialidad médica que estudia al niño y sus enfermedades', 'ACTIVO'),
('DERM-01', 'Dermatología', 'Especialidad médica que se encarga del diagnóstico y tratamiento de las enfermedades de la piel', 'ACTIVO'),
('TRAU-01', 'Traumatología', 'Especialidad que estudia las lesiones del aparato locomotor', 'ACTIVO'),
('MGEN-01', 'Medicina General', 'Atención médica general y preventiva', 'ACTIVO'),
('GINE-01', 'Ginecología', 'Especialidad médica que trata las enfermedades del sistema reproductor femenino', 'ACTIVO'),
('OFTA-01', 'Oftalmología', 'Especialidad médica que estudia las enfermedades de ojo y su tratamiento', 'ACTIVO'),
('NEUR-01', 'Neurología', 'Especialidad médica que trata los trastornos del sistema nervioso', 'ACTIVO'),
('PSIQ-01', 'Psiquiatría', 'Especialidad dedicada al estudio y tratamiento de las enfermedades mentales', 'ACTIVO'),
('NUTR-01', 'Nutrición', 'Especialidad que estudia la relación entre los alimentos y la salud', 'ACTIVO');

-- Insertar consultorios
INSERT INTO consultorio (codigo, nombre, piso, capacidad, equipamiento, estado) VALUES
('CONS-101', 'Consultorio de Cardiología 1', 1, 1, 'Electrocardiógrafo, Camilla, Tensiómetro', 'ACTIVO'),
('CONS-102', 'Consultorio de Pediatría 1', 1, 1, 'Balanza pediátrica, Camilla pediátrica, Esterilizador', 'ACTIVO'),
('CONS-201', 'Consultorio de Medicina General 1', 2, 1, 'Camilla, Tensiómetro, Estetoscopio', 'ACTIVO'),
('CONS-202', 'Consultorio de Medicina General 2', 2, 1, 'Camilla, Tensiómetro, Estetoscopio', 'ACTIVO'),
('CONS-301', 'Consultorio de Traumatología 1', 3, 1, 'Camilla ortopédica, Rayos X portátil', 'ACTIVO'),
('CONS-302', 'Consultorio de Dermatología 1', 3, 1, 'Lámpara de Wood, Dermatoscopio, Camilla', 'ACTIVO'),
('CONS-401', 'Consultorio de Ginecología 1', 4, 1, 'Camilla ginecológica, Ecógrafo, Colposcopio', 'ACTIVO'),
('CONS-402', 'Consultorio de Oftalmología 1', 4, 1, 'Lámpara de hendidura, Refractómetro, Tonómetro', 'ACTIVO');

-- Verificar datos insertados
SELECT 'Estado Cita' AS tabla, COUNT(*) AS registros FROM estado_cita
UNION ALL
SELECT 'Especialidad' AS tabla, COUNT(*) AS registros FROM especialidad
UNION ALL
SELECT 'Consultorio' AS tabla, COUNT(*) AS registros FROM consultorio;
```

---

## 6.6. Resumen de Implementación

### 6.6.1. Checklist de Implementación

✅ **Fase 1: Estructura**
- [x] Base de datos creada
- [x] Esquemas definidos
- [x] Tablas lookup creadas
- [x] Tablas principales creadas
- [x] Tablas asociativas creadas

✅ **Fase 2: Lógica**
- [x] Vistas creadas
- [x] Funciones implementadas
- [x] Triggers activados

✅ **Fase 3: Datos**
- [x] Datos de catálogo insertados
- [x] Datos de prueba (opcional)

✅ **Fase 4: Verificación**
- [x] Integridad referencial verificada
- [x] Constraints funcionando
- [x] Índices creados

---

[⬅️ Anterior: Diseño Lógico](05-diseño-logico.md) | [Volver al índice](README.md) | [Siguiente: Manual Técnico ➡️](07-manual-tecnico.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div>