# 3. Especificación de Requisitos y Prototipos

## Sistema de Reserva de Consultas Médicas Externas

---

## 3.1. Introducción

Este documento presenta la especificación detallada de los requisitos del sistema mediante **Casos de Uso**. Cada caso de uso describe una interacción específica entre los actores del sistema y el sistema mismo, incluyendo el flujo principal, flujos alternativos, precondiciones, postcondiciones y excepciones.

Además, se incluyen referencias a los **diagramas UML** y **prototipos de interfaz** que complementan la especificación.

---

## 3.2. Actores del Sistema

### Actor 1: Paciente
**Descripción:** Persona que solicita servicios médicos y utiliza el sistema para agendar citas.

**Responsabilidades:**
- Registrarse en el sistema
- Buscar médicos por especialidad
- Reservar citas médicas
- Consultar sus citas programadas
- Cancelar citas
- Actualizar sus datos personales

**Nivel de acceso:** Usuario registrado con rol "Paciente"

---

### Actor 2: Médico
**Descripción:** Profesional de la salud que atiende consultas médicas y gestiona su agenda.

**Responsabilidades:**
- Registrarse en el sistema con datos profesionales
- Configurar su agenda de horarios de atención
- Visualizar sus citas programadas
- Actualizar el estado de las citas
- Consultar la lista de pacientes

**Nivel de acceso:** Usuario registrado con rol "Médico"

---

### Actor 3: Administrador
**Descripción:** Personal administrativo que supervisa el funcionamiento del sistema.

**Responsabilidades:**
- Gestionar usuarios (pacientes y médicos)
- Gestionar catálogos (especialidades, consultorios)
- Visualizar dashboard con métricas
- Generar reportes
- Configurar parámetros del sistema

**Nivel de acceso:** Usuario con rol "Administrador" (acceso total)

---

### Actor 4: Sistema de Notificaciones
**Descripción:** Componente automatizado que envía correos electrónicos.

**Responsabilidades:**
- Enviar confirmaciones de citas
- Enviar cancelaciones de citas
- Enviar recordatorios automáticos

**Nivel de acceso:** Sistema interno (no requiere autenticación)

---

## 3.3. Casos de Uso del Sistema

### Tabla Resumen de Casos de Uso

| **Código** | **Caso de Uso** | **Actor Principal** | **Prioridad** |
|------------|----------------|-------------------|--------------|
| CU01 | Registrar Paciente | Paciente | Alta |
| CU02 | Registrar Médico | Médico, Administrador | Alta |
| CU03 | Gestionar Agenda de Horarios | Médico | Alta |
| CU04 | Realizar Reserva de Cita | Paciente | Alta |
| CU05 | Cancelar Cita | Paciente, Médico | Alta |
| CU06 | Enviar Notificaciones | Sistema de Notificaciones | Media |
| CU07 | Actualizar Estado de Cita | Médico | Media |
| CU08 | Gestionar Panel Administrativo | Administrador | Media |
| CU09 | Iniciar Sesión | Todos los usuarios | Alta |

---

## 3.4. Especificación Detallada de Casos de Uso

---

### CU01: Registrar Paciente

#### Descripción
Este caso de uso permite a un nuevo paciente registrarse en el sistema proporcionando sus datos personales.

#### Actores Involucrados
- **Principal:** Paciente
- **Secundarios:** Sistema

#### Objetivo
Crear una cuenta de paciente en el sistema con todos los datos necesarios para poder agendar citas médicas.

#### Precondiciones
- El paciente no debe estar registrado previamente en el sistema
- El sistema debe estar en funcionamiento
- El paciente debe tener acceso a internet y un navegador web

#### Disparador o Evento Inicial
El paciente accede a la página de registro desde el menú principal del sistema.

#### Flujo Principal de Eventos

1. El paciente accede a la opción "Registrarse" en el menú principal
2. El sistema muestra el formulario de registro de paciente (Pantalla P01)
3. El paciente ingresa sus datos personales:
   - DNI (8 dígitos)
   - Nombres
   - Apellidos
   - Fecha de nacimiento
   - Género (Masculino/Femenino/Otro)
   - Dirección
   - Correo electrónico
   - Teléfono(s)
4. El paciente crea sus credenciales de acceso:
   - Nombre de usuario
   - Contraseña
   - Confirmación de contraseña
5. El paciente acepta los términos y condiciones
6. El paciente hace clic en el botón "Registrarse"
7. El sistema valida los datos ingresados:
   - Verifica que el DNI no esté registrado
   - Verifica que el email no esté registrado
   - Verifica que el nombre de usuario no esté registrado
   - Valida el formato de los campos
8. El sistema encripta la contraseña
9. El sistema registra al paciente en la base de datos
10. El sistema envía un correo de bienvenida al email registrado
11. El sistema muestra mensaje de confirmación: "Registro exitoso"
12. El sistema redirige al paciente a la página de login

#### Flujos Alternativos

**FA01: DNI ya registrado**
- En el paso 7, si el DNI ya existe en el sistema:
  - El sistema muestra mensaje de error: "El DNI ya está registrado en el sistema"
  - El sistema sugiere: "Si olvidó su contraseña, use la opción 'Recuperar contraseña'"
  - El flujo retorna al paso 3

**FA02: Email ya registrado**
- En el paso 7, si el email ya existe:
  - El sistema muestra mensaje: "Este correo electrónico ya está registrado"
  - El flujo retorna al paso 3

**FA03: Contraseñas no coinciden**
- En el paso 7, si las contraseñas no coinciden:
  - El sistema muestra mensaje: "Las contraseñas no coinciden"
  - El flujo retorna al paso 4

**FA04: Formato de datos inválido**
- En el paso 7, si algún campo tiene formato inválido:
  - El sistema marca en rojo el campo con error
  - El sistema muestra mensaje específico (ej: "El DNI debe tener 8 dígitos")
  - El flujo retorna al paso 3

**FA05: El paciente cancela el registro**
- En cualquier momento antes del paso 6:
  - El paciente hace clic en "Cancelar"
  - El sistema descarta los datos ingresados
  - El sistema retorna a la página principal
  - Fin del caso de uso

#### Postcondiciones

**Postcondición de Éxito:**
- El paciente queda registrado en la base de datos con estado "Activo"
- Se crea un usuario asociado con rol "Paciente"
- La contraseña queda almacenada de forma encriptada
- Se envía un correo de bienvenida
- El paciente puede iniciar sesión en el sistema

**Postcondición de Fracaso:**
- El paciente no queda registrado
- No se crea ningún registro en la base de datos
- No se envía correo de bienvenida

#### Excepciones

**E01: Error de conexión con la base de datos**
- El sistema muestra mensaje: "Error al conectar con la base de datos. Intente nuevamente."
- El sistema registra el error en logs
- El flujo termina

**E02: Error al enviar correo electrónico**
- El sistema registra al paciente exitosamente
- El sistema registra el error de envío de correo en logs
- El sistema muestra advertencia: "Registro exitoso. No se pudo enviar el correo de confirmación."
- El flujo continúa normalmente

**E03: Tiempo de espera agotado**
- Si el paciente no completa el formulario en 15 minutos:
  - El sistema descarta los datos ingresados
  - El sistema muestra mensaje: "La sesión ha expirado. Por favor, intente nuevamente."

