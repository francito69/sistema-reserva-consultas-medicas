# 2. Requerimientos del Sistema

## Sistema de Reserva de Consultas Médicas Externas

---

## 2.1. Introducción

Este documento especifica los requerimientos funcionales y no funcionales del **Sistema de Reserva de Consultas Médicas Externas**. Los requerimientos han sido identificados mediante el análisis del caso de estudio proporcionado en la práctica calificada y siguiendo las mejores prácticas de ingeniería de requisitos.

---

## 2.2. Requerimientos Funcionales

Los requerimientos funcionales describen las capacidades y comportamientos que el sistema debe proporcionar.

### Tabla de Requerimientos Funcionales

| **Código** | **Requerimiento Funcional** | **Prioridad** | **Caso de Uso** |
|------------|----------------------------|---------------|-----------------|
| **RF01** | El sistema debe permitir el registro de nuevos pacientes con sus datos personales (DNI, nombres, apellidos, fecha de nacimiento, género, dirección, email, teléfono) | Alta | CU01 |
| **RF02** | El sistema debe permitir el registro de médicos con sus datos profesionales (DNI, nombres, apellidos, número de colegiatura, especialidades, email, teléfono) | Alta | CU02 |
| **RF03** | El sistema debe permitir a los médicos gestionar su agenda de horarios de atención (día de semana, hora inicio, hora fin, consultorio asignado) | Alta | CU03 |
| **RF04** | El sistema debe permitir a los pacientes buscar médicos por especialidad | Alta | CU04 |
| **RF05** | El sistema debe mostrar los horarios disponibles de un médico para una fecha específica | Alta | CU04 |
| **RF06** | El sistema debe permitir a los pacientes realizar reservas de citas médicas seleccionando médico, fecha, hora y consultorio | Alta | CU04 |
| **RF07** | El sistema debe validar que no existan conflictos de horario al registrar una cita (un médico no puede tener dos citas simultáneas) | Alta | CU04 |
| **RF08** | El sistema debe permitir a los pacientes cancelar sus citas programadas | Alta | CU05 |
| **RF09** | El sistema debe enviar notificaciones por correo electrónico al confirmar una cita | Media | CU06 |
| **RF10** | El sistema debe enviar notificaciones por correo electrónico al cancelar una cita | Media | CU06 |
| **RF11** | El sistema debe enviar recordatorios automáticos de citas 24 horas antes de la fecha programada | Media | CU06 |
| **RF12** | El sistema debe permitir actualizar el estado de las citas (Pendiente, Confirmada, Atendida, Cancelada, No Presentado) | Media | CU07 |
| **RF13** | El sistema debe mostrar un panel de control (dashboard) para el administrador con métricas del sistema | Media | CU08 |
| **RF14** | El sistema debe permitir visualizar el historial completo de citas de un paciente | Media | CU08 |
| **RF15** | El sistema debe generar reportes de citas por especialidad, médico, fecha y estado | Media | CU08 |
| **RF16** | El sistema debe gestionar el catálogo de especialidades médicas | Media | CU08 |
| **RF17** | El sistema debe gestionar el catálogo de consultorios (código, nombre, piso, capacidad) | Media | CU08 |
| **RF18** | El sistema debe permitir la autenticación de usuarios (login) con usuario y contraseña | Alta | CU09 |
| **RF19** | El sistema debe implementar roles de usuario (Paciente, Médico, Administrador) con permisos diferenciados | Alta | CU09 |
| **RF20** | El sistema debe permitir a los pacientes actualizar sus datos personales | Baja | CU01 |
| **RF21** | El sistema debe permitir a los médicos ver la lista de pacientes que tienen citas con ellos | Media | CU03 |
| **RF22** | El sistema debe calcular automáticamente la edad del paciente a partir de su fecha de nacimiento | Baja | - |
| **RF23** | El sistema debe validar que la fecha de una cita sea futura (no se pueden agendar citas en el pasado) | Alta | CU04 |
| **RF24** | El sistema debe permitir buscar pacientes por DNI, nombre o apellido | Media | CU08 |
| **RF25** | El sistema debe permitir buscar médicos por nombre, apellido o número de colegiatura | Media | CU08 |

---

## 2.3. Requerimientos No Funcionales

Los requerimientos no funcionales definen las cualidades y restricciones del sistema.

