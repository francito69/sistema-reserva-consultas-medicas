# 4. Diseño Conceptual

## Sistema de Reserva de Consultas Médicas Externas

---

## 4.1. Introducción

El diseño conceptual representa la estructura de datos del sistema de manera independiente de la tecnología de implementación. En esta fase se utiliza el **Modelo Entidad-Relación (ER)** para representar las entidades del dominio, sus atributos y las relaciones entre ellas.

Este modelo sirve como puente entre los requerimientos del sistema y el diseño lógico de la base de datos.

---

## 4.2. Diagrama Entidad-Relación (ER)

### 4.2.1. Diagrama ER Completo

**Ubicación:** [diagramas/diagrama-er-conceptual.png](../diagramas/diagrama-er-conceptual.png)

El diagrama muestra las siguientes entidades y sus relaciones:

```
                    ┌──────────────┐
                    │   USUARIO    │
                    └──────┬───────┘
                           │
                           │ hereda
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐    ┌──────────────┐   ┌──────────────┐
│   PACIENTE   │    │    MÉDICO    │   │ADMINISTRADOR │
└──────┬───────┘    └──────┬───────┘   └──────────────┘
       │                   │
       │ realiza           │ atiende
       │                   │
       │            ┌──────┴───────┐
       │            │ tiene        │
       │            ▼              │
       │      ┌──────────────┐    │
       │      │   HORARIO    │    │
       │      │   ATENCION   │    │
       │      └──────┬───────┘    │
       │             │ usa        │
       │             ▼            │
       │      ┌──────────────┐   │
       │      │ CONSULTORIO  │   │
       │      └──────────────┘   │
       │                         │
       └────────────┐    ┌───────┘
                    ▼    ▼
              ┌──────────────┐
              │     CITA     │
              └──────┬───────┘
                     │ tiene
                     ▼
              ┌──────────────┐
              │ ESTADO_CITA  │
              └──────────────┘
                     
┌──────────────┐          ┌──────────────┐
│ ESPECIALIDAD │◄─────────┤    MÉDICO    │
└──────────────┘  tiene   └──────────────┘

┌──────────────┐          ┌──────────────┐
│NOTIFICACION  │◄─────────┤     CITA     │
└──────────────┘ genera  └──────────────┘
```

---

## 4.3. Entidades del Sistema

### 4.3.1. Entidad: USUARIO

**Descripción:** Representa a cualquier persona que tiene acceso al sistema.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_usuario** | Entero | Identificador único del usuario | PK, Autoincremental |
| nombre_usuario | Cadena(50) | Nombre de usuario para login | NOT NULL, UNIQUE |
| contraseña | Cadena(255) | Contraseña encriptada | NOT NULL |
| email | Cadena(100) | Correo electrónico | NOT NULL, UNIQUE |
| rol | Cadena(20) | Rol del usuario | NOT NULL, IN ('PACIENTE', 'MEDICO', 'ADMIN') |
| estado | Cadena(20) | Estado de la cuenta | NOT NULL, DEFAULT 'ACTIVO' |
| fecha_creacion | Fecha/Hora | Fecha de registro | NOT NULL, DEFAULT NOW() |
| ultimo_acceso | Fecha/Hora | Última vez que inició sesión | NULL |

**Clave Primaria:** id_usuario

**Claves Candidatas:** 
- nombre_usuario
- email

---

### 4.3.2. Entidad: PACIENTE

**Descripción:** Representa a una persona que solicita servicios médicos.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_paciente** | Entero | Identificador único del paciente | PK, Autoincremental |
| dni | Cadena(8) | Documento Nacional de Identidad | NOT NULL, UNIQUE |
| nombres | Cadena(100) | Nombres del paciente | NOT NULL |
| apellido_paterno | Cadena(50) | Apellido paterno | NOT NULL |
| apellido_materno | Cadena(50) | Apellido materno | NOT NULL |
| fecha_nacimiento | Fecha | Fecha de nacimiento | NOT NULL |
| genero | Cadena(1) | Género | NOT NULL, IN ('M', 'F', 'O') |
| direccion | Cadena(200) | Dirección de residencia | NULL |
| email | Cadena(100) | Correo electrónico | NOT NULL, UNIQUE |
| id_usuario | Entero | Referencia a usuario | FK NOT NULL, UNIQUE |
| estado | Cadena(20) | Estado del paciente | NOT NULL, DEFAULT 'ACTIVO' |
| fecha_registro | Fecha/Hora | Fecha de registro | NOT NULL, DEFAULT NOW() |