#### Requerimientos Especiales
- La contraseña debe tener mínimo 8 caracteres, incluir mayúsculas, minúsculas y números
- El DNI debe validarse contra el formato peruano (8 dígitos numéricos)
- El email debe validarse con expresión regular estándar
- El formulario debe tener validación en tiempo real (mientras el usuario escribe)

#### Pantalla(s) Asociada(s)
- **P01:** Formulario de Registro de Paciente (ver [prototipos/P01-registro-paciente.png](../prototipos/P01-registro-paciente.png))

#### Frecuencia de Uso
Media - Aproximadamente 10-20 registros nuevos por semana

---

### CU02: Registrar Médico

#### Descripción
Este caso de uso permite registrar a un médico en el sistema con sus datos profesionales y especialidades.

#### Actores Involucrados
- **Principal:** Médico, Administrador
- **Secundarios:** Sistema

#### Objetivo
Crear un perfil de médico en el sistema con sus especialidades y datos profesionales para que pueda gestionar su agenda de atención.

#### Precondiciones
- El médico debe tener número de colegiatura válido
- El médico no debe estar registrado previamente
- Las especialidades médicas deben estar cargadas en el sistema

#### Disparador o Evento Inicial
El médico accede a la opción "Registro de Médico" o el administrador accede a "Gestionar Médicos > Nuevo Médico".

#### Flujo Principal de Eventos

1. El actor accede a la opción "Registrar Médico"
2. El sistema muestra el formulario de registro de médico (Pantalla P02)
3. El actor ingresa los datos personales del médico:
   - DNI (8 dígitos)
   - Nombres
   - Apellidos
   - Correo electrónico
   - Teléfono
4. El actor ingresa los datos profesionales:
   - Número de colegiatura (CMP)
   - Especialidad(es) médica(s) - selección múltiple
   - Fecha de certificación por especialidad
5. Si el actor es el propio médico:
   - Crea sus credenciales (usuario y contraseña)
6. Si el actor es administrador:
   - El sistema genera credenciales temporales
7. El actor hace clic en "Registrar"
8. El sistema valida los datos:
   - Verifica que el DNI no esté registrado
   - Verifica que el número de colegiatura no esté registrado
   - Valida que el email no esté duplicado
   - Valida el formato de los campos
9. El sistema registra al médico en la base de datos
10. El sistema asocia las especialidades seleccionadas al médico
11. El sistema crea un usuario con rol "Médico"
12. El sistema envía correo con las credenciales (si fue creado por admin)
13. El sistema muestra mensaje: "Médico registrado exitosamente"
14. El sistema redirige a la lista de médicos o al login

#### Flujos Alternativos

**FA01: Número de colegiatura ya registrado**
- En el paso 8, si el número de colegiatura ya existe:
  - El sistema muestra: "Este número de colegiatura ya está registrado"
  - El flujo retorna al paso 4

**FA02: DNI ya registrado**
- En el paso 8, si el DNI ya existe como médico:
  - El sistema verifica si existe como paciente
  - Si existe como paciente, el sistema sugiere: "Este DNI está registrado como paciente. ¿Desea actualizar el perfil a médico?"
  - Si el actor confirma, el sistema actualiza el perfil
  - Si no, el flujo retorna al paso 3

**FA03: Sin especialidades seleccionadas**
- En el paso 8, si no seleccionó ninguna especialidad:
  - El sistema muestra: "Debe seleccionar al menos una especialidad"
  - El flujo retorna al paso 4

**FA04: Error en formato de campos**
- Similar a CU01, validación de formato
- El flujo retorna al paso correspondiente

#### Postcondiciones

**Postcondición de Éxito:**
- El médico queda registrado con estado "Activo"
- Las especialidades quedan asociadas al médico
- Se crea usuario con rol "Médico"
- Se envía correo con credenciales (si aplica)
- El médico puede iniciar sesión y gestionar su agenda

**Postcondición de Fracaso:**
- No se crea ningún registro
- Las especialidades no quedan asociadas

#### Excepciones
- **E01:** Error de conexión con BD
- **E02:** Error al enviar correo
- **E03:** Especialidad no encontrada en el catálogo

#### Requerimientos Especiales
- El número de colegiatura debe tener formato: CMP-XXXXX (5 dígitos)
- Debe poder seleccionar múltiples especialidades
- Si el admin registra al médico, se generan credenciales aleatorias seguras

#### Pantalla(s) Asociada(s)
- **P02:** Formulario de Registro de Médico (ver [prototipos/P02-registro-medico.png](../prototipos/P02-registro-medico.png))

#### Frecuencia de Uso
Baja - Aproximadamente 1-5 registros nuevos por mes

---

### CU03: Gestionar Agenda de Horarios

#### Descripción
Este caso de uso permite al médico configurar su agenda de atención definiendo días, horarios y consultorios.

#### Actores Involucrados
- **Principal:** Médico
- **Secundarios:** Sistema

#### Objetivo
Establecer la disponibilidad del médico para que los pacientes puedan agendar citas en los horarios configurados.

#### Precondiciones
- El médico debe estar registrado y autenticado en el sistema
- Deben existir consultorios disponibles en el sistema
- El médico debe tener al menos una especialidad registrada

#### Disparador o Evento Inicial
El médico accede a su perfil y selecciona "Gestionar Agenda" o "Mis Horarios".

#### Flujo Principal de Eventos

1. El médico inicia sesión en el sistema
2. El médico accede a "Mi Agenda" desde el menú principal
3. El sistema muestra la vista de gestión de horarios (Pantalla P03)
4. El sistema muestra los horarios actualmente configurados (si existen)
5. El médico selecciona "Agregar Nuevo Horario"
6. El sistema muestra el formulario de configuración de horario
7. El médico configura el horario:
   - Selecciona día de la semana (Lunes a Viernes)
   - Selecciona hora de inicio (formato 24h)
   - Selecciona hora de fin
   - Selecciona consultorio de atención
   - Selecciona especialidad con la que atenderá
8. El médico hace clic en "Guardar Horario"
9. El sistema valida los datos:
   - Verifica que hora inicio < hora fin
   - Verifica que el consultorio esté disponible en ese horario
   - Verifica que no exista conflicto con otros horarios del médico
10. El sistema registra el horario en la base de datos
11. El sistema asocia el horario al médico y consultorio
12. El sistema actualiza la vista mostrando el nuevo horario
13. El sistema muestra mensaje: "Horario agregado exitosamente"

#### Flujos Alternativos

**FA01: Modificar horario existente**
- En el paso 5, el médico selecciona "Editar" en un horario existente:
  1. El sistema carga los datos del horario seleccionado
  2. El médico modifica los campos deseados
  3. El médico hace clic en "Actualizar"
  4. El sistema valida según paso 9
  5. El sistema actualiza el horario
  6. El sistema verifica si hay citas programadas en el horario modificado
  7. Si hay citas afectadas, el sistema notifica al médico
  8. El flujo continúa en paso 12

**FA02: Eliminar horario**
- En el paso 5, el médico selecciona "Eliminar" en un horario:
  1. El sistema verifica si hay citas futuras programadas en ese horario
  2. Si hay citas, el sistema muestra advertencia: "Existen X citas programadas. ¿Confirma eliminar?"
  3. Si el médico confirma:
     - El sistema marca el horario como "Inactivo"
     - El sistema notifica a los pacientes afectados
  4. Si no confirma, el flujo termina
  5. El flujo continúa en paso 12

