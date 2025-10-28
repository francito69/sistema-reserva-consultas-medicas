# 5. Diseño Lógico

## Sistema de Reserva de Consultas Médicas Externas

---

## 5.1. Introducción

El diseño lógico transforma el modelo conceptual (Entidad-Relación) en un **modelo relacional** implementable en PostgreSQL. En esta fase se definen:

- Esquemas de tablas con tipos de datos específicos
- Claves primarias y foráneas
- Restricciones de integridad
- Índices para optimización
- Normalización de datos

---

## 5.2. Diagrama Relacional

**Ubicación:** [diagramas/diagrama-relacional.png](../diagramas/diagrama-relacional.png)

### 5.2.1. Representación Textual del Esquema

```sql
USUARIO (
    id_usuario SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('PACIENTE', 'MEDICO', 'ADMIN')),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP
)

PACIENTE (
    id_paciente SERIAL PRIMARY KEY,
    dni CHAR(8) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL CHECK (genero IN ('M', 'F', 'O')),
    direccion VARCHAR(200),
    email VARCHAR(100) UNIQUE NOT NULL,
    id_usuario INTEGER UNIQUE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) ON DELETE CASCADE
)

PACIENTE_TELEFONO (
    id_telefono SERIAL PRIMARY KEY,
    id_paciente INTEGER NOT NULL,
    numero VARCHAR(15) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('MOVIL', 'FIJO', 'TRABAJO')),
    es_principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_paciente) REFERENCES PACIENTE(id_paciente) ON DELETE CASCADE
)

MEDICO (
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
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) ON DELETE CASCADE
)

ESPECIALIDAD (
    id_especialidad SERIAL PRIMARY KEY,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
)

MEDICO_ESPECIALIDAD (
    id_medico_especialidad SERIAL PRIMARY KEY,
    id_medico INTEGER NOT NULL,
    id_especialidad INTEGER NOT NULL,
    fecha_certificacion DATE,
    institucion_certificadora VARCHAR(200),
    FOREIGN KEY (id_medico) REFERENCES MEDICO(id_medico) ON DELETE CASCADE,
    FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD(id_especialidad) ON DELETE RESTRICT,
    UNIQUE (id_medico, id_especialidad)
)

CONSULTORIO (
    id_consultorio SERIAL PRIMARY KEY,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    piso INTEGER NOT NULL,
    capacidad INTEGER DEFAULT 1,
    equipamiento TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
)

HORARIO_ATENCION (
    id_horario SERIAL PRIMARY KEY,
    id_medico INTEGER NOT NULL,
    id_consultorio INTEGER NOT NULL,
    id_especialidad INTEGER NOT NULL,
    dia_semana VARCHAR(10) NOT NULL CHECK (dia_semana IN ('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO')),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_cita INTEGER NOT NULL DEFAULT 30,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_medico) REFERENCES MEDICO(id_medico) ON DELETE CASCADE,
    FOREIGN KEY (id_consultorio) REFERENCES CONSULTORIO(id_consultorio) ON DELETE RESTRICT,
    FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD(id_especialidad) ON DELETE RESTRICT,
    CHECK (hora_inicio < hora_fin),
    CHECK (duracion_cita > 0)
)

ESTADO_CITA (
    id_estado SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    color VARCHAR(7)
)

CITA (
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
    FOREIGN KEY (id_paciente) REFERENCES PACIENTE(id_paciente) ON DELETE RESTRICT,
    FOREIGN KEY (id_medico) REFERENCES MEDICO(id_medico) ON DELETE RESTRICT,
    FOREIGN KEY (id_consultorio) REFERENCES CONSULTORIO(id_consultorio) ON DELETE RESTRICT,
    FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD(id_especialidad) ON DELETE RESTRICT,
    FOREIGN KEY (id_estado) REFERENCES ESTADO_CITA(id_estado) ON DELETE RESTRICT,
    CHECK (fecha_cita >= CURRENT_DATE),
    CHECK (hora_inicio < hora_fin),
    UNIQUE (id_medico, fecha_cita, hora_inicio),
    UNIQUE (id_consultorio, fecha_cita, hora_inicio)
)

NOTIFICACION (
    id_notificacion SERIAL PRIMARY KEY,
    id_cita INTEGER NOT NULL,
    tipo_notificacion VARCHAR(50) NOT NULL CHECK (tipo_notificacion IN ('CONFIRMACION', 'RECORDATORIO', 'CANCELACION')),
    destinatario_email VARCHAR(100) NOT NULL,
    destinatario_nombre VARCHAR(200) NOT NULL,
    asunto VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    estado_envio VARCHAR(20) NOT NULL CHECK (estado_envio IN ('ENVIADO', 'ERROR', 'PENDIENTE')),
    fecha_envio TIMESTAMP,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    intentos_envio INTEGER DEFAULT 0,
    mensaje_error TEXT,
    FOREIGN KEY (id_cita) REFERENCES CITA(id_cita) ON DELETE CASCADE,
    CHECK (intentos_envio >= 0)
)
```