### 2.3.1. Rendimiento

| **Código** | **Requerimiento** | **Métrica** |
|------------|------------------|-------------|
| **RNF01** | El tiempo de respuesta para consultas de disponibilidad de horarios no debe superar los 3 segundos | ≤ 3 seg |
| **RNF02** | El tiempo de respuesta para el registro de una nueva cita no debe superar los 5 segundos | ≤ 5 seg |
| **RNF03** | La generación de reportes no debe superar los 10 segundos para consultas de hasta 3 meses | ≤ 10 seg |
| **RNF04** | El sistema debe soportar al menos 100 usuarios concurrentes sin degradación significativa del rendimiento | 100 usuarios |
| **RNF05** | Las páginas web deben cargar completamente en menos de 5 segundos con una conexión de 5 Mbps | ≤ 5 seg |

### 2.3.2. Disponibilidad

| **Código** | **Requerimiento** | **Métrica** |
|------------|------------------|-------------|
| **RNF06** | El sistema debe estar disponible 24 horas al día, 7 días a la semana | 24/7 |
| **RNF07** | El sistema debe tener una disponibilidad mínima del 99% mensual | ≥ 99% |
| **RNF08** | El tiempo máximo de inactividad no planificado no debe superar 4 horas continuas | ≤ 4 horas |
| **RNF09** | El sistema debe contar con respaldos automáticos diarios de la base de datos | Diario |

### 2.3.3. Escalabilidad

| **Código** | **Requerimiento** | **Métrica** |
|------------|------------------|-------------|
| **RNF10** | El sistema debe ser capaz de escalar para soportar hasta 500 usuarios concurrentes | 500 usuarios |
| **RNF11** | La base de datos debe soportar al menos 10,000 pacientes registrados sin pérdida de rendimiento | 10,000 registros |
| **RNF12** | El sistema debe soportar el registro de hasta 1,000 citas diarias | 1,000 citas/día |
| **RNF13** | La arquitectura debe permitir agregar nuevos módulos sin afectar los existentes | Modular |

### 2.3.4. Seguridad

| **Código** | **Requerimiento** | **Especificación** |
|------------|------------------|-------------------|
| **RNF14** | Las contraseñas de usuarios deben almacenarse encriptadas utilizando algoritmos seguros (BCrypt, SHA-256) | Obligatorio |
| **RNF15** | El sistema debe implementar autenticación basada en sesiones o tokens JWT | Obligatorio |
| **RNF16** | Las comunicaciones entre cliente y servidor deben estar protegidas mediante HTTPS | Obligatorio |
| **RNF17** | El sistema debe registrar en logs todas las acciones críticas (registro, modificación, eliminación de citas) | Obligatorio |
| **RNF18** | Los datos personales de pacientes deben cumplir con la Ley de Protección de Datos Personales | Obligatorio |
| **RNF19** | El sistema debe implementar control de acceso basado en roles (RBAC) | Obligatorio |
| **RNF20** | El sistema debe cerrar automáticamente las sesiones inactivas después de 30 minutos | 30 min |
| **RNF21** | El sistema debe validar y sanitizar todas las entradas de usuario para prevenir inyección SQL y XSS | Obligatorio |

### 2.3.5. Usabilidad

| **Código** | **Requerimiento** | **Especificación** |
|------------|------------------|-------------------|
| **RNF22** | La interfaz de usuario debe ser intuitiva y fácil de usar, sin necesidad de capacitación previa | Intuitiva |
| **RNF23** | El sistema debe proporcionar mensajes de error claros y descriptivos | Descriptivos |
| **RNF24** | El sistema debe ser responsive y adaptarse a diferentes tamaños de pantalla (desktop, tablet, móvil) | Responsive |
| **RNF25** | El registro de una nueva cita no debe requerir más de 5 pasos | ≤ 5 pasos |
| **RNF26** | Los formularios deben incluir validación en tiempo real de los datos ingresados | Tiempo real |
| **RNF27** | El sistema debe proporcionar confirmaciones antes de ejecutar acciones irreversibles (cancelar cita) | Confirmación |
| **RNF28** | El sistema debe ser accesible cumpliendo con estándares WCAG 2.1 nivel AA | WCAG 2.1 AA |

### 2.3.6. Mantenibilidad