**Clave Primaria:** id_paciente

**Claves Foráneas:**
- id_usuario → USUARIO(id_usuario)

**Claves Candidatas:**
- dni
- email

**Atributos Derivados:**
- edad (calculada desde fecha_nacimiento)

---

### 4.3.3. Entidad: PACIENTE_TELEFONO

**Descripción:** Entidad débil que almacena los números de teléfono de un paciente (relación 1:N).

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_telefono** | Entero | Identificador del teléfono | PK, Autoincremental |
| id_paciente | Entero | Referencia al paciente | FK NOT NULL |
| numero | Cadena(15) | Número de teléfono | NOT NULL |
| tipo | Cadena(20) | Tipo de teléfono | NOT NULL, IN ('MOVIL', 'FIJO', 'TRABAJO') |
| es_principal | Booleano | Indica si es el número principal | DEFAULT FALSE |

**Clave Primaria:** id_telefono

**Claves Foráneas:**
- id_paciente → PACIENTE(id_paciente)

---

### 4.3.4. Entidad: MEDICO

**Descripción:** Representa a un profesional de la salud que atiende consultas.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_medico** | Entero | Identificador único del médico | PK, Autoincremental |
| dni | Cadena(8) | Documento Nacional de Identidad | NOT NULL, UNIQUE |
| nombres | Cadena(100) | Nombres del médico | NOT NULL |
| apellido_paterno | Cadena(50) | Apellido paterno | NOT NULL |
| apellido_materno | Cadena(50) | Apellido materno | NOT NULL |
| numero_colegiatura | Cadena(15) | Número CMP | NOT NULL, UNIQUE |
| email | Cadena(100) | Correo electrónico | NOT NULL, UNIQUE |
| telefono | Cadena(15) | Número de teléfono | NOT NULL |
| id_usuario | Entero | Referencia a usuario | FK NOT NULL, UNIQUE |
| estado | Cadena(20) | Estado del médico | NOT NULL, DEFAULT 'ACTIVO' |
| fecha_registro | Fecha/Hora | Fecha de registro | NOT NULL, DEFAULT NOW() |

**Clave Primaria:** id_medico

**Claves Foráneas:**
- id_usuario → USUARIO(id_usuario)

**Claves Candidatas:**
- dni
- numero_colegiatura
- email

---

### 4.3.5. Entidad: ESPECIALIDAD

**Descripción:** Catálogo de especialidades médicas.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_especialidad** | Entero | Identificador de la especialidad | PK, Autoincremental |
| codigo | Cadena(10) | Código único de la especialidad | NOT NULL, UNIQUE |
| nombre | Cadena(100) | Nombre de la especialidad | NOT NULL, UNIQUE |
| descripcion | Texto | Descripción detallada | NULL |
| estado | Cadena(20) | Estado de la especialidad | NOT NULL, DEFAULT 'ACTIVO' |

**Clave Primaria:** id_especialidad

**Claves Candidatas:**
- codigo
- nombre

**Ejemplos:**
- Cardiología
- Pediatría
- Dermatología
- Traumatología
- Medicina General

---

### 4.3.6. Entidad: MEDICO_ESPECIALIDAD

**Descripción:** Entidad asociativa que relaciona médicos con especialidades (relación N:M).

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_medico_especialidad** | Entero | Identificador | PK, Autoincremental |
| id_medico | Entero | Referencia al médico | FK NOT NULL |
| id_especialidad | Entero | Referencia a la especialidad | FK NOT NULL |
| fecha_certificacion | Fecha | Fecha de certificación | NULL |
| institucion_certificadora | Cadena(200) | Institución que certificó | NULL |

**Clave Primaria:** id_medico_especialidad

**Claves Foráneas:**
- id_medico → MEDICO(id_medico)
- id_especialidad → ESPECIALIDAD(id_especialidad)

**Restricción Única:** (id_medico, id_especialidad) - Un médico no puede tener la misma especialidad duplicada

---

### 4.3.7. Entidad: CONSULTORIO

