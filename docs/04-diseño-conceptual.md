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
# 4.8.0 Diagrama de Clases - Sistema de Reserva de Consultas Médicas
ubicacion: [diagramas/diagrama-clases.png](../diagramas/diagrama-clases.png)

## 📖 Descripción General

El diagrama de clases representa la **estructura estática** del sistema de reserva de consultas médicas externas. Este diagrama muestra todas las clases del sistema, sus atributos, métodos y las relaciones entre ellas, proporcionando una visión completa de la arquitectura del software.

## 🎯 Propósito del Diagrama

El diagrama tiene como objetivo:

1. **Definir la estructura** de todas las clases del sistema
2. **Establecer las relaciones** entre las diferentes entidades
3. **Especificar atributos y métodos** de cada clase
4. **Servir como base** para la implementación del código
5. **Documentar la arquitectura** del sistema

## 🏗️ Arquitectura del Sistema

El sistema está organizado en **7 paquetes principales**:

### 1. **Gestión de Usuarios** 👥
Maneja todos los tipos de usuarios del sistema.

### 2. **Gestión de Citas** 📅
Controla el proceso de reserva y seguimiento de citas médicas.

### 3. **Gestión de Especialidades** 🏥
Administra las especialidades médicas disponibles.

### 4. **Gestión de Historia Clínica** 📋
Mantiene el registro médico completo de los pacientes.

### 5. **Gestión de Facturación** 💰
Procesa pagos y genera facturas.

### 6. **Sistema de Notificaciones** 📧
Envía recordatorios y alertas a usuarios.

### 7. **Clase Sistema** ⚙️
Clase principal que coordina todo el sistema.

---

## 📦 Descripción Detallada de Paquetes y Clases

## 1️⃣ Package: Gestión de Usuarios

### Clase Abstracta: **Usuario**

**Descripción:** Clase base abstracta que define las características comunes de todos los usuarios del sistema.

**Atributos:**
- `# dni: String` - Documento Nacional de Identidad (único)
- `# nombre: String` - Nombre del usuario
- `# apellidos: String` - Apellidos del usuario
- `# fechaNacimiento: Date` - Fecha de nacimiento
- `# sexo: char` - Sexo del usuario (M/F)
- `# email: String` - Correo electrónico (único)
- `# telefono: String` - Número de teléfono
- `# direccion: String` - Dirección de domicilio
- `# fechaRegistro: Date` - Fecha de registro en el sistema

**Métodos:**
- `+ {abstract} iniciarSesion(usuario: String, password: String): boolean`
- `+ actualizarDatos(): void`
- `+ validarDatos(): boolean`
- `+ obtenerNombreCompleto(): String`

**Relaciones:**
- Es **generalizada** por: Paciente, Medico, Administrador

---

### Clase: **Paciente** (hereda de Usuario)

**Descripción:** Representa a los pacientes que solicitan citas médicas.

**Atributos Adicionales:**
- `- numeroHistoriaClinica: String` - Número único de historia clínica
- `- estadoCuenta: String` - Estado de la cuenta (Activa/Inactiva)
- `- fotoPerfil: Image` - Foto de perfil del paciente

**Métodos:**
- `+ registrarse(): boolean` - Registra un nuevo paciente
- `+ solicitarCita(fecha: Date, especialidad: Especialidad): CitaMedica` - Crea una nueva cita
- `+ cancelarCita(cita: CitaMedica): boolean` - Cancela una cita existente
- `+ consultarHistorial(): HistoriaClinica` - Consulta su historia clínica
- `+ actualizarPerfil(): void` - Actualiza datos del perfil
- `+ verificarCuenta(email: String): boolean` - Verifica la cuenta por email

**Relaciones:**
- Tiene **1** HistoriaClinica
- Solicita **0..*** CitaMedica
- Genera **0..*** Factura
- Recibe **0..*** Notificacion

---

### Clase: **Medico** (hereda de Usuario)

**Descripción:** Representa a los médicos que atienden a los pacientes.

**Atributos Adicionales:**
- `- cmp: String` - Código del Colegio Médico del Perú (único)
- `- especialidadId: String` - ID de la especialidad
- `- añosExperiencia: int` - Años de experiencia profesional
- `- estadoLaboral: String` - Estado laboral (Activo/Inactivo/Vacaciones)
- `- curriculum: String` - Currículum vitae