| **Código** | **Requerimiento** | **Especificación** |
|------------|------------------|-------------------|
| **RNF29** | El código debe estar documentado y comentado siguiendo convenciones de Java (Javadoc) | Obligatorio |
| **RNF30** | El sistema debe seguir principios SOLID y patrones de diseño establecidos | Obligatorio |
| **RNF31** | El código debe estar versionado utilizando Git | Git |
| **RNF32** | El sistema debe contar con pruebas unitarias con una cobertura mínima del 70% | ≥ 70% |
| **RNF33** | La base de datos debe estar normalizada hasta la Tercera Forma Normal (3FN) | 3FN |

### 2.3.7. Portabilidad

| **Código** | **Requerimiento** | **Especificación** |
|------------|------------------|-------------------|
| **RNF34** | El sistema debe ser compatible con los navegadores Chrome, Firefox, Edge y Safari (versiones recientes) | Multi-browser |
| **RNF35** | El backend debe poder ejecutarse en sistemas operativos Windows, Linux y macOS | Multi-OS |
| **RNF36** | La base de datos PostgreSQL debe poder migrarse a otros sistemas compatibles con SQL estándar | Portable |

### 2.3.8. Interoperabilidad

| **Código** | **Requerimiento** | **Especificación** |
|------------|------------------|-------------------|
| **RNF37** | El sistema debe exponer una API REST documentada con Swagger/OpenAPI | REST API |
| **RNF38** | Los datos deben ser intercambiados en formato JSON | JSON |
| **RNF39** | El sistema debe permitir integración futura con servicios externos de mensajería (SMS, WhatsApp) | Extensible |

---

## 2.4. Atributos de Calidad

Los atributos de calidad son características medibles del sistema que determinan su nivel de excelencia.

### 2.4.1. Rendimiento

**Descripción:** Capacidad del sistema para responder rápidamente a las solicitudes de los usuarios.

**Escenario de Calidad:**
- **Estímulo:** Un paciente solicita ver los horarios disponibles de un médico para la próxima semana
- **Respuesta:** El sistema muestra los horarios disponibles
- **Medida de Respuesta:** En menos de 3 segundos con 100 usuarios concurrentes

**Importancia:** Alta - Los usuarios esperan respuestas inmediatas para una buena experiencia.

### 2.4.2. Disponibilidad

**Descripción:** Capacidad del sistema para estar operativo y accesible cuando se necesita.

**Escenario de Calidad:**
- **Estímulo:** Fallo del servidor de base de datos a las 2:00 AM
- **Respuesta:** El sistema detecta el fallo y activa mecanismos de recuperación
- **Medida de Respuesta:** El servicio se restaura automáticamente en menos de 15 minutos

**Importancia:** Alta - Los pacientes deben poder agendar citas en cualquier momento.

### 2.4.3. Escalabilidad

**Descripción:** Capacidad del sistema para manejar crecimiento en usuarios y datos.

**Escenario de Calidad:**
- **Estímulo:** Incremento de usuarios de 100 a 500 simultáneos durante una campaña de salud
- **Respuesta:** El sistema mantiene su rendimiento agregando recursos
- **Medida de Respuesta:** Tiempo de respuesta se mantiene bajo 5 segundos

**Importancia:** Media - El sistema debe crecer con la institución.

### 2.4.4. Seguridad

**Descripción:** Protección de datos sensibles y prevención de accesos no autorizados.

**Escenario de Calidad:**
- **Estímulo:** Intento de acceso no autorizado a datos de pacientes
- **Respuesta:** El sistema rechaza el acceso y registra el intento
- **Medida de Respuesta:** 100% de intentos bloqueados y registrados en logs

**Importancia:** Crítica - Datos médicos son altamente sensibles.

### 2.4.5. Usabilidad

**Descripción:** Facilidad con la que los usuarios pueden utilizar el sistema.

**Escenario de Calidad:**
- **Estímulo:** Un paciente nuevo sin experiencia técnica intenta agendar una cita
- **Respuesta:** El paciente completa el proceso sin ayuda externa
- **Medida de Respuesta:** 90% de usuarios completan el proceso en menos de 5 minutos

**Importancia:** Alta - Un sistema difícil de usar no será adoptado.

---

## 2.5. Restricciones

Las restricciones son limitaciones impuestas al desarrollo del sistema.