**Descripción:** Representa los espacios físicos donde se atienden las consultas.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_consultorio** | Entero | Identificador del consultorio | PK, Autoincremental |
| codigo | Cadena(10) | Código del consultorio | NOT NULL, UNIQUE |
| nombre | Cadena(100) | Nombre del consultorio | NOT NULL |
| piso | Entero | Número de piso | NOT NULL |
| capacidad | Entero | Capacidad de personas | DEFAULT 1 |
| equipamiento | Texto | Descripción del equipamiento | NULL |
| estado | Cadena(20) | Estado del consultorio | NOT NULL, DEFAULT 'ACTIVO' |

**Clave Primaria:** id_consultorio

**Claves Candidatas:**
- codigo

**Ejemplos:**
- CONS-101 (Piso 1, Consultorio de Cardiología)
- CONS-201 (Piso 2, Consultorio de Pediatría)

---

### 4.3.8. Entidad: HORARIO_ATENCION

**Descripción:** Define los horarios en que un médico atiende en un consultorio específico.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_horario** | Entero | Identificador del horario | PK, Autoincremental |
| id_medico | Entero | Referencia al médico | FK NOT NULL |
| id_consultorio | Entero | Referencia al consultorio | FK NOT NULL |
| id_especialidad | Entero | Especialidad con la que atiende | FK NOT NULL |
| dia_semana | Cadena(10) | Día de la semana | NOT NULL, IN ('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO') |
| hora_inicio | Hora | Hora de inicio de atención | NOT NULL |
| hora_fin | Hora | Hora de fin de atención | NOT NULL |
| duracion_cita | Entero | Duración en minutos de cada cita | NOT NULL, DEFAULT 30 |
| estado | Cadena(20) | Estado del horario | NOT NULL, DEFAULT 'ACTIVO' |
| fecha_creacion | Fecha/Hora | Fecha de creación del horario | NOT NULL, DEFAULT NOW() |

**Clave Primaria:** id_horario

**Claves Foráneas:**
- id_medico → MEDICO(id_medico)
- id_consultorio → CONSULTORIO(id_consultorio)
- id_especialidad → ESPECIALIDAD(id_especialidad)

**Restricciones:**
- CHECK: hora_inicio < hora_fin
- UNIQUE: No puede haber dos horarios del mismo médico que se traslapen
- UNIQUE: No puede haber dos horarios diferentes en el mismo consultorio que se traslapen

---

### 4.3.9. Entidad: ESTADO_CITA

**Descripción:** Catálogo de estados posibles de una cita (Lookup Table).

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_estado** | Entero | Identificador del estado | PK |
| codigo | Cadena(20) | Código del estado | NOT NULL, UNIQUE |
| nombre | Cadena(50) | Nombre descriptivo del estado | NOT NULL |
| descripcion | Texto | Descripción del estado | NULL |
| color | Cadena(7) | Color hexadecimal para UI | NULL |

**Clave Primaria:** id_estado

**Valores Predefinidos:**
1. PENDIENTE - Cita recién creada
2. CONFIRMADA - Cita confirmada por el sistema
3. ATENDIDA - Paciente fue atendido
4. CANCELADA - Cita fue cancelada
5. NO_PRESENTADO - Paciente no asistió a la cita

---

### 4.3.10. Entidad: CITA

**Descripción:** Representa una reserva de consulta médica.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_cita** | Entero | Identificador único de la cita | PK, Autoincremental |
| codigo_cita | Cadena(20) | Código único de cita | NOT NULL, UNIQUE |
| id_paciente | Entero | Referencia al paciente | FK NOT NULL |
| id_medico | Entero | Referencia al médico | FK NOT NULL |
| id_consultorio | Entero | Referencia al consultorio | FK NOT NULL |
| id_especialidad | Entero | Especialidad de la consulta | FK NOT NULL |
| id_estado | Entero | Estado actual de la cita | FK NOT NULL |
| fecha_cita | Fecha | Fecha de la cita | NOT NULL |
| hora_inicio | Hora | Hora de inicio de la cita | NOT NULL |
| hora_fin | Hora | Hora de fin de la cita | NOT NULL |
| motivo_consulta | Texto | Motivo de la consulta | NOT NULL |
| observaciones | Texto | Observaciones del médico | NULL |
| motivo_cancelacion | Texto | Motivo de cancelación (si aplica) | NULL |
| cancelado_por | Cadena(20) | Quién canceló (PACIENTE/MEDICO) | NULL |
| fecha_registro | Fecha/Hora | Fecha de registro de la cita | NOT NULL, DEFAULT NOW() |
| fecha_actualizacion | Fecha/Hora | Última actualización | NULL |
| recordatorio_enviado | Booleano | Si se envió recordatorio | DEFAULT FALSE |