**Métodos:**
- `+ registrarHorario(horario: HorarioAtencion): void` - Define horarios de atención
- `+ consultarAgenda(fecha: Date): List<CitaMedica>` - Consulta citas programadas
- `+ atenderCita(cita: CitaMedica): void` - Marca una cita como atendida
- `+ registrarDiagnostico(cita: CitaMedica, diag: Diagnostico): void` - Registra diagnóstico
- `+ prescribirTratamiento(diagnostico: Diagnostico): Tratamiento` - Prescribe tratamiento
- `+ modificarHorario(horario: HorarioAtencion): void` - Modifica horarios

**Relaciones:**
- Está **especializado en 1** Especialidad
- Define **0..*** HorarioAtencion
- Atiende **0..*** CitaMedica
- Recibe **0..*** Notificacion

---

### Clase: **Administrador** (hereda de Usuario)

**Descripción:** Gestiona la administración del sistema.

**Atributos Adicionales:**
- `- rol: String` - Rol del administrador
- `- permisos: List<String>` - Lista de permisos asignados
- `- nivelAcceso: int` - Nivel de acceso (1-5)

**Métodos:**
- `+ gestionarUsuarios(): void` - Administra usuarios del sistema
- `+ configurarSistema(): void` - Configura parámetros del sistema
- `+ generarReportes(): void` - Genera reportes estadísticos
- `+ asignarConsultorios(): void` - Asigna consultorios a citas
- `+ administrarEspecialidades(): void` - Gestiona especialidades médicas

---

## 2️⃣ Package: Gestión de Citas

### Clase: **CitaMedica**

**Descripción:** Representa una cita médica programada.

**Atributos:**
- `- numeroCita: String` - Número único de cita (formato: CITA-YYYY-NNN)
- `- fechaCita: Date` - Fecha programada de la cita
- `- horaCita: Time` - Hora programada
- `- motivo: String` - Motivo de consulta
- `- estadoCita: String` - Estado (Pendiente/Confirmada/Atendida/Cancelada)
- `- observaciones: String` - Observaciones adicionales
- `- fechaRegistro: Date` - Fecha de registro de la cita
- `- costoConsulta: double` - Costo de la consulta

**Métodos:**
- `+ confirmarCita(): void` - Confirma la cita
- `+ cancelarCita(motivo: String): boolean` - Cancela la cita
- `+ reprogramarCita(nuevaFecha: Date): boolean` - Reprograma la cita
- `+ marcarComoAtendida(): void` - Marca como atendida
- `+ generarComprobante(): String` - Genera comprobante
- `+ enviarRecordatorio(): void` - Envía recordatorio al paciente

**Relaciones:**
- Es solicitada por **1** Paciente
- Es atendida por **1** Medico
- Está asignada a **1** Consultorio
- Es registrada en **1** HistoriaClinica
- Genera **0..*** Diagnostico
- Genera **0..1** Factura
- Genera **0..*** Notificacion

---

### Clase: **HorarioAtencion**

**Descripción:** Define los horarios de atención de los médicos.

**Atributos:**
- `- id: int` - Identificador único
- `- diaSemana: String` - Día de la semana
- `- horaInicio: Time` - Hora de inicio
- `- horaFin: Time` - Hora de fin
- `- duracionCita: int` - Duración en minutos de cada cita
- `- maxCitas: int` - Máximo de citas por horario
- `- estado: String` - Estado (Activo/Inactivo)

**Métodos:**
- `+ validarHorario(): boolean` - Valida que el horario sea correcto
- `+ calcularDisponibilidad(): int` - Calcula citas disponibles
- `+ verificarConflictos(): boolean` - Verifica conflictos de horario
- `+ obtenerCitasDisponibles(): List<Time>` - Lista horas disponibles

**Relaciones:**
- Es definido por **1** Medico

---

### Clase: **Consultorio**

**Descripción:** Representa un consultorio físico del hospital.

**Atributos:**
- `- numero: String` - Número del consultorio
- `- piso: String` - Piso donde se encuentra
- `- edificio: String` - Edificio donde se ubica
- `- capacidad: int` - Capacidad de personas
- `- equipamiento: String` - Descripción del equipamiento
- `- estado: String` - Estado (Disponible/Ocupado/Mantenimiento)