---

## 5.3. Diccionario de Datos de Tablas

### 5.3.1. Tabla: USUARIO

**Propósito:** Almacenar cuentas de acceso al sistema.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_usuario | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| nombre_usuario | VARCHAR(50) | | | ✓ | ✓ | | Nombre de usuario para login |
| contraseña | VARCHAR(255) | | | ✓ | | | Hash BCrypt de la contraseña |
| email | VARCHAR(100) | | | ✓ | ✓ | | Correo electrónico |
| rol | VARCHAR(20) | | | ✓ | | | Rol del usuario |
| estado | VARCHAR(20) | | | ✓ | | 'ACTIVO' | Estado de la cuenta |
| fecha_creacion | TIMESTAMP | | | ✓ | | NOW() | Fecha de creación |
| ultimo_acceso | TIMESTAMP | | | | | NULL | Último inicio de sesión |

**Restricciones:**
- CHECK: `rol IN ('PACIENTE', 'MEDICO', 'ADMIN')`
- CHECK: `estado IN ('ACTIVO', 'INACTIVO', 'BLOQUEADO')`

**Índices:**
```sql
CREATE INDEX idx_usuario_email ON USUARIO(email);
CREATE INDEX idx_usuario_nombre ON USUARIO(nombre_usuario);
CREATE INDEX idx_usuario_rol ON USUARIO(rol);
```

---

### 5.3.2. Tabla: PACIENTE

**Propósito:** Almacenar información de pacientes.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_paciente | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| dni | CHAR(8) | | | ✓ | ✓ | | DNI del paciente |
| nombres | VARCHAR(100) | | | ✓ | | | Nombres |
| apellido_paterno | VARCHAR(50) | | | ✓ | | | Apellido paterno |
| apellido_materno | VARCHAR(50) | | | ✓ | | | Apellido materno |
| fecha_nacimiento | DATE | | | ✓ | | | Fecha de nacimiento |
| genero | CHAR(1) | | | ✓ | | | Género (M/F/O) |
| direccion | VARCHAR(200) | | | | | NULL | Dirección |
| email | VARCHAR(100) | | | ✓ | ✓ | | Correo electrónico |
| id_usuario | INTEGER | | ✓ | ✓ | ✓ | | FK a USUARIO |
| estado | VARCHAR(20) | | | ✓ | | 'ACTIVO' | Estado |
| fecha_registro | TIMESTAMP | | | ✓ | | NOW() | Fecha de registro |

**Restricciones:**
- CHECK: `genero IN ('M', 'F', 'O')`
- CHECK: `LENGTH(dni) = 8`
- CHECK: `fecha_nacimiento < CURRENT_DATE`

**Índices:**
```sql
CREATE INDEX idx_paciente_dni ON PACIENTE(dni);
CREATE INDEX idx_paciente_email ON PACIENTE(email);
CREATE INDEX idx_paciente_nombres ON PACIENTE(nombres, apellido_paterno, apellido_materno);
CREATE INDEX idx_paciente_usuario ON PACIENTE(id_usuario);
```

---

### 5.3.3. Tabla: PACIENTE_TELEFONO

**Propósito:** Almacenar teléfonos de pacientes (relación 1:N).

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_telefono | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| id_paciente | INTEGER | | ✓ | ✓ | | | FK a PACIENTE |
| numero | VARCHAR(15) | | | ✓ | | | Número telefónico |
| tipo | VARCHAR(20) | | | ✓ | | | Tipo de teléfono |
| es_principal | BOOLEAN | | | | | FALSE | ¿Es el principal? |

**Restricciones:**
- CHECK: `tipo IN ('MOVIL', 'FIJO', 'TRABAJO')`

**Índices:**
```sql
CREATE INDEX idx_telefono_paciente ON PACIENTE_TELEFONO(id_paciente);
```

---

### 5.3.4. Tabla: MEDICO