### 2.5.1. Restricciones Tecnológicas

| **Restricción** | **Descripción** | **Justificación** |
|-----------------|-----------------|-------------------|
| **RT01** | El backend debe ser desarrollado en Java utilizando Spring Boot 3.x | Requerimiento académico del curso |
| **RT02** | La base de datos debe ser PostgreSQL 15 o superior | Requerimiento académico del curso |
| **RT03** | El frontend debe desarrollarse con HTML5, CSS3 y JavaScript vanilla (sin frameworks como React o Vue) | Requerimiento académico del curso |
| **RT04** | El servidor local debe ser XAMPP o equivalente | Facilidad de configuración |
| **RT05** | El control de versiones debe realizarse con Git y GitHub | Buenas prácticas de desarrollo |
| **RT06** | La versión de Java debe ser JDK 17 LTS o superior | Compatibilidad y soporte a largo plazo |

### 2.5.2. Restricciones de Integración

| **Restricción** | **Descripción** |
|-----------------|-----------------|
| **RI01** | El sistema debe ser standalone (no requiere integración con sistemas externos existentes) |
| **RI02** | Las notificaciones por correo electrónico deben utilizar servicios SMTP públicos (Gmail, SendGrid) |
| **RI03** | No se requiere integración con sistemas de pago en línea en esta versión |
| **RI04** | No se requiere integración con historia clínica electrónica |

### 2.5.3. Restricciones de Almacenamiento y Datos

| **Restricción** | **Descripción** |
|-----------------|-----------------|
| **RD01** | El historial de citas debe mantenerse por un mínimo de 2 años |
| **RD02** | Los datos de pacientes inactivos (sin citas en 2 años) pueden ser archivados |
| **RD03** | Los logs del sistema deben conservarse por al menos 6 meses |
| **RD04** | La base de datos debe realizar respaldos diarios automáticos |

### 2.5.4. Restricciones Legales y Normativas

| **Restricción** | **Descripción** |
|-----------------|-----------------|
| **RL01** | El sistema debe cumplir con la Ley N° 29733 - Ley de Protección de Datos Personales (Perú) |
| **RL02** | El acceso a datos personales de pacientes debe estar restringido por roles |
| **RL03** | Los datos médicos deben ser tratados con confidencialidad |
| **RL04** | El sistema debe permitir a los usuarios ejercer sus derechos ARCO (Acceso, Rectificación, Cancelación, Oposición) |

### 2.5.5. Restricciones de Tiempo y Recursos

| **Restricción** | **Descripción** |
|-----------------|-----------------|
| **RTR01** | El proyecto debe completarse en un plazo máximo de 8 semanas |
| **RTR02** | El equipo de desarrollo consta de 1 persona (proyecto individual) |
| **RTR03** | El presupuesto es de $0 (uso exclusivo de herramientas gratuitas y open source) |
| **RTR04** | El sistema debe funcionar en hardware de gama media (8GB RAM, procesador i5 o equivalente) |

### 2.5.6. Restricciones de Despliegue

| **Restricción** | **Descripción** |
|-----------------|-----------------|
| **RDP01** | El sistema se desplegará inicialmente en un entorno local (localhost) |
| **RDP02** | No se requiere infraestructura en la nube en esta versión |
| **RDP03** | El sistema debe poder ejecutarse en un solo servidor (monolito) |

---

## 2.6. Supuestos y Dependencias

### 2.6.1. Supuestos

Los siguientes supuestos fueron considerados durante el análisis:

1. **Acceso a Internet:** Los usuarios tienen acceso a conexión de internet estable
2. **Navegadores Modernos:** Los usuarios utilizan navegadores actualizados
3. **Alfabetización Digital:** Los usuarios tienen conocimientos básicos de navegación web
4. **Correo Electrónico:** Todos los pacientes tienen una dirección de correo electrónico válida
5. **Identificación:** Todos los pacientes tienen DNI peruano válido
6. **Colegiatura:** Todos los médicos están colegiados y tienen número de colegiatura
7. **Horario Laboral:** Los médicos atienden en horarios de 08:00 a 20:00 horas
8. **Duración de Consultas:** Cada consulta tiene una duración estándar de 30 minutos
9. **Cancelación Anticipada:** Los pacientes pueden cancelar citas con al menos 24 horas de anticipación
10. **Idioma:** El sistema se desarrolla únicamente en español