**Métodos:**
- `+ verificarDisponibilidad(fecha: Date, hora: Time): boolean`
- `+ reservarConsultorio(): void`
- `+ liberarConsultorio(): void`
- `+ registrarMantenimiento(): void`

**Relaciones:**
- Tiene asignadas **0..*** CitaMedica

---

## 3️⃣ Package: Gestión de Especialidades

### Clase: **Especialidad**

**Descripción:** Representa una especialidad médica del hospital.

**Atributos:**
- `- id: String` - Identificador único
- `- nombre: String` - Nombre de la especialidad
- `- descripcion: String` - Descripción de la especialidad
- `- activo: boolean` - Si está activa
- `- costoBase: double` - Costo base de consulta

**Métodos:**
- `+ obtenerMedicos(): List<Medico>` - Lista médicos de la especialidad
- `+ activar(): void` - Activa la especialidad
- `+ desactivar(): void` - Desactiva la especialidad

**Relaciones:**
- Tiene **0..*** Medico especializados

---

## 4️⃣ Package: Gestión de Historia Clínica

### Clase: **HistoriaClinica**

**Descripción:** Almacena el historial médico completo de un paciente.

**Atributos:**
- `- numeroHistoria: String` - Número único de historia (formato: HC-YYYY-NNNNN)
- `- fechaApertura: Date` - Fecha de apertura de la historia
- `- tipoSangre: String` - Tipo de sangre del paciente
- `- alergias: String` - Alergias conocidas
- `- antecedentes: String` - Antecedentes médicos
- `- observacionesGenerales: String` - Observaciones generales

**Métodos:**
- `+ agregarCita(cita: CitaMedica): void` - Agrega una cita al historial
- `+ consultarHistorial(): List<CitaMedica>` - Consulta todas las citas
- `+ generarResumen(): String` - Genera resumen de la historia
- `+ exportarPDF(): File` - Exporta historia en PDF

**Relaciones:**
- Pertenece a **1** Paciente
- Contiene **0..*** CitaMedica
- Contiene **0..*** Diagnostico
- Incluye **0..*** ExamenMedico

---

### Clase: **Diagnostico**

**Descripción:** Representa un diagnóstico médico.

**Atributos:**
- `- id: int` - Identificador único
- `- codigo: String` - Código CIE-10
- `- descripcion: String` - Descripción del diagnóstico
- `- fecha: Date` - Fecha del diagnóstico
- `- observaciones: String` - Observaciones adicionales
- `- gravedad: String` - Gravedad (Leve/Moderada/Grave)

**Métodos:**
- `+ registrarDiagnostico(): void`
- `+ actualizarDiagnostico(): void`
- `+ vincularTratamiento(tratamiento: Tratamiento): void`

**Relaciones:**
- Es generado por **1** CitaMedica
- Está contenido en **1** HistoriaClinica
- Prescribe **0..*** Tratamiento

---

### Clase: **Tratamiento**

**Descripción:** Representa un tratamiento médico prescrito.

**Atributos:**
- `- id: int` - Identificador único
- `- descripcion: String` - Descripción del tratamiento
- `- fechaInicio: Date` - Fecha de inicio
- `- fechaFin: Date` - Fecha de fin
- `- duracion: String` - Duración del tratamiento
- `- indicaciones: String` - Indicaciones para el paciente
- `- medicamentos: String` - Medicamentos prescritos

**Métodos:**
- `+ prescribirTratamiento(): void`
- `+ modificarTratamiento(): void`
- `+ finalizarTratamiento(): void`
- `+ generarReceta(): String`

**Relaciones:**
- Es prescrito por **1** Diagnostico

---

### Clase: **ExamenMedico**

**Descripción:** Representa exámenes médicos solicitados.

**Atributos:**
- `- id: int` - Identificador único
- `- tipoExamen: String` - Tipo de examen
- `- descripcion: String` - Descripción del examen
- `- fechaSolicitud: Date` - Fecha de solicitud
- `- fechaResultado: Date` - Fecha del resultado
- `- resultado: String` - Resultado del examen
- `- archivoAdjunto: File` - Archivo con resultados

