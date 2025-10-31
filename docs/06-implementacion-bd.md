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

### 6.5.2. Script 10: Insertar Datos de Prueba

**Ubicación:** `database/dml/10_insert_test_data.sql`

**Propósito:** Insertar datos de prueba para desarrollo y testing.

```sql
-- ============================================
-- Script: 10_insert_test_data.sql
-- Descripción: Insertar datos de prueba
-- Autor: [francito69]
-- Fecha: 2025-10-30
-- ============================================

BEGIN;

-- ===========================================
-- 1. INSERTAR USUARIOS
-- ===========================================

-- Usuarios Administrador
INSERT INTO usuario (nombre_usuario, contraseña, email, rol, estado) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@hospital.com', 'ADMIN', 'ACTIVO');
-- Contraseña: admin123

-- Usuarios Médicos
INSERT INTO usuario (nombre_usuario, contraseña, email, rol, estado) VALUES
('dr.garcia', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'garcia@hospital.com', 'MEDICO', 'ACTIVO'),
('dr.lopez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'lopez@hospital.com', 'MEDICO', 'ACTIVO'),
('dr.martinez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'martinez@hospital.com', 'MEDICO', 'ACTIVO'),
('dra.fernandez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'fernandez@hospital.com', 'MEDICO', 'ACTIVO');

-- Usuarios Pacientes
INSERT INTO usuario (nombre_usuario, contraseña, email, rol, estado) VALUES
('jperes', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'juan.perez@email.com', 'PACIENTE', 'ACTIVO'),
('mrodriguez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'maria.rodriguez@email.com', 'PACIENTE', 'ACTIVO'),
('cgonzalez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'carlos.gonzalez@email.com', 'PACIENTE', 'ACTIVO'),
('asilva', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ana.silva@email.com', 'PACIENTE', 'ACTIVO'),
('ltorres', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'luis.torres@email.com', 'PACIENTE', 'ACTIVO');

-- ===========================================
-- 2. INSERTAR MÉDICOS
-- ===========================================

INSERT INTO medico (dni, nombres, apellido_paterno, apellido_materno, numero_colegiatura, email, telefono, id_usuario) VALUES
('45678901', 'Roberto Carlos', 'García', 'Mendoza', 'CMP-12345', 'garcia@hospital.com', '987654321', 2),
('45678902', 'Patricia Elena', 'López', 'Vargas', 'CMP-12346', 'lopez@hospital.com', '987654322', 3),
('45678903', 'Miguel Ángel', 'Martínez', 'Ramos', 'CMP-12347', 'martinez@hospital.com', '987654323', 4),
('45678904', 'Carmen Rosa', 'Fernández', 'Castro', 'CMP-12348', 'fernandez@hospital.com', '987654324', 5);

-- ===========================================
-- 3. ASIGNAR ESPECIALIDADES A MÉDICOS
-- ===========================================

-- Dr. García - Cardiología y Medicina General
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(1, 1, '2020-03-15', 'Colegio Médico del Perú'),
(1, 5, '2018-06-20', 'Universidad Nacional Mayor de San Marcos');

-- Dra. López - Pediatría
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(2, 2, '2019-08-10', 'Instituto Nacional de Salud del Niño');

-- Dr. Martínez - Traumatología
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(3, 4, '2021-01-25', 'Hospital Nacional Dos de Mayo');

-- Dra. Fernández - Ginecología y Medicina General
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(4, 6, '2020-11-30', 'Instituto Nacional Materno Perinatal'),
(4, 5, '2017-05-15', 'Universidad Peruana Cayetano Heredia');

-- ===========================================
-- 4. INSERTAR HORARIOS DE ATENCIÓN
-- ===========================================

-- Dr. García - Cardiología (Lunes, Miércoles, Viernes)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(1, 1, 1, 'LUNES', '08:00', '13:00', 30),
(1, 1, 1, 'MIERCOLES', '08:00', '13:00', 30),
(1, 1, 1, 'VIERNES', '08:00', '13:00', 30);

-- Dr. García - Medicina General (Martes, Jueves)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(1, 3, 5, 'MARTES', '14:00', '18:00', 20),
(1, 3, 5, 'JUEVES', '14:00', '18:00', 20);

-- Dra. López - Pediatría (Lunes a Viernes por la mañana)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(2, 2, 2, 'LUNES', '09:00', '13:00', 25),
(2, 2, 2, 'MARTES', '09:00', '13:00', 25),
(2, 2, 2, 'MIERCOLES', '09:00', '13:00', 25),
(2, 2, 2, 'JUEVES', '09:00', '13:00', 25),
(2, 2, 2, 'VIERNES', '09:00', '13:00', 25);

-- Dr. Martínez - Traumatología (Martes, Jueves, Sábado)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(3, 5, 4, 'MARTES', '08:00', '12:00', 30),
(3, 5, 4, 'JUEVES', '08:00', '12:00', 30),
(3, 5, 4, 'SABADO', '08:00', '12:00', 30);

-- Dra. Fernández - Ginecología (Lunes, Miércoles, Viernes)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(4, 7, 6, 'LUNES', '15:00', '19:00', 40),
(4, 7, 6, 'MIERCOLES', '15:00', '19:00', 40),
(4, 7, 6, 'VIERNES', '15:00', '19:00', 40);

-- ===========================================
-- 5. INSERTAR PACIENTES
-- ===========================================

INSERT INTO paciente (dni, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, genero, direccion, email, id_usuario) VALUES
('70123456', 'Juan Carlos', 'Pérez', 'García', '1990-05-15', 'M', 'Av. Arequipa 1234, Lima', 'juan.perez@email.com', 6),
('70123457', 'María Isabel', 'Rodríguez', 'López', '1985-08-22', 'F', 'Jr. Huancayo 567, Lima', 'maria.rodriguez@email.com', 7),
('70123458', 'Carlos Alberto', 'González', 'Martínez', '1978-12-10', 'M', 'Av. Brasil 890, Lima', 'carlos.gonzalez@email.com', 8),
('70123459', 'Ana Lucía', 'Silva', 'Fernández', '1995-03-25', 'F', 'Calle Los Olivos 234, Lima', 'ana.silva@email.com', 9),
('70123460', 'Luis Fernando', 'Torres', 'Ramírez', '1982-07-18', 'M', 'Av. Colonial 456, Lima', 'luis.torres@email.com', 10);

-- ===========================================
-- 6. INSERTAR TELÉFONOS DE PACIENTES
-- ===========================================

INSERT INTO paciente_telefono (id_paciente, numero, tipo, es_principal) VALUES
(1, '987654321', 'MOVIL', true),
(1, '014567890', 'FIJO', false),
(2, '987654322', 'MOVIL', true),
(3, '987654323', 'MOVIL', true),
(3, '014567891', 'TRABAJO', false),
(4, '987654324', 'MOVIL', true),
(5, '987654325', 'MOVIL', true);

-- ===========================================
-- 7. INSERTAR CITAS DE PRUEBA
-- ===========================================

-- Citas futuras (PENDIENTE/CONFIRMADA)
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta
) VALUES
('CITA-2025-0001', 1, 1, 1, 1, 2, CURRENT_DATE + INTERVAL '5 days', '08:00', '08:30', 'Control de presión arterial y revisión general del corazón'),
('CITA-2025-0002', 2, 2, 2, 2, 2, CURRENT_DATE + INTERVAL '7 days', '09:00', '09:25', 'Control de crecimiento y desarrollo del niño de 3 años'),
('CITA-2025-0003', 3, 3, 5, 4, 1, CURRENT_DATE + INTERVAL '10 days', '08:30', '09:00', 'Dolor en rodilla derecha después de practicar deporte'),
('CITA-2025-0004', 4, 4, 7, 6, 1, CURRENT_DATE + INTERVAL '12 days', '15:00', '15:40', 'Control ginecológico anual de rutina y papanicolau'),
('CITA-2025-0005', 5, 1, 3, 5, 2, CURRENT_DATE + INTERVAL '3 days', '14:00', '14:20', 'Consulta general por gripe y malestar general');

-- Citas pasadas (ATENDIDA)
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta, observaciones
) VALUES
('CITA-2025-0006', 1, 1, 1, 1, 3, CURRENT_DATE - INTERVAL '15 days', '08:00', '08:30', 
 'Dolor en el pecho y palpitaciones', 
 'Paciente diagnosticado con arritmia leve. Se recetó medicamento y se programa seguimiento.'),
('CITA-2025-0007', 2, 2, 2, 2, 3, CURRENT_DATE - INTERVAL '30 days', '10:00', '10:25', 
 'Vacunación y control de peso del niño', 
 'Niño con desarrollo normal. Se aplicaron vacunas correspondientes.'),
('CITA-2025-0008', 3, 3, 5, 4, 3, CURRENT_DATE - INTERVAL '45 days', '09:00', '09:30', 
 'Fractura de muñeca izquierda', 
 'Se colocó yeso. Control en 4 semanas para evaluar consolidación.');

-- Citas canceladas
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta, 
    motivo_cancelacion, cancelado_por
) VALUES
('CITA-2025-0009', 4, 4, 7, 6, 4, CURRENT_DATE + INTERVAL '2 days', '16:00', '16:40', 
 'Control prenatal del primer trimestre', 
 'Paciente tuvo compromiso laboral urgente', 'PACIENTE'),
('CITA-2025-0010', 5, 1, 1, 1, 4, CURRENT_DATE + INTERVAL '4 days', '09:00', '09:30', 
 'Evaluación cardiológica por antecedentes familiares', 
 'Médico tuvo emergencia familiar', 'MEDICO');

-- Citas con inasistencia
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta
) VALUES
('CITA-2025-0011', 3, 2, 2, 2, 5, CURRENT_DATE - INTERVAL '7 days', '11:00', '11:25', 
 'Control pediátrico del bebé de 6 meses');

COMMIT;

-- ===========================================
-- 8. VERIFICAR DATOS INSERTADOS
-- ===========================================

SELECT 'Usuarios' AS tabla, COUNT(*) AS total FROM usuario
UNION ALL
SELECT 'Médicos' AS tabla, COUNT(*) AS total FROM medico
UNION ALL
SELECT 'Pacientes' AS tabla, COUNT(*) AS total FROM paciente
UNION ALL
SELECT 'Especialidades Médicas' AS tabla, COUNT(*) AS total FROM medico_especialidad
UNION ALL
SELECT 'Horarios de Atención' AS tabla, COUNT(*) AS total FROM horario_atencion
UNION ALL
SELECT 'Teléfonos' AS tabla, COUNT(*) AS total FROM paciente_telefono
UNION ALL
SELECT 'Citas' AS tabla, COUNT(*) AS total FROM cita
UNION ALL
SELECT 'Notificaciones' AS tabla, COUNT(*) AS total FROM notificacion;

-- Mostrar distribución de citas por estado
SELECT 
    ec.nombre AS estado,
    COUNT(*) AS cantidad,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cita), 2) AS porcentaje
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY ec.nombre, ec.id_estado
ORDER BY ec.id_estado;

PRINT 'Datos de prueba insertados exitosamente!';
```