### 2.6.2. Dependencias

El sistema depende de:

1. **Tecnologías de Terceros:**
   - PostgreSQL para persistencia de datos
   - Spring Boot para el framework backend
   - Bootstrap para estilos del frontend
   - Servicio SMTP (Gmail) para envío de correos

2. **Bibliotecas y Frameworks:**
   - Spring Data JPA para acceso a datos
   - Spring Security para autenticación
   - Lombok para reducción de código
   - JUnit para testing

3. **Herramientas de Desarrollo:**
   - JDK 17 instalado
   - Maven para gestión de dependencias
   - Git para control de versiones
   - Navegador web moderno

---

## 2.7. Priorización de Requerimientos

Los requerimientos se priorizan utilizando el método **MoSCoW**:

### Must Have (Debe Tener) - Prioridad Alta
- ✅ RF01 - Registro de pacientes
- ✅ RF02 - Registro de médicos
- ✅ RF03 - Gestión de agenda médica
- ✅ RF04, RF05, RF06 - Búsqueda y reserva de citas
- ✅ RF07 - Validación de conflictos de horario
- ✅ RF08 - Cancelación de citas
- ✅ RF18, RF19 - Autenticación y autorización
- ✅ RNF14-RNF21 - Seguridad

### Should Have (Debería Tener) - Prioridad Media
- 🟡 RF09, RF10, RF11 - Sistema de notificaciones
- 🟡 RF12 - Actualización de estados de citas
- 🟡 RF13, RF15 - Dashboard y reportes
- 🟡 RF14 - Historial de citas
- 🟡 RF16, RF17 - Gestión de catálogos
- 🟡 RNF01-RNF05 - Rendimiento

### Could Have (Podría Tener) - Prioridad Baja
- 🟢 RF20 - Actualización de datos personales
- 🟢 RF21 - Lista de pacientes por médico
- 🟢 RF22 - Cálculo automático de edad
- 🟢 RF24, RF25 - Búsqueda avanzada

### Won't Have (No Tendrá) - Fuera del Alcance
- ❌ Historia clínica electrónica
- ❌ Sistema de pagos en línea
- ❌ Telemedicina
- ❌ Aplicación móvil nativa
- ❌ Gestión de exámenes de laboratorio

---

## 2.8. Matriz de Trazabilidad

| Requerimiento | Caso de Uso | Entidad BD | Prioridad |
|---------------|-------------|------------|-----------|
| RF01 | CU01 | paciente, paciente_telefono | Alta |
| RF02 | CU02 | medico, medico_especialidad | Alta |
| RF03 | CU03 | horario_atencion | Alta |
| RF04-RF07 | CU04 | cita, especialidad, medico | Alta |
| RF08 | CU05 | cita, estado_cita | Alta |
| RF09-RF11 | CU06 | notificacion | Media |
| RF12 | CU07 | cita, estado_cita | Media |
| RF13, RF15 | CU08 | Todas | Media |
| RF18-RF19 | CU09 | usuario, rol | Alta |

---

## 2.9. Criterios de Aceptación

Para considerar el sistema como completado y funcional, debe cumplir los siguientes criterios:

### Funcionalidad
- ✅ Todos los requerimientos funcionales de prioridad Alta están implementados
- ✅ Al menos 80% de los requerimientos de prioridad Media están implementados
- ✅ Todos los casos de uso principales funcionan correctamente

### Calidad
- ✅ Cobertura de pruebas unitarias ≥ 70%
- ✅ Todas las pruebas de integración pasan exitosamente
- ✅ Cero errores críticos (severity: critical)
- ✅ Menos de 5 errores menores (severity: minor)

### Documentación
- ✅ Documentación técnica completa
- ✅ Manual de usuario disponible
- ✅ API REST documentada con Swagger
- ✅ Comentarios en el código

### Rendimiento
- ✅ Tiempo de respuesta ≤ 5 segundos para el 95% de las peticiones
- ✅ Sistema soporta 100 usuarios concurrentes sin fallos

---

[⬅️ Anterior: Introducción](01-introduccion.md) | [Volver al índice](README.md) | [Siguiente: Especificación de Requisitos ➡️](03-especificacion-requisitos.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div>