**Métodos:**
- `+ solicitarExamen(): void`
- `+ registrarResultado(resultado: String): void`
- `+ adjuntarArchivo(archivo: File): void`

**Relaciones:**
- Está incluido en **1** HistoriaClinica

---

## 5️⃣ Package: Gestión de Facturación

### Clase: **Factura**

**Descripción:** Representa una factura por servicios médicos.

**Atributos:**
- `- numeroFactura: String` - Número único de factura
- `- fecha: Date` - Fecha de emisión
- `- monto: double` - Monto base
- `- igv: double` - Impuesto (18%)
- `- total: double` - Total a pagar
- `- estadoPago: String` - Estado (Pendiente/Pagado/Anulado)
- `- metodoPago: String` - Método de pago utilizado

**Métodos:**
- `+ generarFactura(): void`
- `+ calcularTotal(): double`
- `+ registrarPago(): void`
- `+ anularFactura(): void`
- `+ imprimirFactura(): File`

**Relaciones:**
- Es generada por **1** Paciente
- Corresponde a **1** CitaMedica
- Es procesada con **1..*** Pago

---

### Clase: **Pago**

**Descripción:** Representa un pago realizado.

**Atributos:**
- `- idPago: int` - Identificador único
- `- monto: double` - Monto pagado
- `- fechaPago: Date` - Fecha del pago
- `- metodoPago: String` - Método (Efectivo/Tarjeta/Transferencia)
- `- numeroTransaccion: String` - Número de transacción
- `- comprobante: String` - Comprobante de pago

**Métodos:**
- `+ procesarPago(): boolean`
- `+ verificarPago(): boolean`
- `+ generarComprobante(): String`

**Relaciones:**
- Procesa **1** Factura

---

## 6️⃣ Package: Sistema de Notificaciones

### Clase Abstracta: **Notificacion**

**Descripción:** Clase base para diferentes tipos de notificaciones.

**Atributos:**
- `- id: int` - Identificador único
- `- tipo: String` - Tipo de notificación
- `- mensaje: String` - Contenido del mensaje
- `- fecha: Date` - Fecha de envío
- `- leida: boolean` - Si fue leída
- `- prioridad: String` - Prioridad (Alta/Media/Baja)

**Métodos:**
- `+ enviarNotificacion(): void`
- `+ marcarComoLeida(): void`
- `+ programarEnvio(fecha: Date): void`

**Relaciones:**
- Es recibida por **1** Paciente o Medico
- Es generada por **1** CitaMedica
- Es **generalizada** por: Email, SMS

---

### Clase: **Email** (hereda de Notificacion)

**Atributos Adicionales:**
- `- asunto: String` - Asunto del correo
- `- cuerpo: String` - Cuerpo del mensaje
- `- destinatario: String` - Email del destinatario
- `- adjuntos: List<File>` - Archivos adjuntos

**Métodos:**
- `+ enviarEmail(): boolean`
- `+ agregarAdjunto(archivo: File): void`

---

### Clase: **SMS** (hereda de Notificacion)

**Atributos Adicionales:**
- `- numeroDestino: String` - Número de teléfono
- `- texto: String` - Texto del SMS (máx 160 caracteres)
- `- estadoEnvio: String` - Estado de envío

**Métodos:**
- `+ enviarSMS(): boolean`

---

## 7️⃣ Clase Principal: Sistema

### Clase: **Sistema**

**Descripción:** Clase principal que coordina todo el sistema.

**Atributos:**
- `- nombre: String` - Nombre del sistema
- `- version: String` - Versión del sistema
- `- fechaActual: Date` - Fecha actual del sistema

**Métodos:**
- `+ iniciarSistema(): void`
- `+ cerrarSistema(): void`
- `+ obtenerFechaActual(): Date`

**Relaciones:**
- Gestiona **0..*** Usuario
- Administra **0..*** CitaMedica
- Contiene **0..*** Especialidad

---

## 🔗 Tipos de Relaciones

### **Herencia (Generalización)**
- Usuario ◁─ Paciente
- Usuario ◁─ Medico
- Usuario ◁─ Administrador
- Notificacion ◁─ Email
- Notificacion ◁─ SMS