---

## 6.6. Scripts DQL (Data Query Language)

### 6.6.1. Script 11: Consultas Básicas

**Ubicación:** `database/dql/11_basic_queries.sql`

**Propósito:** Consultas básicas para verificación y operaciones comunes.

```sql
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
```

---

### 6.6.2. Script 12: Consultas Intermedias

**Ubicación:** `database/dql/12_intermediate_queries.sql`

**Propósito:** Consultas con JOINs, agregaciones y subconsultas.

```sql
-- ============================================
-- Script: 12_intermediate_queries.sql
-- Descripción: Consultas intermedias
-- Autor: [francito69]
-- Fecha: 2025-10-30
-- ============================================

-- ===========================================
-- 1. CONSULTAS CON AGREGACIONES
-- ===========================================

-- Estadísticas generales del sistema
SELECT 
    (SELECT COUNT(*) FROM usuario WHERE rol = 'PACIENTE') AS total_pacientes,
    (SELECT COUNT(*) FROM usuario WHERE rol = 'MEDICO') AS total_medicos,
    (SELECT COUNT(*) FROM especialidad WHERE estado = 'ACTIVO') AS total_especialidades,
    (SELECT COUNT(*) FROM consultorio WHERE estado = 'ACTIVO') AS total_consultorios,
    (SELECT COUNT(*) FROM cita) AS total_citas,
    (SELECT COUNT(*) FROM cita WHERE fecha_cita >= CURRENT_DATE) AS citas_futuras;

-- Médicos con más citas atendidas
SELECT 
    m.id_medico,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS citas_atendidas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS citas_canceladas,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) / NULLIF(COUNT(c.id_cita), 0), 2) AS porcentaje_atencion
FROM medico m
LEFT JOIN cita c ON m.id_medico = c.id_medico
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY m.id_medico, m.nombres, m.apellido_paterno
HAVING COUNT(c.id_cita) > 0
ORDER BY citas_atendidas DESC;

-- Especialidades más solicitadas
SELECT 
    e.nombre AS especialidad,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN c.fecha_cita >= CURRENT_DATE THEN 1 END) AS citas_futuras,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS citas_canceladas
FROM especialidad e
LEFT JOIN cita c ON e.id_especialidad = c.id_especialidad
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY e.id_especialidad, e.nombre
ORDER BY total_citas DESC;

-- Pacientes con más citas
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS paciente,
    p.dni,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS citas_atendidas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS inasistencias
FROM paciente p
LEFT JOIN cita c ON p.id_paciente = c.id_paciente
LEFT JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY p.id_paciente, p.nombres, p.apellido_paterno, p.apellido_materno, p.dni
HAVING COUNT(c.id_cita) > 0
ORDER BY total_citas DESC;

-- Consultorios más utilizados
SELECT 
    co.codigo,
    co.nombre AS consultorio,
    co.piso,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN c.fecha_cita >= CURRENT_DATE THEN 1 END) AS citas_futuras
FROM consultorio co
LEFT JOIN cita c ON co.id_consultorio = c.id_consultorio
GROUP BY co.id_consultorio, co.codigo, co.nombre, co.piso
ORDER BY total_citas DESC;

-- ===========================================
-- 2. CONSULTAS CON FECHAS
-- ===========================================

-- Citas por mes (últimos 6 meses)
SELECT 
    TO_CHAR(c.fecha_cita, 'YYYY-MM') AS mes,
    TO_CHAR(c.fecha_cita, 'TMMonth YYYY') AS mes_nombre,
    COUNT(*) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'ATENDIDA' THEN 1 END) AS atendidas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS canceladas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS no_presentados
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY TO_CHAR(c.fecha_cita, 'YYYY-MM'), TO_CHAR(c.fecha_cita, 'TMMonth YYYY')
ORDER BY mes DESC;

-- Citas por día de la semana
SELECT 
    TO_CHAR(c.fecha_cita, 'Day') AS dia_semana,
    COUNT(*) AS total_citas,
    ROUND(AVG(COUNT(*)) OVER(), 2) AS promedio_diario
FROM cita c
WHERE c.fecha_cita >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY TO_CHAR(c.fecha_cita, 'Day'), EXTRACT(DOW FROM c.fecha_cita)
ORDER BY EXTRACT(DOW FROM c.fecha_cita);

-- Horarios más solicitados
SELECT 
    EXTRACT(HOUR FROM c.hora_inicio) AS hora,
    COUNT(*) AS cantidad_citas,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cita), 2) AS porcentaje
FROM cita c
GROUP BY EXTRACT(HOUR FROM c.hora_inicio)
ORDER BY hora;

-- ===========================================
-- 3. CONSULTAS CON SUBCONSULTAS
-- ===========================================

-- Médicos sin citas programadas
SELECT 
    m.id_medico,
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    m.numero_colegiatura,
    m.email
FROM medico m
WHERE m.estado = 'ACTIVO'
  AND NOT EXISTS (
      SELECT 1 
      FROM cita c 
      WHERE c.id_medico = m.id_medico 
        AND c.fecha_cita >= CURRENT_DATE
        AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
  )
ORDER BY m.apellido_paterno;

-- Pacientes sin citas recientes (últimos 6 meses)
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    p.dni,
    p.email,
    (SELECT MAX(c.fecha_cita) 
     FROM cita c 
     WHERE c.id_paciente = p.id_paciente) AS ultima_cita
FROM paciente p
WHERE p.estado = 'ACTIVO'
  AND NOT EXISTS (
      SELECT 1 
      FROM cita c 
      WHERE c.id_paciente = p.id_paciente 
        AND c.fecha_cita >= CURRENT_DATE - INTERVAL '6 months'
  )
ORDER BY ultima_cita DESC NULLS LAST;

-- Consultorios disponibles en horario específico
SELECT 
    co.codigo,
    co.nombre,
    co.piso
FROM consultorio co
WHERE co.estado = 'ACTIVO'
  AND NOT EXISTS (
      SELECT 1
      FROM cita c
      WHERE c.id_consultorio = co.id_consultorio
        AND c.fecha_cita = CURRENT_DATE + INTERVAL '7 days'
        AND c.hora_inicio = '10:00'
        AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
  )
ORDER BY co.piso, co.codigo;

-- ===========================================
-- 4. CONSULTAS CON VISTAS
-- ===========================================

-- Usar vista de citas completas
SELECT 
    codigo_cita,
    fecha_cita,
    hora_inicio,
    paciente_nombre_completo,
    medico_nombre_completo,
    especialidad_nombre,
    estado_nombre
FROM v_citas_completas
WHERE fecha_cita BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY fecha_cita, hora_inicio;

-- Usar vista de horarios disponibles
SELECT 
    dia_semana,
    hora_inicio,
    hora_fin,
    medico_nombre,
    especialidad_nombre,
    consultorio_nombre
FROM v_horarios_disponibles
WHERE dia_semana = 'LUNES'
ORDER BY hora_inicio;

-- Usar vista de médicos con especialidades
SELECT 
    nombre_completo,
    numero_colegiatura,
    especialidades,
    cantidad_especialidades
FROM v_medicos_con_especialidades
WHERE estado = 'ACTIVO'
ORDER BY cantidad_especialidades DESC, nombre_completo;

-- ===========================================
-- 5. ANÁLISIS DE CANCELACIONES
-- ===========================================

-- Motivos de cancelación más frecuentes
SELECT 
    c.cancelado_por,
    COUNT(*) AS cantidad,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cita WHERE id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'CANCELADA')), 2) AS porcentaje
FROM cita c
WHERE c.id_estado = (SELECT id_estado FROM estado_cita WHERE codigo = 'CANCELADA')
  AND c.cancelado_por IS NOT NULL
GROUP BY c.cancelado_por
ORDER BY cantidad DESC;

-- Pacientes con más cancelaciones
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) AS cancelaciones,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) / NULLIF(COUNT(c.id_cita), 0), 2) AS tasa_cancelacion
FROM paciente p
INNER JOIN cita c ON p.id_paciente = c.id_paciente
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY p.id_paciente, p.nombres, p.apellido_paterno
HAVING COUNT(CASE WHEN ec.codigo = 'CANCELADA' THEN 1 END) > 0
ORDER BY cancelaciones DESC;

-- ===========================================
-- 6. ANÁLISIS DE OCUPACIÓN
-- ===========================================

-- Tasa de ocupación por médico
SELECT 
    CONCAT('Dr(a). ', m.nombres, ' ', m.apellido_paterno) AS medico,
    COUNT(ha.id_horario) AS horarios_configurados,
    COUNT(c.id_cita) AS citas_reservadas,
    ROUND(100.0 * COUNT(c.id_cita) / NULLIF(COUNT(ha.id_horario), 0), 2) AS tasa_ocupacion
FROM medico m
LEFT JOIN horario_atencion ha ON m.id_medico = ha.id_medico AND ha.estado = 'ACTIVO'
LEFT JOIN cita c ON m.id_medico = c.id_medico 
    AND c.fecha_cita BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
    AND c.id_estado IN (SELECT id_estado FROM estado_cita WHERE codigo IN ('PENDIENTE', 'CONFIRMADA'))
GROUP BY m.id_medico, m.nombres, m.apellido_paterno
ORDER BY tasa_ocupacion DESC;

-- ===========================================
-- 7. INDICADORES DE CALIDAD
-- ===========================================

-- Tasa de no presentación por paciente
SELECT 
    p.id_paciente,
    CONCAT(p.nombres, ' ', p.apellido_paterno) AS paciente,
    COUNT(c.id_cita) AS total_citas,
    COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) AS no_presentaciones,
    ROUND(100.0 * COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) / NULLIF(COUNT(c.id_cita), 0), 2) AS tasa_no_presentacion
FROM paciente p
INNER JOIN cita c ON p.id_paciente = c.id_paciente
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
WHERE c.fecha_cita < CURRENT_DATE
GROUP BY p.id_paciente, p.nombres, p.apellido_paterno
HAVING COUNT(CASE WHEN ec.codigo = 'NO_PRESENTADO' THEN 1 END) > 0
ORDER BY tasa_no_presentacion DESC;
```