**FA03: Conflicto de horario**
- En el paso 9, si existe conflicto con otro horario del médico:
  - El sistema muestra: "Ya tiene un horario configurado de HH:MM a HH:MM los días XXXX"
  - El sistema sugiere horarios alternativos disponibles
  - El flujo retorna al paso 7

**FA04: Consultorio no disponible**
- En el paso 9, si el consultorio ya está ocupado:
  - El sistema muestra: "El consultorio está ocupado en ese horario"
  - El sistema muestra consultorios disponibles en ese horario
  - El flujo retorna al paso 7

**FA05: Visualizar calendario de agenda**
- En el paso 5, el médico selecciona "Ver Calendario":
  - El sistema muestra una vista de calendario semanal
  - Se visualizan los bloques de horarios configurados
  - El médico puede hacer clic en un bloque para editarlo
  - El flujo retorna al paso 3

#### Postcondiciones

**Postcondición de Éxito:**
- El horario queda registrado y activo en el sistema
- El horario está disponible para que pacientes agenden citas
- El consultorio queda reservado para el médico en ese horario
- Los cambios se reflejan inmediatamente en el sistema de reservas

**Postcondición de Fracaso:**
- No se registra ningún horario
- El estado del sistema permanece sin cambios

#### Excepciones

**E01: Error de validación de horarios**
- El sistema muestra mensaje específico del error
- El flujo retorna al paso de ingreso de datos

**E02: Error al guardar en base de datos**
- El sistema muestra: "No se pudo guardar el horario. Intente nuevamente."
- El sistema registra el error en logs

**E03: Cambios simultáneos**
- Si otro proceso modifica el mismo horario simultáneamente:
  - El sistema detecta conflicto de concurrencia
  - El sistema recarga los datos actualizados
  - El sistema notifica al médico del conflicto

#### Requerimientos Especiales
- El sistema debe permitir configurar horarios en bloques de 30 minutos
- Debe validar que no se configuren horarios en horarios no laborales (antes de 7:00 AM o después de 9:00 PM)
- Debe mostrar visualmente los horarios ya ocupados
- Debe permitir copiar un horario a múltiples días

#### Reglas de Negocio
- **RN01:** Cada bloque de atención es de 30 minutos
- **RN02:** Un médico no puede tener dos horarios simultáneos
- **RN03:** Un consultorio solo puede ser usado por un médico a la vez
- **RN04:** Se debe notificar a pacientes si se elimina un horario con citas programadas
- **RN05:** Los horarios se configuran de Lunes a Viernes

#### Pantalla(s) Asociada(s)
- **P03:** Gestión de Agenda de Horarios (ver [prototipos/P03-agenda-horarios.png](../prototipos/P03-agenda-horarios.png))

#### Frecuencia de Uso
Media - Cada médico configura su agenda 1 vez por semana (o al inicio)

---

### CU04: Realizar Reserva de Cita

#### Descripción
Este caso de uso permite al paciente buscar médicos, ver horarios disponibles y reservar una cita médica.

#### Actores Involucrados
- **Principal:** Paciente
- **Secundarios:** Sistema, Sistema de Notificaciones

#### Objetivo
Agendar una cita médica exitosamente con un médico de la especialidad requerida en un horario disponible.

#### Precondiciones
- El paciente debe estar registrado y autenticado
- Debe haber al menos un médico con horarios disponibles
- La fecha de la cita debe ser futura (no se pueden agendar citas en el pasado)

#### Disparador o Evento Inicial
El paciente accede a la opción "Agendar Nueva Cita" desde el menú principal.

#### Flujo Principal de Eventos

1. El paciente inicia sesión en el sistema
2. El paciente selecciona "Agendar Cita" en el menú
3. El sistema muestra el formulario de búsqueda (Pantalla P04)
4. El paciente selecciona:
   - Especialidad médica (lista desplegable)
5. El sistema busca y muestra la lista de médicos que tienen esa especialidad
6. El sistema muestra para cada médico:
   - Nombre completo
   - Número de colegiatura
   - Consultorios donde atiende
7. El paciente selecciona un médico de la lista
8. El paciente selecciona una fecha (mediante calendario)
9. El sistema valida que la fecha sea futura
10. El sistema consulta los horarios disponibles del médico para esa fecha
11. El sistema muestra los horarios disponibles en bloques de 30 minutos:
    - Ejemplo: 09:00 - 09:30, 09:30 - 10:00, etc.
    - Muestra consultorio asignado para cada horario
12. El paciente selecciona un horario disponible
13. El paciente ingresa el motivo de la consulta (campo de texto)
14. El paciente revisa el resumen de la cita:
    - Médico
    - Especialidad
    - Fecha y hora
    - Consultorio
    - Motivo de consulta
15. El paciente hace clic en "Confirmar Reserva"
16. El sistema valida que el horario aún esté disponible (validación de concurrencia)
17. El sistema crea la cita con estado "Pendiente"
18. El sistema asocia la cita al paciente y al médico
19. El sistema genera un código único de cita
20. El sistema actualiza el estado de la cita a "Confirmada"
21. El sistema invoca al Sistema de Notificaciones (CU06)
22. El sistema muestra mensaje de éxito con el código de cita
23. El sistema ofrece opciones:
    - Ver detalles de la cita
    - Agregar a calendario
    - Agendar otra cita
    - Volver al inicio

#### Flujos Alternativos

**FA01: No hay médicos disponibles para la especialidad**
- En el paso 5, si no hay médicos con esa especialidad:
  - El sistema muestra: "No hay médicos disponibles para esta especialidad"
  - El sistema sugiere: "Intente con otra especialidad o contacte con administración"
  - El flujo retorna al paso 4

**FA02: No hay horarios disponibles en la fecha seleccionada**
- En el paso 11, si el médico no tiene horarios ese día:
  - El sistema muestra: "El médico no tiene horarios disponibles para esta fecha"
  - El sistema muestra las próximas fechas con disponibilidad
  - El paciente puede:
    - Seleccionar otra fecha sugerida
    - Seleccionar otro médico
  - El flujo retorna al paso 8 o paso 7 según elección

**FA03: Horario seleccionado ya no disponible (reservado por otro paciente)**
- En el paso 16, si el horario fue reservado por otro usuario:
  - El sistema muestra: "Lo sentimos, este horario acaba de ser reservado"
  - El sistema actualiza la lista de horarios disponibles
  - El flujo retorna al paso 11

**FA04: Fecha seleccionada en el pasado**
- En el paso 9, si la fecha es pasada:
  - El sistema muestra: "No se pueden agendar citas en fechas pasadas"
  - El flujo retorna al paso 8

**FA05: Paciente cancela la reserva antes de confirmar**
- En cualquier momento antes del paso 15:
  - El paciente hace clic en "Cancelar"
  - El sistema descarta los datos temporales
  - El sistema retorna al menú principal
  - Fin del caso de uso