### **Asociación**
- Paciente ── HistoriaClinica (1:1)
- Paciente ── CitaMedica (1:*)
- Medico ── Especialidad (*:1)
- CitaMedica ── Consultorio (*:1)

### **Composición**
- HistoriaClinica ◆── Diagnostico
- HistoriaClinica ◆── ExamenMedico

### **Dependencia**
- Diagnostico ··> Tratamiento

---

## 📋 Multiplicidades

| Relación | Multiplicidad | Descripción |
|----------|---------------|-------------|
| Paciente - HistoriaClinica | 1:1 | Un paciente tiene una historia clínica |
| Paciente - CitaMedica | 1:* | Un paciente puede tener muchas citas |
| Medico - CitaMedica | 1:* | Un médico atiende muchas citas |
| Medico - Especialidad | *:1 | Muchos médicos pueden tener una especialidad |
| CitaMedica - Consultorio | *:1 | Muchas citas en un consultorio |
| CitaMedica - Diagnostico | 1:* | Una cita puede generar varios diagnósticos |
| Diagnostico - Tratamiento | 1:* | Un diagnóstico puede tener varios tratamientos |
| Factura - Pago | 1:1..* | Una factura puede tener uno o más pagos |

---

## 💡 Patrones de Diseño Aplicados

### 1. **Patrón de Herencia (Inheritance)**
- Clase abstracta `Usuario` con subclases concretas
- Clase abstracta `Notificacion` con subclases concretas

### 2. **Patrón de Composición**
- `HistoriaClinica` compone `Diagnostico` y `ExamenMedico`

### 3. **Patrón de Singleton (Implícito)**
- La clase `Sistema` actúa como punto central de coordinación

---

## ✅ Validación del Diseño

El diagrama de clases permite:

✅ **Gestión completa de usuarios** (Pacientes, Médicos, Administradores)  
✅ **Reserva y seguimiento de citas** médicas  
✅ **Registro de historiales clínicos** completos  
✅ **Diagnósticos y tratamientos** médicos  
✅ **Facturación y pagos** de servicios  
✅ **Sistema de notificaciones** automático  
✅ **Asignación de consultorios** y horarios  
✅ **Especialidades médicas** diferenciadas  

---

## 📊 Estadísticas del Diagrama

- **Total de Clases:** 18
- **Clases Abstractas:** 2 (Usuario, Notificacion)
- **Paquetes:** 7
- **Relaciones de Herencia:** 5
- **Relaciones de Asociación:** 15+
- **Métodos Totales:** ~120+
- **Atributos Totales:** ~110+

---

**Herramienta:** PlantUML  
**Formato:** PNG, 300 DPI  
**Versión:** 1.0  
**Fecha:** Octubre 2025  
**Fuente:** Elaboración propia



# 4.8 Diagrama de Objetos (Instancias de Ejemplo)

Ubicación:[diagramas/diagrama-objetos.png](../diagramas/diagrama-objetos.png)
## Descripción General

El diagrama de objetos representa un **snapshot** o instantánea del sistema de reserva de consultas médicas en un momento específico del tiempo. Este diagrama muestra instancias concretas de las clases del sistema con valores reales y sus relaciones específicas, ilustrando cómo funciona el sistema en un escenario de uso típico.

## Propósito del Diagrama

El diagrama tiene como objetivo:

1. **Ilustrar instancias reales** del sistema con datos concretos
2. **Mostrar relaciones específicas** entre objetos en tiempo de ejecución
3. **Complementar el diagrama de clases** mostrando ejemplos prácticos
4. **Facilitar la comprensión** del funcionamiento del sistema
5. **Validar el modelo de datos** con casos de uso reales

## Escenario Representado

El diagrama muestra un escenario típico del sistema donde:

- **Dos pacientes** están registrados en el sistema
- **Tres médicos** de diferentes especialidades están disponibles
- **Tres citas médicas** en diferentes estados (confirmada, pendiente, atendida)
- **Una cita completada** que incluye diagnóstico y tratamiento
- **Historias clínicas activas** para ambos pacientes
- **Consultorios asignados** para cada cita

## Descripción de las Instancias

### 1. Sistema Principal