**Clave Primaria:** id_cita

**Claves Foráneas:**
- id_paciente → PACIENTE(id_paciente)
- id_medico → MEDICO(id_medico)
- id_consultorio → CONSULTORIO(id_consultorio)
- id_especialidad → ESPECIALIDAD(id_especialidad)
- id_estado → ESTADO_CITA(id_estado)

**Claves Candidatas:**
- codigo_cita

**Restricciones:**
- CHECK: fecha_cita >= CURRENT_DATE
- CHECK: hora_inicio < hora_fin
- UNIQUE: (id_medico, fecha_cita, hora_inicio) - Un médico no puede tener dos citas simultáneas
- UNIQUE: (id_consultorio, fecha_cita, hora_inicio) - Un consultorio solo puede usarse por una cita a la vez

---

### 4.3.11. Entidad: NOTIFICACION

**Descripción:** Registro de notificaciones enviadas a los usuarios.

**Atributos:**

| Atributo | Tipo | Descripción | Restricciones |
|----------|------|-------------|---------------|
| **id_notificacion** | Entero | Identificador de la notificación | PK, Autoincremental |
| id_cita | Entero | Referencia a la cita | FK NOT NULL |
| tipo_notificacion | Cadena(50) | Tipo de notificación | NOT NULL, IN ('CONFIRMACION', 'RECORDATORIO', 'CANCELACION') |
| destinatario_email | Cadena(100) | Email del destinatario | NOT NULL |
| destinatario_nombre | Cadena(200) | Nombre del destinatario | NOT NULL |
| asunto | Cadena(200) | Asunto del correo | NOT NULL |
| mensaje | Texto | Contenido del mensaje | NOT NULL |
| estado_envio | Cadena(20) | Estado del envío | NOT NULL, IN ('ENVIADO', 'ERROR', 'PENDIENTE') |
| fecha_envio | Fecha/Hora | Fecha/hora de envío | NULL |
| fecha_creacion | Fecha/Hora | Fecha de creación | NOT NULL, DEFAULT NOW() |
| intentos_envio | Entero | Número de intentos de envío | DEFAULT 0 |
| mensaje_error | Texto | Descripción del error (si aplica) | NULL |

**Clave Primaria:** id_notificacion

**Claves Foráneas:**
- id_cita → CITA(id_cita)

---

## 4.4. Relaciones entre Entidades

### 4.4.1. Tabla de Relaciones

| Relación | Entidad 1 | Entidad 2 | Cardinalidad | Descripción |
|----------|-----------|-----------|--------------|-------------|
| **R1** | USUARIO | PACIENTE | 1:1 | Un usuario puede ser un paciente |
| **R2** | USUARIO | MEDICO | 1:1 | Un usuario puede ser un médico |
| **R3** | PACIENTE | PACIENTE_TELEFONO | 1:N | Un paciente puede tener varios teléfonos |
| **R4** | MEDICO | MEDICO_ESPECIALIDAD | 1:N | Un médico puede tener varias especialidades |
| **R5** | ESPECIALIDAD | MEDICO_ESPECIALIDAD | 1:N | Una especialidad puede tener varios médicos |
| **R6** | MEDICO | HORARIO_ATENCION | 1:N | Un médico puede tener varios horarios |
| **R7** | CONSULTORIO | HORARIO_ATENCION | 1:N | Un consultorio puede tener varios horarios |
| **R8** | ESPECIALIDAD | HORARIO_ATENCION | 1:N | Una especialidad puede tener varios horarios |
| **R9** | PACIENTE | CITA | 1:N | Un paciente puede tener varias citas |
| **R10** | MEDICO | CITA | 1:N | Un médico puede tener varias citas |
| **R11** | CONSULTORIO | CITA | 1:N | Un consultorio puede albergar varias citas |
| **R12** | ESPECIALIDAD | CITA | 1:N | Una especialidad puede tener varias citas |
| **R13** | ESTADO_CITA | CITA | 1:N | Un estado puede aplicar a varias citas |
| **R14** | CITA | NOTIFICACION | 1:N | Una cita puede generar varias notificaciones |