**FA06: Buscar médico por nombre**
- En el paso 4, el paciente puede:
  - Ingresar el nombre del médico en un campo de búsqueda
  - El sistema busca médicos por nombre/apellido
  - El sistema muestra resultados coincidentes
  - El flujo continúa en paso 7

#### Postcondiciones

**Postcondición de Éxito:**
- La cita queda registrada en estado "Confirmada"
- El horario queda marcado como "Ocupado"
- El paciente y médico quedan asociados a la cita
- Se envía notificación por correo al paciente
- Se envía notificación al médico
- La cita aparece en "Mis Citas" del paciente
- La cita aparece en "Mi Agenda" del médico

**Postcondición de Fracaso:**
- No se crea ninguna cita
- El horario permanece disponible
- No se envían notificaciones

#### Excepciones

**E01: Error de conexión durante la confirmación**
- El sistema intenta confirmar la reserva 3 veces
- Si falla, el sistema muestra: "Error al confirmar la cita. Por favor, intente nuevamente."
- El sistema registra el error
- Los datos temporales se mantienen para reintentar

**E02: Error al enviar notificación**
- La cita se confirma exitosamente
- El sistema registra el error de notificación
- El sistema muestra advertencia: "Cita confirmada. No se pudo enviar la notificación por correo."
- El flujo continúa normalmente

**E03: Paciente tiene cita pendiente con el mismo médico**
- El sistema detecta duplicado
- El sistema advierte: "Ya tiene una cita pendiente con este médico el DD/MM/AAAA"
- El sistema pregunta: "¿Desea continuar?"
- Si acepta, el flujo continúa
- Si cancela, el flujo termina

#### Requerimientos Especiales
- El formulario debe ser responsive (funcionar en móviles)
- La búsqueda de horarios debe ser en tiempo real
- Debe implementarse un timeout de 5 minutos para completar la reserva
- Debe haber validación de disponibilidad antes de confirmar (evitar doble reserva)

#### Reglas de Negocio
- **RN01:** Una cita tiene duración estándar de 30 minutos
- **RN02:** Un paciente no puede tener más de 3 citas pendientes simultáneamente
- **RN03:** No se pueden agendar citas con menos de 2 horas de anticipación
- **RN04:** No se pueden agendar citas con más de 60 días de anticipación
- **RN05:** El motivo de consulta es obligatorio y debe tener mínimo 10 caracteres

#### Pantalla(s) Asociada(s)
- **P04:** Formulario de Reserva de Cita (ver [prototipos/P04-reserva-cita.png](../prototipos/P04-reserva-cita.png))

#### Frecuencia de Uso
Alta - Se espera que sea la funcionalidad más utilizada (50-100 reservas diarias)

---

### CU05: Cancelar Cita

#### Descripción
Este caso de uso permite al paciente o al médico cancelar una cita previamente agendada.

#### Actores Involucrados
- **Principal:** Paciente, Médico
- **Secundarios:** Sistema de Notificaciones

#### Objetivo
Cancelar una cita médica liberando el horario para que pueda ser utilizado por otro paciente.

#### Precondiciones
- El actor debe estar autenticado
- Debe existir una cita en estado "Pendiente" o "Confirmada"
- La fecha de la cita debe ser futura

#### Disparador o Evento Inicial
El actor accede a "Mis Citas" y selecciona la opción "Cancelar" en una cita específica.

#### Flujo Principal de Eventos

1. El actor inicia sesión en el sistema
2. El actor accede a "Mis Citas" (Pantalla P05 para paciente)
3. El sistema muestra la lista de citas:
   - Citas pendientes
   - Citas confirmadas
   - Citas pasadas (historial)
4. El sistema muestra para cada cita:
   - Código de cita
   - Fecha y hora
   - Médico (si es paciente) o Paciente (si es médico)
   - Especialidad
   - Consultorio
   - Estado actual
   - Botón "Cancelar" (solo para citas futuras)
5. El actor selecciona "Cancelar" en una cita específica
6. El sistema valida que la cita esté en estado "Pendiente" o "Confirmada"
7. El sistema muestra ventana de confirmación:
   - Detalles de la cita a cancelar
   - Campo obligatorio: "Motivo de cancelación"
   - Advertencia: "Esta acción no se puede deshacer"
8. El actor ingresa el motivo de cancelación
9. El actor confirma haciendo clic en "Sí, Cancelar Cita"
10. El sistema valida el motivo (mínimo 10 caracteres)
11. El sistema actualiza el estado de la cita a "Cancelada"
12. El sistema registra la fecha/hora de cancelación
13. El sistema registra el motivo de cancelación
14. El sistema registra quién canceló la cita
15. El sistema libera el horario del médico
16. El sistema invoca al Sistema de Notificaciones (CU06):
    - Notifica al paciente (si canceló el médico)
    - Notifica al médico (si canceló el paciente)
17. El sistema actualiza la vista de "Mis Citas"
18. El sistema muestra mensaje: "Cita cancelada exitosamente"

#### Flujos Alternativos

**FA01: Actor cancela la confirmación**
- En el paso 9, el actor hace clic en "No, Mantener Cita":
  - El sistema cierra la ventana de confirmación
  - El sistema retorna a la lista de citas
  - Fin del caso de uso

**FA02: Intento de cancelar cita ya atendida**
- En el paso 6, si la cita está en estado "Atendida":
  - El sistema muestra: "No se puede cancelar una cita que ya fue atendida"
  - El sistema oculta el botón "Cancelar" para esa cita
  - Fin del caso de uso

**FA03: Intento de cancelar cita con menos de 2 horas de anticipación (Regla de negocio)**
- En el paso 6, si faltan menos de 2 horas para la cita:
  - El sistema muestra advertencia: "Solo se puede cancelar con al menos 2 horas de anticipación"
  - El sistema sugiere: "Por favor, contacte directamente con la institución"
  - El sistema ofrece opción de contacto (teléfono/email)
  - Fin del caso de uso

**FA04: Motivo de cancelación muy corto**
- En el paso 10, si el motivo tiene menos de 10 caracteres:
  - El sistema muestra: "El motivo debe tener al menos 10 caracteres"
  - El flujo retorna al paso 8

**FA05: Ver historial de cancelaciones**
- En el paso 3, el actor selecciona filtro "Citas Canceladas":
  - El sistema muestra solo las citas canceladas
  - Para cada cita muestra: motivo de cancelación y quién canceló
  - El flujo retorna al paso 3

#### Postcondiciones

**Postcondición de Éxito:**
- La cita cambia a estado "Cancelada"
- Se registra fecha, hora y motivo de cancelación
- Se registra quién realizó la cancelación
- El horario del médico queda disponible nuevamente
- Se envían notificaciones a ambas partes
- La cita aparece en el historial como "Cancelada"

**Postcondición de Fracaso:**
- La cita mantiene su estado original
- El horario permanece ocupado
- No se envían notificaciones

#### Excepciones

**E01: Error al actualizar estado**
- El sistema intenta actualizar 3 veces
- Si falla, muestra: "Error al cancelar la cita. Intente nuevamente."
- Se registra el error en logs

**E02: Error al liberar horario**
- La cita se marca como cancelada
- El sistema registra error en la liberación del horario
- El sistema alerta al administrador para corrección manual

**E03: Error al enviar notificación**
- La cancelación se completa exitosamente
- Se muestra advertencia sobre la notificación
- Se registra el error