**`:Sistema`**
- Representa la instancia del sistema completo
- Gestiona todas las entidades y sus relaciones
- Mantiene la fecha actual: 2025-10-29

### 2. Pacientes

**`paciente1:Paciente` - Juan Pérez García**
- **DNI:** 72345678
- **Fecha de Nacimiento:** 15/05/1990
- **Contacto:** juan.perez@email.com, 987654321
- **Estado:** Cuenta Activa
- **Antecedentes:** Hipertensión arterial
- **Citas:** Tiene 2 citas (una confirmada y una atendida)

**`paciente2:Paciente` - María González López**
- **DNI:** 71234567
- **Fecha de Nacimiento:** 22/08/1985
- **Contacto:** maria.gonzalez@email.com, 965432187
- **Estado:** Cuenta Activa
- **Antecedentes:** Ninguno
- **Citas:** Tiene 1 cita pendiente

### 3. Médicos y Especialidades

**`med1:Medico` - Dr. Carlos Ramírez Torres**
- **CMP:** 054321
- **Especialidad:** Cardiología
- **Experiencia:** 15 años
- **Horario:** Lunes 08:00-13:00
- **Estado:** Activo
- **Cita asignada:** CITA-2025-001 (Consultorio 101)

**`med2:Medico` - Dra. Ana Martínez Sánchez**
- **CMP:** 054789
- **Especialidad:** Pediatría
- **Experiencia:** 10 años
- **Horario:** Martes 09:00-12:00
- **Estado:** Activo
- **Cita asignada:** CITA-2025-002 (Consultorio 310)

**`med3:Medico` - Dr. Luis Flores Díaz**
- **CMP:** 055123
- **Especialidad:** Traumatología
- **Experiencia:** 8 años
- **Horario:** Miércoles 14:00-18:00
- **Estado:** Activo
- **Cita asignada:** CITA-2025-003 (Consultorio 205)

### 4. Especialidades Médicas

**`esp1:Especialidad` - Cardiología**
- Especialidad médica del corazón y sistema cardiovascular
- Estado: Activo

**`esp2:Especialidad` - Pediatría**
- Atención médica infantil y adolescente
- Estado: Activo

**`esp3:Especialidad` - Traumatología**
- Lesiones del sistema músculo-esquelético
- Estado: Activo

### 5. Consultorios

**`cons1:Consultorio` - 101**
- **Ubicación:** Piso 1, Edificio A
- **Equipamiento:** Básico
- **Estado:** Disponible
- **Asignado a:** CITA-2025-001 (Cardiología)

**`cons2:Consultorio` - 205**
- **Ubicación:** Piso 2, Edificio A
- **Equipamiento:** Completo
- **Estado:** Disponible
- **Asignado a:** CITA-2025-003 (Traumatología)

**`cons3:Consultorio` - 310**
- **Ubicación:** Piso 3, Edificio B
- **Equipamiento:** Pediátrico
- **Estado:** Disponible
- **Asignado a:** CITA-2025-002 (Pediatría)

### 6. Citas Médicas

**`cita1:CitaMedica` - CITA-2025-001** ✅ CONFIRMADA
- **Paciente:** Juan Pérez García
- **Médico:** Dr. Carlos Ramírez Torres (Cardiología)
- **Fecha:** 05/11/2025 a las 09:00
- **Consultorio:** 101
- **Motivo:** Control cardiológico rutinario
- **Estado:** Confirmada
- **Fecha de Registro:** 28/10/2025

**`cita2:CitaMedica` - CITA-2025-002** ⏳ PENDIENTE
- **Paciente:** María González López
- **Médico:** Dra. Ana Martínez Sánchez (Pediatría)
- **Fecha:** 06/11/2025 a las 10:00
- **Consultorio:** 310
- **Motivo:** Control pediátrico mensual
- **Estado:** Pendiente
- **Fecha de Registro:** 29/10/2025

**`cita3:CitaMedica` - CITA-2025-003** ✔️ ATENDIDA
- **Paciente:** Juan Pérez García
- **Médico:** Dr. Luis Flores Díaz (Traumatología)
- **Fecha:** 30/10/2025 a las 15:00
- **Consultorio:** 205
- **Motivo:** Dolor en rodilla derecha
- **Estado:** Atendida
- **Fecha de Registro:** 20/10/2025
- **Resultado:** Diagnóstico y tratamiento registrados