**Propósito:** Almacenar información de médicos.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_medico | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| dni | CHAR(8) | | | ✓ | ✓ | | DNI del médico |
| nombres | VARCHAR(100) | | | ✓ | | | Nombres |
| apellido_paterno | VARCHAR(50) | | | ✓ | | | Apellido paterno |
| apellido_materno | VARCHAR(50) | | | ✓ | | | Apellido materno |
| numero_colegiatura | VARCHAR(15) | | | ✓ | ✓ | | Número CMP |
| email | VARCHAR(100) | | | ✓ | ✓ | | Correo electrónico |
| telefono | VARCHAR(15) | | | ✓ | | | Teléfono |
| id_usuario | INTEGER | | ✓ | ✓ | ✓ | | FK a USUARIO |
| estado | VARCHAR(20) | | | ✓ | | 'ACTIVO' | Estado |
| fecha_registro | TIMESTAMP | | | ✓ | | NOW() | Fecha de registro |

**Restricciones:**
- CHECK: `numero_colegiatura ~ '^CMP-[0-9]{5}$'` (formato CMP-XXXXX)

**Índices:**
```sql
CREATE INDEX idx_medico_dni ON MEDICO(dni);
CREATE INDEX idx_medico_colegiatura ON MEDICO(numero_colegiatura);
CREATE INDEX idx_medico_nombres ON MEDICO(nombres, apellido_paterno);
CREATE INDEX idx_medico_usuario ON MEDICO(id_usuario);
```

---

### 5.3.5. Tabla: ESPECIALIDAD

**Propósito:** Catálogo de especialidades médicas.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_especialidad | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| codigo | VARCHAR(10) | | | ✓ | ✓ | | Código único |
| nombre | VARCHAR(100) | | | ✓ | ✓ | | Nombre especialidad |
| descripcion | TEXT | | | | | NULL | Descripción |
| estado | VARCHAR(20) | | | ✓ | | 'ACTIVO' | Estado |

**Índices:**
```sql
CREATE INDEX idx_especialidad_codigo ON ESPECIALIDAD(codigo);
CREATE INDEX idx_especialidad_nombre ON ESPECIALIDAD(nombre);
```

---

### 5.3.6. Tabla: MEDICO_ESPECIALIDAD

**Propósito:** Relación N:M entre médicos y especialidades.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_medico_especialidad | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| id_medico | INTEGER | | ✓ | ✓ | | | FK a MEDICO |
| id_especialidad | INTEGER | | ✓ | ✓ | | | FK a ESPECIALIDAD |
| fecha_certificacion | DATE | | | | | NULL | Fecha certificación |
| institucion_certificadora | VARCHAR(200) | | | | | NULL | Institución |

**Restricciones:**
- UNIQUE: `(id_medico, id_especialidad)`

**Índices:**
```sql
CREATE INDEX idx_medico_esp_medico ON MEDICO_ESPECIALIDAD(id_medico);
CREATE INDEX idx_medico_esp_especialidad ON MEDICO_ESPECIALIDAD(id_especialidad);
CREATE UNIQUE INDEX idx_medico_esp_unique ON MEDICO_ESPECIALIDAD(id_medico, id_especialidad);
```

---

### 5.3.7. Tabla: CONSULTORIO

**Propósito:** Almacenar consultorios disponibles.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_consultorio | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| codigo | VARCHAR(10) | | | ✓ | ✓ | | Código consultorio |
| nombre | VARCHAR(100) | | | ✓ | | | Nombre |
| piso | INTEGER | | | ✓ | | | Número de piso |
| capacidad | INTEGER | | | | | 1 | Capacidad personas |
| equipamiento | TEXT | | | | | NULL | Descripción equipo |
| estado | VARCHAR(20) | | | ✓ | | 'ACTIVO' | Estado |

**Índices:**
```sql
CREATE INDEX idx_consultorio_codigo ON CONSULTORIO(codigo);
CREATE INDEX idx_consultorio_piso ON CONSULTORIO(piso);
```

---

### 5.3.8. Tabla: HORARIO_ATENCION

**Propósito:** Horarios de atención de médicos.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_horario | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| id_medico | INTEGER | | ✓ | ✓ | | | FK a MEDICO |
| id_consultorio | INTEGER | | ✓ | ✓ | | | FK a CONSULTORIO |
| id_especialidad | INTEGER | | ✓ | ✓ | | | FK a ESPECIALIDAD |
| dia_semana | VARCHAR(10) | | | ✓ | | | Día de la semana |
| hora_inicio | TIME | | | ✓ | | | Hora inicio |
| hora_fin | TIME | | | ✓ | | | Hora fin |
| duracion_cita | INTEGER | | | ✓ | | 30 | Duración en minutos |
| estado | VARCHAR(20) | | | ✓ | | 'ACTIVO' | Estado |
| fecha_creacion | TIMESTAMP | | | ✓ | | NOW() | Fecha creación |