---

### 4.4.2. Descripción Detallada de Relaciones

#### R1: USUARIO - PACIENTE (1:1)
- **Descripción:** Un usuario con rol "PACIENTE" tiene un perfil de paciente asociado.
- **Participación:** Obligatoria en ambos lados
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Cada paciente debe tener exactamente un usuario asociado.

#### R2: USUARIO - MEDICO (1:1)
- **Descripción:** Un usuario con rol "MEDICO" tiene un perfil de médico asociado.
- **Participación:** Obligatoria en ambos lados
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Cada médico debe tener exactamente un usuario asociado.

#### R3: PACIENTE - PACIENTE_TELEFONO (1:N)
- **Descripción:** Un paciente puede registrar uno o más números telefónicos.
- **Participación:** Obligatoria por PACIENTE, Total por PACIENTE_TELEFONO
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Todo paciente debe tener al menos un teléfono registrado.

#### R4 y R5: MEDICO ↔ ESPECIALIDAD (N:M a través de MEDICO_ESPECIALIDAD)
- **Descripción:** Un médico puede tener múltiples especialidades y una especialidad puede ser ejercida por múltiples médicos.
- **Participación:** Obligatoria - Todo médico debe tener al menos una especialidad.
- **Atributos de la relación:** fecha_certificacion, institucion_certificadora
- **Regla de negocio:** No se pueden duplicar especialidades para el mismo médico.

#### R6: MEDICO - HORARIO_ATENCION (1:N)
- **Descripción:** Un médico configura múltiples horarios de atención.
- **Participación:** Opcional por MEDICO, Obligatoria por HORARIO_ATENCION
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Los horarios del mismo médico no pueden traslaparse.

#### R7: CONSULTORIO - HORARIO_ATENCION (1:N)
- **Descripción:** Un consultorio puede ser usado en múltiples horarios.
- **Participación:** Opcional por CONSULTORIO, Obligatoria por HORARIO_ATENCION
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** No puede haber dos horarios simultáneos en el mismo consultorio.

#### R8: ESPECIALIDAD - HORARIO_ATENCION (1:N)
- **Descripción:** Los horarios están asociados a una especialidad específica.
- **Participación:** Opcional por ESPECIALIDAD, Obligatoria por HORARIO_ATENCION
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** La especialidad del horario debe estar entre las especialidades del médico.

#### R9: PACIENTE - CITA (1:N)
- **Descripción:** Un paciente puede tener múltiples citas.
- **Participación:** Opcional por PACIENTE, Obligatoria por CITA
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Un paciente no puede tener más de 3 citas pendientes simultáneamente.

#### R10: MEDICO - CITA (1:N)
- **Descripción:** Un médico puede atender múltiples citas.
- **Participación:** Opcional por MEDICO, Obligatoria por CITA
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Un médico no puede tener dos citas simultáneas.

#### R11: CONSULTORIO - CITA (1:N)
- **Descripción:** Un consultorio alberga múltiples citas.
- **Participación:** Opcional por CONSULTORIO, Obligatoria por CITA
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Un consultorio no puede tener dos citas simultáneas.

#### R12: ESPECIALIDAD - CITA (1:N)
- **Descripción:** Las citas están asociadas a una especialidad.
- **Participación:** Opcional por ESPECIALIDAD, Obligatoria por CITA
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** La especialidad de la cita debe corresponder con una especialidad del médico.

#### R13: ESTADO_CITA - CITA (1:N)
- **Descripción:** Cada cita tiene un estado actual.
- **Participación:** Obligatoria en ambos lados
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** El estado por defecto de una nueva cita es "PENDIENTE".

#### R14: CITA - NOTIFICACION (1:N)
- **Descripción:** Una cita puede generar múltiples notificaciones (confirmación, recordatorio, cancelación).
- **Participación:** Opcional por CITA, Obligatoria por NOTIFICACION
- **Atributos de la relación:** Ninguno
- **Regla de negocio:** Se deben enviar notificaciones en eventos clave (confirmación, 24h antes, cancelación).

---

## 4.5. Restricciones de Integridad

### 4.5.1. Restricciones de Dominio