### 7. Historias Clínicas

**`hc1:HistoriaClinica` - HC-2025-00123**
- **Paciente:** Juan Pérez García
- **Fecha de Apertura:** 15/01/2025
- **Tipo Sanguíneo:** O+
- **Alergias:** Penicilina
- **Antecedentes:** Hipertensión arterial
- **Citas Registradas:** 2 (CITA-2025-001, CITA-2025-003)

**`hc2:HistoriaClinica` - HC-2025-00124**
- **Paciente:** María González López
- **Fecha de Apertura:** 20/03/2025
- **Tipo Sanguíneo:** A+
- **Alergias:** Ninguna
- **Antecedentes:** Ninguno
- **Citas Registradas:** 1 (CITA-2025-002)

### 8. Diagnósticos (de cita atendida)

**`diag1:Diagnostico` - I10**
- **Descripción:** Hipertensión arterial controlada
- **Fecha:** 30/10/2025
- **Observaciones:** Continuar tratamiento
- **Relacionado con:** Cita CITA-2025-003
- **Tratamiento prescrito:** Enalapril 10mg

**`diag2:Diagnostico` - M25.561**
- **Descripción:** Dolor en rodilla derecha
- **Fecha:** 30/10/2025
- **Observaciones:** Requiere radiografía
- **Relacionado con:** Cita CITA-2025-003
- **Tratamiento prescrito:** Ibuprofeno 400mg

### 9. Tratamientos

**`trat1:Tratamiento`** (Para hipertensión)
- **Descripción:** Enalapril 10mg cada 12 horas
- **Fecha de Inicio:** 30/10/2025
- **Duración:** 30 días
- **Indicaciones:** Tomar después de las comidas
- **Prescrito por:** Diagnóstico I10

**`trat2:Tratamiento`** (Para dolor de rodilla)
- **Descripción:** Ibuprofeno 400mg cada 8 horas
- **Fecha de Inicio:** 30/10/2025
- **Duración:** 7 días
- **Indicaciones:** Tomar con alimentos, aplicar hielo local
- **Prescrito por:** Diagnóstico M25.561

## Relaciones Principales

### Relaciones de Asociación

1. **Sistema → Entidades**
   - El sistema gestiona todos los pacientes, médicos y especialidades

2. **Paciente → Historia Clínica** (1:1)
   - Cada paciente tiene una historia clínica única
   - `p1` → `hc1`, `p2` → `hc2`

3. **Paciente → Citas** (1:N)
   - Un paciente puede tener múltiples citas
   - `p1` solicita `cita1` y `cita3`
   - `p2` solicita `cita2`

4. **Médico → Especialidad** (N:1)
   - Cada médico está especializado en una especialidad
   - `med1` especializado en `esp1` (Cardiología)
   - `med2` especializado en `esp2` (Pediatría)
   - `med3` especializado en `esp3` (Traumatología)

5. **Médico → Horario de Atención** (1:N)
   - Cada médico tiene horarios de atención específicos
   - `med1` atiende en `h1` (Lunes 08:00-13:00)
   - `med2` atiende en `h3` (Martes 09:00-12:00)
   - `med3` atiende en `h2` (Miércoles 14:00-18:00)

6. **Médico → Citas** (1:N)
   - Cada médico atiende múltiples citas
   - `med1` atiende `cita1`
   - `med2` atiende `cita2`
   - `med3` atiende `cita3`

7. **Consultorio → Cita** (1:1 por sesión)
   - Cada cita se asigna a un consultorio específico
   - `cons1` asignado a `cita1`
   - `cons2` asignado a `cita3`
   - `cons3` asignado a `cita2`

8. **Cita → Historia Clínica** (N:1)
   - Todas las citas se registran en la historia clínica del paciente
   - `cita1` y `cita3` se registran en `hc1`
   - `cita2` se registra en `hc2`

9. **Cita → Diagnóstico** (1:N)
   - Una cita atendida puede generar uno o más diagnósticos
   - `cita3` genera `diag1` y `diag2`