#### Requerimientos Especiales
- Debe haber doble confirmación para evitar cancelaciones accidentales
- El sistema debe registrar métricas de cancelaciones por médico y paciente
- Debe permitir exportar historial de citas canceladas

#### Reglas de Negocio
- **RN01:** Las citas solo pueden cancelarse con al menos 2 horas de anticipación
- **RN02:** El motivo de cancelación es obligatorio
- **RN03:** Si un paciente cancela más de 3 citas en un mes, se debe alertar al administrador
- **RN04:** Si un médico cancela una cita, debe reprogramarse automáticamente
- **RN05:** Las citas canceladas no se eliminan, se mantienen en el historial

#### Pantalla(s) Asociada(s)
- **P05:** Lista de Mis Citas (ver [prototipos/P05-mis-citas-paciente.png](../prototipos/P05-mis-citas-paciente.png))

#### Frecuencia de Uso
Media - Se espera 5-10% de cancelaciones sobre el total de citas agendadas

---

### CU06: Enviar Notificaciones

#### Descripción
Este caso de uso describe el proceso automatizado de envío de notificaciones por correo electrónico.

#### Actores Involucrados
- **Principal:** Sistema de Notificaciones (proceso automatizado)
- **Secundarios:** Paciente, Médico

#### Objetivo
Informar a los usuarios sobre eventos importantes del sistema (confirmación de cita, cancelación, recordatorios).

#### Precondiciones
- El servicio SMTP debe estar configurado y funcionando
- Los usuarios deben tener correos electrónicos válidos registrados
- Debe existir una plantilla de correo para cada tipo de notificación

#### Disparador o Evento Inicial
- Se confirma una nueva cita (CU04)
- Se cancela una cita (CU05)
- Se actualiza el estado de una cita (CU07)
- Se ejecuta el proceso automático de recordatorios (24 horas antes de cada cita)

#### Flujo Principal de Eventos

**Subflujo: Notificación de Confirmación de Cita**
1. El sistema detecta que se confirmó una nueva cita
2. El sistema obtiene los datos de la cita:
   - Código de cita
   - Fecha y hora
   - Datos del paciente (nombre, email)
   - Datos del médico (nombre, especialidad)
   - Consultorio
   - Motivo de consulta
3. El sistema selecciona la plantilla "Confirmación de Cita"
4. El sistema personaliza la plantilla con los datos de la cita
5. El sistema envía el correo al paciente
6. El sistema envía el correo al médico
7. El sistema registra el envío en la tabla `notificacion`:
   - Fecha y hora de envío
   - Tipo: "CONFIRMACION"
   - Destinatarios
   - Estado: "ENVIADO" o "ERROR"
8. Si el envío fue exitoso:
   - El sistema marca la notificación como "ENVIADO"
9. Si hubo error:
   - El sistema marca como "ERROR"
   - El sistema reintenta hasta 3 veces
   - Si persiste el error, registra en logs

**Subflujo: Notificación de Cancelación**
1. El sistema detecta que se canceló una cita
2. El sistema obtiene los datos de la cita cancelada
3. El sistema obtiene el motivo de cancelación
4. El sistema selecciona la plantilla "Cancelación de Cita"
5. El sistema personaliza la plantilla
6. El sistema envía correo a la parte afectada:
   - Si canceló el paciente → notifica al médico
   - Si canceló el médico → notifica al paciente
7. El sistema registra el envío

**Subflujo: Recordatorio Automático**
1. El sistema ejecuta un proceso programado (cron job) cada hora
2. El sistema consulta citas confirmadas que son en 24 horas
3. Para cada cita encontrada:
   - Verifica que no se haya enviado recordatorio previamente
   - Selecciona la plantilla "Recordatorio de Cita"
   - Personaliza la plantilla con datos de la cita
   - Envía correo al paciente
   - Marca la cita como "Recordatorio Enviado"
   - Registra el envío en tabla notificacion

#### Flujos Alternativos

**FA01: Correo electrónico inválido o inexistente**
- En el paso 5 o 6, si el correo no es válido:
  - El sistema registra error: "Email inválido"
  - El sistema alerta al administrador
  - El flujo continúa con otros destinatarios

**FA02: Servicio SMTP no disponible**
- Si no hay conexión con el servidor SMTP:
  - El sistema encola los correos para envío posterior
  - El sistema reintenta cada 30 minutos
  - Después de 3 intentos, alerta al administrador

**FA03: Destinatario ha deshabilitado notificaciones**
- Si el usuario ha desactivado notificaciones en su perfil:
  - El sistema no envía el correo
  - El sistema registra: "Notificación omitida por preferencia del usuario"

#### Postcondiciones

**Postcondición de Éxito:**
- El correo es recibido por el destinatario
- Se registra el envío en la base de datos
- El usuario está informado sobre el evento

**Postcondición de Fracaso:**
- El correo no es enviado
- Se registra el error
- Se programa reintento

#### Excepciones

**E01: Plantilla de correo no encontrada**
- El sistema usa una plantilla genérica por defecto
- Se registra el error
- Se alerta al administrador

**E02: Exceso de correos rechazados (spam)**
- El sistema detecta tasa alta de rebote
- Se pausa el envío temporalmente
- Se alerta al administrador para revisar configuración

#### Requerimientos Especiales
- Los correos deben tener diseño responsive (HTML)
- Deben incluir botones de acción (Ver Cita, Cancelar, etc.)
- Deben tener footer con información de contacto
- Deben respetar el límite de envío del proveedor SMTP (ej: Gmail 500/día)

#### Reglas de Negocio
- **RN01:** Los recordatorios se envían exactamente 24 horas antes de la cita
- **RN02:** No se envían recordatorios para citas canceladas
- **RN03:** Si un correo falla 3 veces, se marca como "ERROR_PERMANENTE"
- **RN04:** Los usuarios pueden deshabilitar notificaciones en su perfil

#### Contenido de las Plantillas de Correo

**Plantilla: Confirmación de Cita**
```
Asunto: Confirmación de Cita Médica - [Código Cita]

Hola [Nombre Paciente],

Su cita ha sido confirmada exitosamente:

✅ Código de Cita: [Código]
👨‍⚕️ Médico: Dr(a). [Nombre Médico]
🏥 Especialidad: [Especialidad]
📅 Fecha: [DD/MM/AAAA]
🕐 Hora: [HH:MM]
🚪 Consultorio: [Nombre Consultorio] - Piso [X]

📝 Motivo: [Motivo consulta]

Por favor, llegue 10 minutos antes de su cita.

[Botón: Ver Detalles] [Botón: Cancelar Cita]

Gracias por confiar en nosotros.
[Firma del Sistema]
```

**Plantilla: Cancelación de Cita**
```
Asunto: Cita Médica Cancelada - [Código Cita]

Hola [Nombre],

Le informamos que la cita con código [Código] ha sido cancelada.

❌ Motivo: [Motivo Cancelación]

Puede agendar una nueva cita cuando lo desee.

[Botón: Agendar Nueva Cita]

[Firma del Sistema]
```