| Entidad | Atributo | Restricción |
|---------|----------|-------------|
| PACIENTE | dni | LENGTH = 8, NUMERIC |
| PACIENTE | genero | IN ('M', 'F', 'O') |
| PACIENTE | email | FORMAT EMAIL VÁLIDO |
| MEDICO | dni | LENGTH = 8, NUMERIC |
| MEDICO | numero_colegiatura | PATTERN 'CMP-[0-9]{5}' |
| HORARIO_ATENCION | dia_semana | IN ('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO') |
| HORARIO_ATENCION | duracion_cita | > 0, MÚLTIPLO DE 15 |
| CITA | fecha_cita | >= CURRENT_DATE |
| NOTIFICACION | tipo_notificacion | IN ('CONFIRMACION', 'RECORDATORIO', 'CANCELACION') |
| NOTIFICACION | estado_envio | IN ('ENVIADO', 'ERROR', 'PENDIENTE') |

### 4.5.2. Restricciones de Integridad Referencial

Todas las claves foráneas deben mantener integridad referencial:

- **ON DELETE:** Depende de la relación
  - USUARIO → PACIENTE/MEDICO: CASCADE (si se elimina usuario, se elimina el perfil)
  - PACIENTE/MEDICO → CITA: RESTRICT (no se puede eliminar si tiene citas)
  - ESTADO_CITA → CITA: RESTRICT (no se pueden eliminar estados en uso)
  
- **ON UPDATE:** CASCADE (las actualizaciones se propagan)

### 4.5.3. Restricciones de Unicidad

| Entidad | Atributos | Descripción |
|---------|-----------|-------------|
| USUARIO | nombre_usuario | No puede haber usuarios duplicados |
| USUARIO | email | No puede haber emails duplicados |
| PACIENTE | dni | No puede haber DNIs duplicados |
| MEDICO | numero_colegiatura | No puede haber números de colegiatura duplicados |
| ESPECIALIDAD | codigo | Códigos únicos para especialidades |
| CITA | codigo_cita | Códigos únicos de cita |
| CITA | (id_medico, fecha_cita, hora_inicio) | Un médico no puede tener dos citas simultáneas |

### 4.5.4. Restricciones de Verificación (CHECK)

```sql
-- HORARIO_ATENCION
CHECK (hora_inicio < hora_fin)
CHECK (duracion_cita > 0)

-- CITA
CHECK (fecha_cita >= CURRENT_DATE)
CHECK (hora_inicio < hora_fin)

-- PACIENTE
CHECK (LENGTH(dni) = 8)
CHECK (edad >= 0 AND edad <= 120)

-- NOTIFICACION
CHECK (intentos_envio >= 0)
```

---

## 4.6. Reglas de Negocio Implementadas en el Modelo

### RN01: Validación de Disponibilidad
- Un médico no puede tener dos citas en el mismo horario
- Un consultorio no puede ser usado por dos citas simultáneamente
- **Implementación:** Restricción UNIQUE en CITA sobre (id_medico, fecha_cita, hora_inicio)

### RN02: Horarios de Atención
- Los horarios de un médico no pueden traslaparse
- **Implementación:** Trigger para validar traslapes al insertar/actualizar HORARIO_ATENCION

### RN03: Estados de Cita
- Una cita nueva se crea en estado "PENDIENTE"
- Solo puede cambiar a "CONFIRMADA", "ATENDIDA", "CANCELADA" o "NO_PRESENTADO"
- **Implementación:** Default value + Trigger para validar transiciones de estado

### RN04: Notificaciones Automáticas
- Se debe enviar notificación al confirmar una cita
- Se debe enviar recordatorio 24 horas antes
- Se debe enviar notificación al cancelar
- **Implementación:** Triggers en tabla CITA que insertan en NOTIFICACION

### RN05: Especialidad del Médico
- Un médico solo puede atender citas de especialidades que tiene registradas
- **Implementación:** Validación mediante trigger que verifica MEDICO_ESPECIALIDAD

### RN06: Límite de Citas Pendientes
- Un paciente no puede tener más de 3 citas en estado "PENDIENTE" o "CONFIRMADA"
- **Implementación:** Trigger BEFORE INSERT en CITA

---

## 4.7. Diccionario de Datos Conceptual

### 4.7.1. Resumen de Entidades