---

### 6.6.3. Script 13: Consultas Avanzadas

**Ubicación:** `database/dql/13_advanced_queries.sql`

**Propósito:** Consultas avanzadas con window functions, CTEs y análisis complejos.

```sql
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
```

---

## 6.7. Resumen de Implementación

### 6.7.1. Checklist de Implementación

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
- [x] Datos de prueba insertados

✅ **Fase 4: Verificación**
- [x] Integridad referencial verificada
- [x] Constraints funcionando
- [x] Índices creados

✅ **Fase 5: Consultas**
- [x] Consultas básicas implementadas
- [x] Consultas intermedias implementadas
- [x] Consultas avanzadas implementadas

---

### 6.7.2. Comandos Útiles de PostgreSQL

```bash
# Conectarse a PostgreSQL
psql -U postgres

# Listar bases de datos
\l

# Conectarse a una base de datos
\c sistema_consultas_medicas

# Listar tablas
\dt

# Describir estructura de una tabla
\d nombre_tabla

# Listar vistas
\dv

# Listar funciones
\df

# Listar triggers
\dy

# Ver esquemas
\dn

# Exportar resultado de consulta a CSV
\copy (SELECT * FROM cita) TO '/tmp/citas.csv' CSV HEADER;

# Ejecutar script SQL desde archivo
\i /ruta/al/script.sql

# Salir de psql
\q
```

---

### 6.7.3. Backup y Restore

```bash
# Hacer backup completo de la base de datos
pg_dump -U postgres -d sistema_consultas_medicas -F c -f backup_sistema.dump

# Restaurar desde backup
pg_restore -U postgres -d sistema_consultas_medicas backup_sistema.dump

# Backup solo de datos (sin estructura)
pg_dump -U postgres -d sistema_consultas_medicas --data-only -f backup_datos.sql

# Backup solo de estructura (sin datos)
pg_dump -U postgres -d sistema_consultas_medicas --schema-only -f backup_estructura.sql
```

---

[⬅️ Anterior: Diseño Lógico](05-diseño-logico.md) | [Volver al índice](README.md) | [Siguiente: Manual Técnico ➡️](07-manual-tecnico.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div>