**Plantilla: Recordatorio**
```
Asunto: Recordatorio: Cita Médica Mañana

Hola [Nombre Paciente],

Le recordamos su cita médica programada para mañana:

⏰ Fecha: [DD/MM/AAAA]
🕐 Hora: [HH:MM]
👨‍⚕️ Médico: Dr(a). [Nombre Médico]
🚪 Consultorio: [Consultorio]

Por favor, no olvide asistir. Si no puede acudir, cancele con anticipación.

[Botón: Ver Detalles] [Botón: Cancelar]

[Firma del Sistema]
```

#### Pantalla(s) Asociada(s)
- **P07:** Plantillas de Notificaciones (ver [prototipos/P07-notificaciones.png](../prototipos/P07-notificaciones.png))

#### Frecuencia de Uso
Muy Alta - Se ejecuta automáticamente para cada evento (100+ correos diarios)

---

### CU07: Actualizar Estado de Cita

#### Descripción
Este caso de uso permite al médico actualizar el estado de una cita después de la consulta.

#### Actores Involucrados
- **Principal:** Médico
- **Secundarios:** Sistema

#### Objetivo
Registrar el resultado de la consulta actualizando el estado de la cita (Atendida, No Presentado).

#### Precondiciones
- El médico debe estar autenticado
- Debe existir una cita en estado "Confirmada"
- La fecha de la cita debe ser igual o anterior a hoy

#### Disparador o Evento Inicial
El médico accede a su agenda y selecciona una cita para actualizar su estado.

#### Flujo Principal de Eventos

1. El médico inicia sesión en el sistema
2. El médico accede a "Mi Agenda"
3. El sistema muestra las citas del día actual
4. El sistema filtra por defecto las citas en estado "Confirmada"
5. Para cada cita muestra:
   - Hora de atención
   - Nombre del paciente
   - Motivo de consulta
   - Estado actual
   - Botón "Actualizar Estado"
6. El médico selecciona "Actualizar Estado" en una cita
7. El sistema muestra ventana modal con opciones:
   - ✅ Atendida (cita fue realizada)
   - ❌ No Presentado (paciente no asistió)
   - Campo opcional: "Observaciones"
8. El médico selecciona el nuevo estado
9. El médico ingresa observaciones (opcional)
10. El médico hace clic en "Guardar"
11. El sistema valida el cambio de estado
12. El sistema actualiza el estado de la cita
13. El sistema registra la fecha/hora de actualización
14. El sistema registra las observaciones (si las hay)
15. El sistema actualiza la vista de agenda
16. El sistema muestra mensaje: "Estado actualizado exitosamente"

#### Flujos Alternativos

**FA01: Marcar múltiples citas como atendidas**
- En el paso 6, el médico selecciona checkbox en varias citas:
  - El médico hace clic en "Marcar seleccionadas como Atendidas"
  - El sistema actualiza en lote todas las citas seleccionadas
  - El flujo continúa en paso 15

**FA02: Ver citas de otro día**
- En el paso 3, el médico selecciona una fecha en el calendario:
  - El sistema carga las citas de esa fecha
  - El flujo continúa en paso 4

**FA03: Filtrar citas por estado**
- En el paso 4, el médico selecciona un filtro:
  - "Todas"
  - "Confirmadas"
  - "Atendidas"
  - "No Presentado"
  - El sistema aplica el filtro
  - El flujo continúa en paso 5

**FA04: Agregar notas médicas (opcional)**
- En el paso 9, si el médico agrega observaciones detalladas:
  - El sistema permite texto de hasta 500 caracteres
  - Las observaciones quedan registradas en la cita
  - Solo el médico puede ver estas notas

#### Postcondiciones

**Postcondición de Éxito:**
- El estado de la cita se actualiza correctamente
- Se registra fecha/hora de actualización
- Las observaciones quedan almacenadas
- Las métricas del sistema se actualizan

**Postcondición de Fracaso:**
- El estado de la cita no cambia
- No se registran observaciones

#### Excepciones

**E01: Intento de actualizar cita futura**
- El sistema valida que la fecha de la cita sea hoy o pasada
- Si es futura: "No se puede actualizar el estado de una cita futura"

**E02: Error al guardar cambios**
- El sistema muestra: "Error al actualizar. Intente nuevamente."
- El sistema registra el error

#### Requerimientos Especiales
- Debe ser posible actualizar el estado en modo offline (sincroniza después)
- Debe haber opción de deshacer el último cambio (en 5 minutos)

#### Reglas de Negocio
- **RN01:** Solo el médico asignado puede actualizar el estado
- **RN02:** Una vez marcada como "Atendida", no se puede cambiar a otro estado
- **RN03:** Las citas marcadas como "No Presentado" generan estadísticas
- **RN04:** Después de 2 días, si una cita sigue "Confirmada", se marca automáticamente como "No Presentado"

#### Pantalla(s) Asociada(s)
- **P03:** Mi Agenda (médico)

#### Frecuencia de Uso
Alta - Cada médico actualiza 10-30 citas por día

---

### CU08: Gestionar Panel Administrativo

#### Descripción
Este caso de uso permite al administrador supervisar el sistema mediante un dashboard con métricas y gestionar catálogos.

#### Actores Involucrados
- **Principal:** Administrador
- **Secundarios:** Sistema

#### Objetivo
Proporcionar visibilidad del funcionamiento del sistema y permitir gestionar configuraciones y catálogos.

#### Precondiciones
- El usuario debe tener rol "Administrador"
- Debe estar autenticado en el sistema

#### Disparador o Evento Inicial
El administrador inicia sesión y accede al panel de control.

#### Flujo Principal de Eventos

**Subflujo: Visualizar Dashboard**
1. El administrador inicia sesión
2. El sistema redirige automáticamente al dashboard (Pantalla P06)
3. El sistema muestra las siguientes métricas:
   - **Total de Pacientes Registrados**
   - **Total de Médicos Activos**
   - **Citas del Día:** (Confirmadas / Atendidas / Canceladas)
   - **Citas de la Semana:** (Total / Por especialidad)
   - **Tasa de Cancelación:** (Porcentaje)
   - **Tasa de No Presentación:** (Porcentaje)
   - **Médicos Más Solicitados:** (Top 5)
   - **Especialidades Más Solicitadas:** (Top 5)
   - **Horarios Pico:** (Gráfico de barras)
4. El sistema muestra gráficos visuales:
   - Gráfico de líneas: Citas por semana (último mes)
   - Gráfico de pastel: Distribución por especialidad
   - Gráfico de barras: Citas por médico
5. El sistema permite filtrar por:
   - Rango de fechas
   - Especialidad
   - Médico
6. El sistema ofrece opciones de navegación:
   - Gestionar Pacientes
   - Gestionar Médicos
   - Gestionar Especialidades
   - Gestionar Consultorios
   - Generar Reportes

**Subflujo: Gestionar Especialidades**
1. El administrador selecciona "Gestionar Especialidades"
2. El sistema muestra lista de especialidades existentes:
   - Código
   - Nombre
   - Descripción
   - Número de médicos asociados
   - Botones: Editar / Eliminar
3. El administrador puede:
   - Agregar nueva especialidad
   - Editar especialidad existente
   - Eliminar especialidad (solo si no tiene médicos asociados)

**Subflujo: Gestionar Consultorios**
1. El administrador selecciona "Gestionar Consultorios"
2. El sistema muestra lista de consultorios:
   - Código
   - Nombre
   - Piso
   - Capacidad
   - Estado (Activo/Inactivo)
   - Botones: Editar / Desactivar