| # | Entidad | Tipo | Descripción | Cantidad de Atributos |
|---|---------|------|-------------|----------------------|
| 1 | USUARIO | Fuerte | Cuenta de acceso al sistema | 8 |
| 2 | PACIENTE | Fuerte | Persona que solicita servicios médicos | 12 |
| 3 | PACIENTE_TELEFONO | Débil | Teléfonos del paciente | 5 |
| 4 | MEDICO | Fuerte | Profesional de la salud | 11 |
| 5 | ESPECIALIDAD | Fuerte | Catálogo de especialidades médicas | 5 |
| 6 | MEDICO_ESPECIALIDAD | Asociativa | Relación médico-especialidad | 5 |
| 7 | CONSULTORIO | Fuerte | Espacio físico de atención | 7 |
| 8 | HORARIO_ATENCION | Fuerte | Agenda de atención del médico | 10 |
| 9 | ESTADO_CITA | Lookup | Catálogo de estados de cita | 5 |
| 10 | CITA | Fuerte | Reserva de consulta médica | 17 |
| 11 | NOTIFICACION | Fuerte | Registro de notificaciones enviadas | 12 |

**Total de Entidades:** 11

---

## 4.8. Diagrama de Objetos (Instancias de Ejemplo)

**Ubicación:** [diagramas/diagrama-objetos.png](../diagramas/diagrama-objetos.png)

El diagrama de objetos muestra ejemplos concretos de instancias:

**Ejemplo de Instancias:**

```
PACIENTE #1001
- dni: "12345678"
- nombres: "Juan Carlos"
- apellido_paterno: "Pérez"
- apellido_materno: "García"
- email: "juan.perez@email.com"

MEDICO #2001
- dni: "87654321"
- nombres: "María Elena"
- apellido_paterno: "López"
- numero_colegiatura: "CMP-45678"

ESPECIALIDAD #3001
- codigo: "CARD-01"
- nombre: "Cardiología"

CITA #4001
- codigo_cita: "CITA-2025-001"
- id_paciente: 1001
- id_medico: 2001
- fecha_cita: "2025-11-15"
- hora_inicio: "09:00"
- estado: "CONFIRMADA"
```

---

## 4.9. Ventajas del Modelo Conceptual

1. **Independencia de Tecnología:** No está atado a PostgreSQL o cualquier DBMS específico
2. **Claridad:** Representa el dominio del negocio de forma comprensible
3. **Comunicación:** Facilita discusiones con stakeholders no técnicos
4. **Base para el Diseño Lógico:** Sirve como fundamento para el modelo relacional
5. **Documentación:** Proporciona documentación visual del sistema
6. **Validación:** Permite validar que se capturan todos los requerimientos

---

## 4.10. Consideraciones de Diseño

### 4.10.1. Decisiones de Diseño

**Decisión 1: Separación de Usuario y Roles**
- **Razón:** Permite que una persona pueda ser tanto paciente como médico (aunque raro)
- **Alternativa descartada:** Tener tablas separadas sin herencia

**Decisión 2: Tabla de Teléfonos Separada**
- **Razón:** Un paciente puede tener múltiples teléfonos (móvil, casa, trabajo)
- **Alternativa descartada:** Campos telefono1, telefono2, telefono3 en PACIENTE

**Decisión 3: Entidad MEDICO_ESPECIALIDAD**
- **Razón:** Relación N:M requiere tabla asociativa, permite agregar atributos adicionales
- **Alternativa descartada:** Campo especialidad_principal en MEDICO

**Decisión 4: ESTADO_CITA como Lookup Table**
- **Razón:** Los estados son valores predefinidos que rara vez cambian
- **Alternativa descartada:** Campo ENUM en CITA

**Decisión 5: Código Único de Cita**
- **Razón:** Facilita búsqueda y referencia para usuarios (más amigable que ID numérico)
- **Formato:** CITA-YYYY-NNNN

### 4.10.2. Escalabilidad del Modelo

El modelo está diseñado para escalar:
- ✅ Puede manejar miles de pacientes y médicos
- ✅ Soporta múltiples especialidades por médico
- ✅ Permite horarios complejos y variables
- ✅ Registro completo de historial (no elimina citas)

---

[⬅️ Anterior: Especificación de Requisitos](03-especificacion-requisitos.md) | [Volver al índice](README.md) | [Siguiente: Diseño Lógico ➡️](05-diseño-logico.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div>