10. **Diagnóstico → Tratamiento** (1:N)
    - Cada diagnóstico puede prescribir uno o más tratamientos
    - `diag1` prescribe `trat1`
    - `diag2` prescribe `trat2`

## Flujo de Ejemplo: Cita Completa (CITA-2025-003)

Este diagrama ilustra el ciclo completo de una cita médica:

1. **Registro del Paciente**
   - Juan Pérez García (DNI: 72345678) se registra en el sistema
   - Se crea su historia clínica (HC-2025-00123)

2. **Solicitud de Cita**
   - El paciente solicita cita para "Dolor en rodilla derecha"
   - Fecha de registro: 20/10/2025
   - Cita programada: 30/10/2025 a las 15:00

3. **Asignación de Recursos**
   - Médico asignado: Dr. Luis Flores Díaz (Traumatología)
   - Consultorio asignado: 205 (Piso 2, Edificio A)

4. **Atención de la Cita**
   - Estado cambia a "Atendida"
   - Se realizan diagnósticos:
     - Hipertensión arterial controlada (I10)
     - Dolor en rodilla derecha (M25.561)

5. **Prescripción de Tratamientos**
   - Tratamiento 1: Enalapril 10mg para hipertensión
   - Tratamiento 2: Ibuprofeno 400mg para dolor

6. **Registro en Historia Clínica**
   - Toda la información se registra en HC-2025-00123
   - El paciente puede consultar su historial completo

## Notas Importantes

### 📌 Nota 1: Paciente con Historial
Juan Pérez García (paciente1) tiene antecedentes de hipertensión, lo cual se refleja en:
- Su historia clínica (alergias: Penicilina, antecedentes: Hipertensión)
- Su diagnóstico actual (I10: Hipertensión arterial controlada)
- Su tratamiento continuo (Enalapril)

### 📌 Nota 2: Cita Atendida Completa
La CITA-2025-003 muestra el flujo completo:
- Paciente → Cita → Médico → Consultorio
- Cita → Diagnóstico → Tratamiento
- Cita → Historia Clínica (registro permanente)

### 📌 Nota 3: Estados de Citas
El diagrama muestra los tres estados posibles:
- **Confirmada** (cita1): Agendada y confirmada
- **Pendiente** (cita2): Agendada pero sin confirmar
- **Atendida** (cita3): Completada con diagnóstico

### 📌 Nota 4: Sistema Centralizado
El objeto `:Sistema` 
- gestiona todas las entidades y sus relaciones, asegurando la integridad y consistencia de los datos.
---
## Validación del Modelo

Este diagrama valida que el modelo de datos puede:

✅ Gestionar múltiples pacientes simultáneamente  
✅ Registrar diferentes especialidades médicas  
✅ Asignar médicos a especialidades específicas  
✅ Programar citas en diferentes consultorios  
✅ Mantener historiales clínicos completos  
✅ Registrar diagnósticos y tratamientos  
✅ Gestionar diferentes estados de citas  
✅ Relacionar toda la información de forma coherente  
## Casos de Uso Representados

1. **UC-01:** Registro de Paciente (paciente1, paciente2)
2. **UC-02:** Solicitud de Cita (cita1, cita2, cita3)
3. **UC-03:** Asignación de Recursos (consultorios, médicos)
4. **UC-04:** Atención de Cita (cita3)
5. **UC-05:** Registro de Diagnóstico (diag1, diag2)
6. **UC-06:** Prescripción de Tratamiento (trat1, trat2)
7. **UC-07:** Consulta de Historia Clínica (hc1, hc2)

## Conclusiones

El diagrama de objetos demuestra que:

1. El modelo de datos es **completo y consistente**
2. Las relaciones entre entidades son **claras y correctas**
3. El sistema puede gestionar **escenarios reales complejos**
4. La información se mantiene **integrada y coherente**
5. El flujo de trabajo médico está **correctamente modelado**

Este diagrama complementa el diagrama de clases al mostrar cómo funcionan las instancias en tiempo de ejecución y valida que el diseño puede soportar las operaciones del sistema de forma eficiente.

---

**Figura 4.8:** Diagrama de Objetos del Sistema de Reserva de Consultas Médicas  
**Herramienta:** PlantUML  
**Formato:** PNG, 300 DPI  
**Fuente:** Elaboración propia

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