3. El administrador puede:
   - Agregar nuevo consultorio
   - Editar datos del consultorio
   - Activar/Desactivar consultorio

**Subflujo: Generar Reportes**
1. El administrador selecciona "Generar Reportes"
2. El sistema muestra opciones:
   - Reporte de citas por especialidad
   - Reporte de citas por médico
   - Reporte de cancelaciones
   - Reporte de no presentaciones
   - Reporte de pacientes más frecuentes
3. El administrador selecciona tipo de reporte
4. El administrador selecciona parámetros:
   - Rango de fechas
   - Filtros adicionales
5. El administrador hace clic en "Generar"
6. El sistema procesa los datos
7. El sistema muestra el reporte en pantalla
8. El sistema ofrece opciones:
   - Exportar a PDF
   - Exportar a Excel
   - Imprimir
   - Enviar por correo

#### Flujos Alternativos

**FA01: Buscar Paciente**
- El administrador usa el buscador de pacientes:
  - Ingresa DNI, nombre o apellido
  - El sistema busca y muestra resultados
  - El administrador puede ver detalles o editar

**FA02: Buscar Médico**
- Similar a buscar paciente

**FA03: Ver Historial de un Paciente**
- El administrador selecciona un paciente
- El sistema muestra todas sus citas (pasadas y futuras)
- El sistema muestra estadísticas del paciente

#### Postcondiciones

**Postcondición de Éxito:**
- El administrador visualiza métricas actualizadas
- Los cambios en catálogos se guardan correctamente
- Los reportes se generan exitosamente

#### Excepciones

**E01: Error al cargar métricas**
- El sistema muestra valores por defecto o ceros
- El sistema registra el error

**E02: Error al generar reporte**
- El sistema muestra: "No se pudo generar el reporte"

#### Requerimientos Especiales
- El dashboard debe actualizarse en tiempo real (WebSocket)
- Los gráficos deben ser interactivos
- Los reportes deben generarse en menos de 10 segundos

#### Reglas de Negocio
- **RN01:** Solo usuarios con rol Admin pueden acceder
- **RN02:** No se pueden eliminar especialidades con médicos asociados
- **RN03:** No se pueden desactivar consultorios con citas futuras

#### Pantalla(s) Asociada(s)
- **P06:** Panel de Control Administrador (ver [prototipos/P06-panel-admin.png](../prototipos/P06-panel-admin.png))

#### Frecuencia de Uso
Media - Los administradores revisan el dashboard varias veces al día

---

### CU09: Iniciar Sesión

#### Descripción
Este caso de uso permite a los usuarios autenticarse en el sistema.

#### Actores Involucrados
- **Principal:** Paciente, Médico, Administrador
- **Secundarios:** Sistema

#### Objetivo
Verificar la identidad del usuario y conceder acceso al sistema según su rol.

#### Precondiciones
- El usuario debe estar registrado en el sistema
- El usuario debe conocer sus credenciales (usuario y contraseña)

#### Disparador o Evento Inicial
El usuario accede a la URL del sistema.

#### Flujo Principal de Eventos

1. El usuario accede a la página principal del sistema
2. El sistema muestra el formulario de login
3. El usuario ingresa:
   - Nombre de usuario (o email)
   - Contraseña
4. El usuario hace clic en "Iniciar Sesión"
5. El sistema valida el formato de los datos
6. El sistema busca el usuario en la base de datos
7. El sistema verifica la contraseña encriptada
8. Si las credenciales son correctas:
   - El sistema crea una sesión
   - El sistema genera un token de autenticación (JWT)
   - El sistema registra el login en logs
   - El sistema obtiene el rol del usuario
9. El sistema redirige según el rol:
   - Paciente → Página principal con "Agendar Cita"
   - Médico → Mi Agenda
   - Administrador → Dashboard
10. El sistema muestra mensaje de bienvenida: "Bienvenido, [Nombre]"

#### Flujos Alternativos

**FA01: Credenciales incorrectas**
- En el paso 7, si la contraseña es incorrecta:
  - El sistema incrementa contador de intentos fallidos
  - El sistema muestra: "Usuario o contraseña incorrectos"
  - Si intentos fallidos >= 3:
    - El sistema bloquea temporalmente la cuenta (15 minutos)
    - El sistema muestra: "Cuenta bloqueada temporalmente por seguridad"
  - El flujo retorna al paso 3

**FA02: Usuario no existe**
- En el paso 6, si el usuario no existe:
  - El sistema muestra: "Usuario o contraseña incorrectos" (por seguridad, mismo mensaje)
  - El flujo retorna al paso 3

**FA03: Cuenta desactivada**
- En el paso 6, si la cuenta está inactiva:
  - El sistema muestra: "Su cuenta ha sido desactivada. Contacte al administrador."
  - Fin del caso de uso

**FA04: Recuperar contraseña**
- En el paso 3, el usuario hace clic en "¿Olvidó su contraseña?":
  1. El sistema muestra formulario de recuperación
  2. El usuario ingresa su email
  3. El sistema verifica que el email existe
  4. El sistema genera un token de recuperación
  5. El sistema envía correo con enlace de recuperación
  6. El usuario hace clic en el enlace
  7. El sistema valida el token
  8. El sistema muestra formulario de nueva contraseña
  9. El usuario ingresa y confirma nueva contraseña
  10. El sistema actualiza la contraseña
  11. El sistema muestra: "Contraseña actualizada exitosamente"
  12. El flujo retorna al paso 2

**FA05: Recordar sesión**
- En el paso 3, el usuario marca checkbox "Recordarme":
  - El sistema extiende la duración de la sesión a 30 días
  - El sistema almacena token en localStorage

#### Postcondiciones

**Postcondición de Éxito:**
- El usuario queda autenticado
- Se crea una sesión activa
- Se genera un token JWT válido
- El usuario accede a funcionalidades según su rol

**Postcondición de Fracaso:**
- El usuario no queda autenticado
- No se crea sesión
- El usuario permanece en la página de login

#### Excepciones

**E01: Error de conexión con BD**
- El sistema muestra: "Error de conexión. Intente más tarde."

**E02: Error al generar token**
- El sistema registra el error
- El sistema muestra: "Error al iniciar sesión. Intente nuevamente."

#### Requerimientos Especiales
- Las contraseñas deben estar encriptadas con BCrypt
- El sistema debe implementar protección contra ataques de fuerza bruta
- Debe haber timeout de sesión por inactividad (30 minutos)
- Debe implementarse HTTPS para proteger las credenciales en tránsito

#### Reglas de Negocio
- **RN01:** Después de 3 intentos fallidos, bloquear cuenta por 15 minutos
- **RN02:** Las sesiones expiran después de 30 minutos de inactividad
- **RN03:** El token de recuperación de contraseña expira en 1 hora
- **RN04:** No permitir contraseñas comunes o muy simples

#### Pantalla(s) Asociada(s)
- Formulario de Login
- Formulario de Recuperación de Contraseña

#### Frecuencia de Uso
Muy Alta - Cada usuario inicia sesión al menos una vez por visita

---

## 3.5. Diagramas UML

Los siguientes diagramas complementan la especificación de casos de uso:

### 3.5.1. Diagrama de Casos de Uso General
**Ubicación:** [diagramas/casos-uso-general.png](../diagramas/casos-uso-general.png)

Muestra todos los casos de uso del sistema y su relación con los actores principales.

### 3.5.2. Diagrama de Casos de Uso por Actor

#### Paciente
**Ubicación:** [diagramas/casos-uso-paciente.png](../diagramas/casos-uso-paciente.png)

Casos de uso:
- CU01: Registrar Paciente
- CU04: Realizar Reserva de Cita
- CU05: Cancelar Cita
- CU09: Iniciar Sesión

#### Médico
**Ubicación:** [diagramas/casos-uso-medico.png](../diagramas/casos-uso-medico.png)

Casos de uso:
- CU02: Registrar Médico
- CU03: Gestionar Agenda de Horarios
- CU05: Cancelar Cita
- CU07: Actualizar Estado de Cita
- CU09: Iniciar Sesión

#### Administrador
**Ubicación:** [diagramas/casos-uso-admin.png](../diagramas/casos-uso-admin.png)

Casos de uso:
- CU02: Registrar Médico
- CU08: Gestionar Panel Administrativo
- CU09: Iniciar Sesión

### 3.5.3. Diagramas de Secuencia

Los diagramas de secuencia muestran la interacción entre objetos a lo largo del tiempo:

- **Registrar Paciente:** [diagramas/secuencia-registrar-paciente.png](../diagramas/secuencia-registrar-paciente.png)
- **Reservar Cita:** [diagramas/secuencia-reservar-cita.png](../diagramas/secuencia-reservar-cita.png)
- **Cancelar Cita:** [diagramas/secuencia-cancelar-cita.png](../diagramas/secuencia-cancelar-cita.png)

### 3.5.4. Diagrama de Actividades

Muestra el flujo de procesos del negocio:

- **Proceso de Reserva Completo:** [diagramas/actividades-proceso-reserva.png](../diagramas/actividades-proceso-reserva.png)

### 3.5.5. Diagrama de Estados

Muestra los estados de la entidad Cita:

- **Estados de una Cita:** [diagramas/estados-cita.png](../diagramas/estados-cita.png)

Estados posibles:
- **Pendiente:** Cita recién creada
- **Confirmada:** Cita confirmada por el sistema
- **Atendida:** Paciente fue atendido
- **Cancelada:** Cita fue cancelada
- **No Presentado:** Paciente no asistió

Transiciones:
- Pendiente → Confirmada (automática tras validación)
- Confirmada → Atendida (médico actualiza)
- Confirmada → Cancelada (paciente o médico cancela)
- Confirmada → No Presentado (automático si pasa la fecha sin atender)

---

## 3.6. Prototipos de Interfaces

Los prototipos de interfaz proporcionan una representación visual de cómo se verán las pantallas del sistema.

### P01: Registro de Paciente
**Ubicación:** [prototipos/P01-registro-paciente.png](../prototipos/P01-registro-paciente.png)

**Descripción:** Formulario de registro con campos para datos personales del paciente.

**Elementos:**
- Campos: DNI, Nombres, Apellidos, Fecha de Nacimiento, Género, Dirección, Email, Teléfono
- Sección de credenciales: Usuario, Contraseña, Confirmar Contraseña
- Checkbox: Aceptar términos y condiciones
- Botones: Registrarse, Cancelar

---

### P02: Registro de Médico
**Ubicación:** [prototipos/P02-registro-medico.png](../prototipos/P02-registro-medico.png)

**Descripción:** Formulario de registro con datos profesionales del médico.

**Elementos:**
- Datos personales: DNI, Nombres, Apellidos, Email, Teléfono
- Datos profesionales: Número de Colegiatura, Especialidades (multiselect)
- Sección de credenciales (si aplica)
- Botones: Registrar, Cancelar

---

### P03: Gestión de Agenda de Horarios
**Ubicación:** [prototipos/P03-agenda-horarios.png](../prototipos/P03-agenda-horarios.png)

**Descripción:** Interfaz para que el médico configure sus horarios de atención.

**Elementos:**
- Tabla con horarios existentes: Día, Hora Inicio, Hora Fin, Consultorio, Acciones
- Botón: Agregar Nuevo Horario
- Vista de calendario semanal
- Formulario modal para agregar/editar horario

---

### P04: Reserva de Cita
**Ubicación:** [prototipos/P04-reserva-cita.png](../prototipos/P04-reserva-cita.png)

**Descripción:** Interfaz para que el paciente busque y reserve una cita.

**Elementos:**
- Paso 1: Seleccionar Especialidad
- Paso 2: Seleccionar Médico
- Paso 3: Seleccionar Fecha (calendario)
- Paso 4: Seleccionar Hora (bloques de 30 min)
- Paso 5: Ingresar Motivo de Consulta
- Resumen de la cita
- Botones: Confirmar Reserva, Atrás, Cancelar

---

### P05: Mis Citas (Paciente)
**Ubicación:** [prototipos/P05-mis-citas-paciente.png](../prototipos/P05-mis-citas-paciente.png)

**Descripción:** Lista de citas del paciente con opciones de cancelación.

**Elementos:**
- Pestañas: Próximas Citas, Historial
- Tarjetas de cita con: Fecha, Hora, Médico, Especialidad, Estado
- Botón: Cancelar Cita (solo para citas futuras)
- Botón: Ver Detalles

---

### P06: Panel de Control Administrador
**Ubicación:** [prototipos/P06-panel-admin.png](../prototipos/P06-panel-admin.png)

**Descripción:** Dashboard con métricas y accesos a gestión.

**Elementos:**
- Tarjetas de métricas: Total Pacientes, Total Médicos, Citas del Día
- Gráfico de citas por semana
- Gráfico de distribución por especialidad
- Menú lateral: Gestionar Pacientes, Gestionar Médicos, Gestionar Catálogos, Reportes

---

### P07: Notificaciones
**Ubicación:** [prototipos/P07-notificaciones.png](../prototipos/P07-notificaciones.png)

**Descripción:** Plantillas de correos electrónicos.

**Elementos:**
- Plantilla de confirmación de cita
- Plantilla de cancelación
- Plantilla de recordatorio

---

## 3.7. Matriz de Trazabilidad: Casos de Uso vs Requerimientos

| Caso de Uso | Requerimientos Funcionales | Pantallas | Frecuencia |
|-------------|---------------------------|-----------|------------|
| CU01 | RF01, RF20 | P01 | Media |
| CU02 | RF02 | P02 | Baja |
| CU03 | RF03, RF21 | P03 | Media |
| CU04 | RF04, RF05, RF06, RF07, RF23 | P04 | Alta |
| CU05 | RF08 | P05 | Media |
| CU06 | RF09, RF10, RF11 | P07 | Muy Alta |
| CU07 | RF12 | P03 | Alta |
| CU08 | RF13, RF14, RF15, RF16, RF17, RF24, RF25 | P06 | Media |
| CU09 | RF18, RF19 | Login | Muy Alta |

---

[⬅️ Anterior: Requerimientos](02-requerimientos.md) | [Volver al índice](README.md) | [Siguiente: Diseño Conceptual ➡️](04-diseño-conceptual.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div>