**Restricciones:**
- CHECK: `hora_inicio < hora_fin`
- CHECK: `duracion_cita > 0`
- CHECK: `dia_semana IN ('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO')`

**Índices:**
```sql
CREATE INDEX idx_horario_medico ON HORARIO_ATENCION(id_medico);
CREATE INDEX idx_horario_consultorio ON HORARIO_ATENCION(id_consultorio);
CREATE INDEX idx_horario_dia ON HORARIO_ATENCION(dia_semana);
CREATE INDEX idx_horario_medico_dia ON HORARIO_ATENCION(id_medico, dia_semana);
```

---

### 5.3.9. Tabla: ESTADO_CITA

**Propósito:** Catálogo de estados de citas (Lookup Table).

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_estado | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| codigo | VARCHAR(20) | | | ✓ | ✓ | | Código estado |
| nombre | VARCHAR(50) | | | ✓ | | | Nombre estado |
| descripcion | TEXT | | | | | NULL | Descripción |
| color | VARCHAR(7) | | | | | NULL | Color hex (#RRGGBB) |

**Datos Precargados:**
```sql
INSERT INTO ESTADO_CITA (id_estado, codigo, nombre, color) VALUES
(1, 'PENDIENTE', 'Pendiente', '#FFA500'),
(2, 'CONFIRMADA', 'Confirmada', '#00FF00'),
(3, 'ATENDIDA', 'Atendida', '#0000FF'),
(4, 'CANCELADA', 'Cancelada', '#FF0000'),
(5, 'NO_PRESENTADO', 'No Presentado', '#808080');
```

---

### 5.3.10. Tabla: CITA

**Propósito:** Almacenar reservas de citas médicas.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_cita | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| codigo_cita | VARCHAR(20) | | | ✓ | ✓ | | Código único cita |
| id_paciente | INTEGER | | ✓ | ✓ | | | FK a PACIENTE |
| id_medico | INTEGER | | ✓ | ✓ | | | FK a MEDICO |
| id_consultorio | INTEGER | | ✓ | ✓ | | | FK a CONSULTORIO |
| id_especialidad | INTEGER | | ✓ | ✓ | | | FK a ESPECIALIDAD |
| id_estado | INTEGER | | ✓ | ✓ | | | FK a ESTADO_CITA |
| fecha_cita | DATE | | | ✓ | | | Fecha de la cita |
| hora_inicio | TIME | | | ✓ | | | Hora inicio |
| hora_fin | TIME | | | ✓ | | | Hora fin |
| motivo_consulta | TEXT | | | ✓ | | | Motivo |
| observaciones | TEXT | | | | | NULL | Observaciones médico |
| motivo_cancelacion | TEXT | | | | | NULL | Motivo cancelación |
| cancelado_por | VARCHAR(20) | | | | | NULL | Quién canceló |
| fecha_registro | TIMESTAMP | | | ✓ | | NOW() | Fecha registro |
| fecha_actualizacion | TIMESTAMP | | | | | NULL | Última actualización |
| recordatorio_enviado | BOOLEAN | | | | | FALSE | Recordatorio enviado |

**Restricciones:**
- CHECK: `fecha_cita >= CURRENT_DATE`
- CHECK: `hora_inicio < hora_fin`
- UNIQUE: `(id_medico, fecha_cita, hora_inicio)`
- UNIQUE: `(id_consultorio, fecha_cita, hora_inicio)`

**Índices:**
```sql
CREATE INDEX idx_cita_paciente ON CITA(id_paciente);
CREATE INDEX idx_cita_medico ON CITA(id_medico);
CREATE INDEX idx_cita_fecha ON CITA(fecha_cita);
CREATE INDEX idx_cita_estado ON CITA(id_estado);
CREATE INDEX idx_cita_codigo ON CITA(codigo_cita);
CREATE INDEX idx_cita_medico_fecha ON CITA(id_medico, fecha_cita);
CREATE INDEX idx_cita_recordatorio ON CITA(recordatorio_enviado, fecha_cita) WHERE recordatorio_enviado = FALSE;
CREATE UNIQUE INDEX idx_cita_medico_horario ON CITA(id_medico, fecha_cita, hora_inicio);
CREATE UNIQUE INDEX idx_cita_consultorio_horario ON CITA(id_consultorio, fecha_cita, hora_inicio);
```

---

### 5.3.11. Tabla: NOTIFICACION

**Propósito:** Registro de notificaciones enviadas.

| Columna | Tipo de Dato | PK | FK | NN | UQ | Default | Descripción |
|---------|--------------|----|----|----|----|---------|-------------|
| id_notificacion | SERIAL | ✓ | | ✓ | ✓ | AUTO | Identificador único |
| id_cita | INTEGER | | ✓ | ✓ | | | FK a CITA |
| tipo_notificacion | VARCHAR(50) | | | ✓ | | | Tipo notificación |
| destinatario_email | VARCHAR(100) | | | ✓ | | | Email destinatario |
| destinatario_nombre | VARCHAR(200) | | | ✓ | | | Nombre destinatario |
| asunto | VARCHAR(200) | | | ✓ | | | Asunto correo |
| mensaje | TEXT | | | ✓ | | | Contenido mensaje |
| estado_envio | VARCHAR(20) | | | ✓ | | | Estado envío |
| fecha_envio | TIMESTAMP | | | | | NULL | Fecha/hora envío |
| fecha_creacion | TIMESTAMP | | | ✓ | | NOW() | Fecha creación |
| intentos_envio | INTEGER | | | | | 0 | Intentos realizados |
| mensaje_error | TEXT | | | | | NULL | Mensaje error |

**Restricciones:**
- CHECK: `tipo_notificacion IN ('CONFIRMACION', 'RECORDATORIO', 'CANCELACION')`
- CHECK: `estado_envio IN ('ENVIADO', 'ERROR', 'PENDIENTE')`
- CHECK: `intentos_envio >= 0`

**Índices:**
```sql
CREATE INDEX idx_notificacion_cita ON NOTIFICACION(id_cita);
CREATE INDEX idx_notificacion_tipo ON NOTIFICACION(tipo_notificacion);
CREATE INDEX idx_notificacion_estado ON NOTIFICACION(estado_envio);
CREATE INDEX idx_notificacion_fecha ON NOTIFICACION(fecha_creacion);
```

---

## 5.4. Normalización de la Base de Datos

### 5.4.1. Primera Forma Normal (1FN)

**Definición:** Una tabla está en 1FN si:
- Todos los atributos son atómicos (no divisibles)
- No hay grupos repetitivos
- Hay una clave primaria

**Aplicación:**

✅ **Todas las tablas cumplen 1FN:**

- **PACIENTE:** Todos los atributos son atómicos
  - ❌ Antes: campo "telefono" con múltiples valores
  - ✅ Después: tabla PACIENTE_TELEFONO (1:N)
  
- **MEDICO:** Especialidades separadas en tabla asociativa
  - ❌ Antes: campo "especialidades" con valores múltiples
  - ✅ Después: tabla MEDICO_ESPECIALIDAD (N:M)

- **CITA:** Todos los atributos son atómicos
  - Fecha y hora en campos separados (fecha_cita, hora_inicio, hora_fin)

### 5.4.2. Segunda Forma Normal (2FN)

**Definición:** Una tabla está en 2FN si:
- Está en 1FN
- Todos los atributos no-clave dependen completamente de la clave primaria (no hay dependencias parciales)

**Aplicación:**

✅ **Todas las tablas cumplen 2FN:**

**Ejemplo - Tabla CITA:**
- Clave primaria: `id_cita`
- Todos los atributos dependen completamente de `id_cita`:
  - `codigo_cita` → depende de `id_cita` ✓
  - `id_paciente` → depende de `id_cita` ✓
  - `fecha_cita` → depende de `id_cita` ✓
  - Etc.

**Ejemplo - Tabla MEDICO_ESPECIALIDAD:**
- Clave primaria compuesta: `(id_medico, id_especialidad)`
- `fecha_certificacion` → depende de ambos (id_medico Y id_especialidad) ✓
- No hay dependencias parciales

### 5.4.3. Tercera Forma Normal (3FN)

**Definición:** Una tabla está en 3FN si:
- Está en 2FN
- No hay dependencias transitivas (ningún atributo no-clave depende de otro atributo no-clave)

**Aplicación:**

✅ **Todas las tablas cumplen 3FN:**

**Análisis de PACIENTE:**
- `edad` NO está almacenada (se calcula desde `fecha_nacimiento`)
  - ❌ Antes: `edad` almacenada (dependencia transitiva: edad → fecha_nacimiento → id_paciente)
  - ✅ Después: `edad` es un atributo derivado calculado en consultas

**Análisis de CITA:**
- Datos del médico NO duplicados:
  - ❌ Antes: `nombre_medico`, `especialidad_nombre` en CITA
  - ✅ Después: Solo `id_medico` (FK), datos se obtienen via JOIN

**Análisis de USUARIO-PACIENTE:**
- Separación correcta:
  - `email` podría estar duplicado entre USUARIO y PACIENTE
  - ✅ Solución: Email en ambos, pero PACIENTE.email es para contacto médico, USUARIO.email es para login
  - Alternativa: Solo en USUARIO, PACIENTE referencia via FK

**Catálogos (Lookup Tables):**
- ESTADO_CITA: Separada para evitar repetición de nombres
  - ❌ Antes: Campo "estado" VARCHAR en CITA con valores repetidos
  - ✅ Después: FK a ESTADO_CITA con id_estado

### 5.4.4. Forma Normal de Boyce-Codd (FNBC)

**Definición:** Una tabla está en FNBC si:
- Está en 3FN
- Para cada dependencia funcional X → Y, X es una superclave

✅ **Las tablas principales cumplen FNBC:**

**Ejemplo - MEDICO_ESPECIALIDAD:**
- Dependencias funcionales:
  - `(id_medico, id_especialidad)` → `fecha_certificacion`
  - `(id_medico, id_especialidad)` es superclave ✓

**Excepción posible - HORARIO_ATENCION:**
- Podría tener dependencia: `(id_medico, dia_semana, hora_inicio)` → `id_consultorio`
- Pero la clave primaria es `id_horario` (simple)
- Para FNBC estricta, la clave debería ser compuesta
- **Decisión de diseño:** Mantener clave simple por simplicidad

### 5.4.5. Resumen de Normalización

| Tabla | 1FN | 2FN | 3FN | FNBC | Observaciones |
|-------|-----|-----|-----|------|---------------|
| USUARIO | ✓ | ✓ | ✓ | ✓ | Totalmente normalizada |
| PACIENTE | ✓ | ✓ | ✓ | ✓ | Edad es derivada, no almacenada |
| PACIENTE_TELEFONO | ✓ | ✓ | ✓ | ✓ | Resuelve multivalor de teléfonos |
| MEDICO | ✓ | ✓ | ✓ | ✓ | Totalmente normalizada |
| ESPECIALIDAD | ✓ | ✓ | ✓ | ✓ | Lookup table |
| MEDICO_ESPECIALIDAD | ✓ | ✓ | ✓ | ✓ | Resuelve N:M |
| CONSULTORIO | ✓ | ✓ | ✓ | ✓ | Totalmente normalizada |
| HORARIO_ATENCION | ✓ | ✓ | ✓ | ~ | Clave simple por diseño |
| ESTADO_CITA | ✓ | ✓ | ✓ | ✓ | Lookup table |
| CITA | ✓ | ✓ | ✓ | ✓ | Totalmente normalizada |
| NOTIFICACION | ✓ | ✓ | ✓ | ✓ | Totalmente normalizada |

---

## 5.5. Índices y Optimización

### 5.5.1. Estrategia de Indexación

Los índices se crean basándose en:
1. **Claves foráneas:** Para optimizar JOINs
2. **Columnas de búsqueda frecuente:** DNI, email, códigos
3. **Columnas de filtrado:** fecha, estado
4. **Columnas de ordenamiento:** nombres, fecha

### 5.5.2. Índices por Tabla

```sql
-- USUARIO
CREATE INDEX idx_usuario_email ON USUARIO(email);
CREATE INDEX idx_usuario_nombre ON USUARIO(nombre_usuario);
CREATE INDEX idx_usuario_rol ON USUARIO(rol);

-- PACIENTE
CREATE INDEX idx_paciente_dni ON PACIENTE(dni);
CREATE INDEX idx_paciente_email ON PACIENTE(email);
CREATE INDEX idx_paciente_nombres ON PACIENTE(nombres, apellido_paterno, apellido_materno);
CREATE INDEX idx_paciente_usuario ON PACIENTE(id_usuario);

-- MEDICO
CREATE INDEX idx_medico_dni ON MEDICO(dni);
CREATE INDEX idx_medico_colegiatura ON MEDICO(numero_colegiatura);
CREATE INDEX idx_medico_nombres ON MEDICO(nombres, apellido_paterno);
CREATE INDEX idx_medico_usuario ON MEDICO(id_usuario);

-- ESPECIALIDAD
CREATE INDEX idx_especialidad_codigo ON ESPECIALIDAD(codigo);
CREATE INDEX idx_especialidad_nombre ON ESPECIALIDAD(nombre);

-- MEDICO_ESPECIALIDAD
CREATE INDEX idx_medico_esp_medico ON MEDICO_ESPECIALIDAD(id_medico);
CREATE INDEX idx_medico_esp_especialidad ON MEDICO_ESPECIALIDAD(id_especialidad);
CREATE UNIQUE INDEX idx_medico_esp_unique ON MEDICO_ESPECIALIDAD(id_medico, id_especialidad);

-- CONSULTORIO
CREATE INDEX idx_consultorio_codigo ON CONSULTORIO(codigo);
CREATE INDEX idx_consultorio_piso ON CONSULTORIO(piso);

-- HORARIO_ATENCION
CREATE INDEX idx_horario_medico ON HORARIO_ATENCION(id_medico);
CREATE INDEX idx_horario_consultorio ON HORARIO_ATENCION(id_consultorio);
CREATE INDEX idx_horario_dia ON HORARIO_ATENCION(dia_semana);
CREATE INDEX idx_horario_medico_dia ON HORARIO_ATENCION(id_medico, dia_semana);

-- CITA
CREATE INDEX idx_cita_paciente ON CITA(id_paciente);
CREATE INDEX idx_cita_medico ON CITA(id_medico);
CREATE INDEX idx_cita_fecha ON CITA(fecha_cita);
CREATE INDEX idx_cita_estado ON CITA(id_estado);
CREATE INDEX idx_cita_codigo ON CITA(codigo_cita);
CREATE INDEX idx_cita_medico_fecha ON CITA(id_medico, fecha_cita);
CREATE INDEX idx_cita_recordatorio ON CITA(recordatorio_enviado, fecha_cita) 
    WHERE recordatorio_enviado = FALSE;

-- NOTIFICACION
CREATE INDEX idx_notificacion_cita ON NOTIFICACION(id_cita);
CREATE INDEX idx_notificacion_tipo ON NOTIFICACION(tipo_notificacion);
CREATE INDEX idx_notificacion_estado ON NOTIFICACION(estado_envio);
```

### 5.5.3. Índices Únicos Compuestos

```sql
-- Evitar conflictos de horario
CREATE UNIQUE INDEX idx_cita_medico_horario 
    ON CITA(id_medico, fecha_cita, hora_inicio);

CREATE UNIQUE INDEX idx_cita_consultorio_horario 
    ON CITA(id_consultorio, fecha_cita, hora_inicio);

-- Evitar especialidades duplicadas por médico
CREATE UNIQUE INDEX idx_medico_esp_unique 
    ON MEDICO_ESPECIALIDAD(id_medico, id_especialidad);
```

### 5.5.4. Índices Parciales (Partial Indexes)

```sql
-- Solo para citas que requieren recordatorio
CREATE INDEX idx_cita_recordatorio 
    ON CITA(recordatorio_enviado, fecha_cita) 
    WHERE recordatorio_enviado = FALSE AND fecha_cita >= CURRENT_DATE;

-- Solo para notificaciones con error
CREATE INDEX idx_notificacion_error 
    ON NOTIFICACION(estado_envio, intentos_envio) 
    WHERE estado_envio = 'ERROR';
```

---

## 5.6. Vistas (Views)

### 5.6.1. Vista: v_citas_completas

**Propósito:** Simplificar consultas de citas con todos los datos relacionados.

```sql
CREATE VIEW v_citas_completas AS
SELECT 
    c.id_cita,
    c.codigo_cita,
    c.fecha_cita,
    c.hora_inicio,
    c.hora_fin,
    c.motivo_consulta,
    c.observaciones,
    
    -- Datos del paciente
    p.id_paciente,
    p.dni AS paciente_dni,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS paciente_nombre_completo,
    p.email AS paciente_email,
    
    -- Datos del médico
    m.id_medico,
    m.numero_colegiatura,
    CONCAT(m.nombres, ' ', m.apellido_paterno, ' ', m.apellido_materno) AS medico_nombre_completo,
    m.email AS medico_email,
    
    -- Datos de la especialidad
    e.id_especialidad,
    e.codigo AS especialidad_codigo,
    e.nombre AS especialidad_nombre,
    
    -- Datos del consultorio
    co.id_consultorio,
    co.codigo AS consultorio_codigo,
    co.nombre AS consultorio_nombre,
    co.piso AS consultorio_piso,
    
    -- Estado de la cita
    ec.id_estado,
    ec.codigo AS estado_codigo,
    ec.nombre AS estado_nombre,
    ec.color AS estado_color,
    
    -- Datos adicionales
    c.fecha_registro,
    c.fecha_actualizacion,
    c.recordatorio_enviado
FROM CITA c
INNER JOIN PACIENTE p ON c.id_paciente = p.id_paciente
INNER JOIN MEDICO m ON c.id_medico = m.id_medico
INNER JOIN ESPECIALIDAD e ON c.id_especialidad = e.id_especialidad
INNER JOIN CONSULTORIO co ON c.id_consultorio = co.id_consultorio
INNER JOIN ESTADO_CITA ec ON c.id_estado = ec.id_estado;
```

### 5.6.2. Vista: v_horarios_disponibles

**Propósito:** Mostrar horarios disponibles de médicos.

```sql
CREATE VIEW v_horarios_disponibles AS
SELECT 
    ha.id_horario,
    ha.dia_semana,
    ha.hora_inicio,
    ha.hora_fin,
    ha.duracion_cita,
    
    -- Datos del médico
    m.id_medico,
    CONCAT(m.nombres, ' ', m.apellido_paterno) AS medico_nombre,
    m.numero_colegiatura,
    
    -- Datos de la especialidad
    e.id_especialidad,
    e.nombre AS especialidad_nombre,
    
    -- Datos del consultorio
    c.id_consultorio,
    c.codigo AS consultorio_codigo,
    c.nombre AS consultorio_nombre,
    c.piso AS consultorio_piso
FROM HORARIO_ATENCION ha
INNER JOIN MEDICO m ON ha.id_medico = m.id_medico
INNER JOIN ESPECIALIDAD e ON ha.id_especialidad = e.id_especialidad
INNER JOIN CONSULTORIO c ON ha.id_consultorio = c.id_consultorio
WHERE ha.estado = 'ACTIVO'
  AND m.estado = 'ACTIVO';
```

### 5.6.3. Vista: v_medicos_con_especialidades

**Propósito:** Listar médicos con sus especialidades.

```sql
CREATE VIEW v_medicos_con_especialidades AS
SELECT 
    m.id_medico,
    m.dni,
    CONCAT(m.nombres, ' ', m.apellido_paterno, ' ', m.apellido_materno) AS nombre_completo,
    m.numero_colegiatura,
    m.email,
    m.telefono,
    m.estado,
    
    -- Especialidades (agregadas)
    STRING_AGG(e.nombre, ', ') AS especialidades,
    COUNT(me.id_especialidad) AS cantidad_especialidades
FROM MEDICO m
LEFT JOIN MEDICO_ESPECIALIDAD me ON m.id_medico = me.id_medico
LEFT JOIN ESPECIALIDAD e ON me.id_especialidad = e.id_especialidad
WHERE m.estado = 'ACTIVO'
GROUP BY m.id_medico, m.dni, m.nombres, m.apellido_paterno, m.apellido_materno, 
         m.numero_colegiatura, m.email, m.telefono, m.estado;
```

---

## 5.7. Tamaño Estimado de la Base de Datos

### 5.7.1. Estimación de Registros

| Tabla | Registros Iniciales | Crecimiento Anual | Tamaño por Registro |
|-------|-------------------|-------------------|---------------------|
| USUARIO | 500 | 1,000 | 200 bytes |
| PACIENTE | 400 | 800 | 300 bytes |
| PACIENTE_TELEFONO | 600 | 1,200 | 50 bytes |
| MEDICO | 50 | 10 | 250 bytes |
| ESPECIALIDAD | 30 | 2 | 150 bytes |
| MEDICO_ESPECIALIDAD | 75 | 15 | 80 bytes |
| CONSULTORIO | 20 | 2 | 200 bytes |
| HORARIO_ATENCION | 200 | 20 | 150 bytes |
| ESTADO_CITA | 5 | 0 | 100 bytes |
| CITA | 1,000 | 12,000 | 400 bytes |
| NOTIFICACION | 3,000 | 36,000 | 500 bytes |

### 5.7.2. Cálculo de Espacio

**Primer Año:**
- CITA: 1,000 + 12,000 = 13,000 registros × 400 bytes ≈ **5.2 MB**
- NOTIFICACION: 3,000 + 36,000 = 39,000 registros × 500 bytes ≈ **19.5 MB**
- Otras tablas: ≈ **2 MB**
- **Total estimado:** ~27 MB (sin índices)

**Con índices:** ~50 MB  
**Después de 5 años:** ~250 MB

---

[⬅️ Anterior: Diseño Conceptual](04-diseño-conceptual.md) | [Volver al índice](README.md) | [Siguiente: Implementación BD ➡️](06-implementacion-bd.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div> 