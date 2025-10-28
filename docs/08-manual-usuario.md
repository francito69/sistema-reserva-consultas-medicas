# 8. Manual de Usuario

## Sistema de Reserva de Consultas Médicas Externas

---

## 8.1. Introducción

Bienvenido al **Sistema de Reserva de Consultas Médicas Externas**. Este manual está diseñado para ayudarle a utilizar el sistema de manera efectiva, ya sea como paciente, médico o administrador.

### 8.1.1. ¿Qué es el Sistema?

Es una plataforma web que permite:
- **A los pacientes:** Agendar citas médicas de forma rápida y sencilla
- **A los médicos:** Gestionar su agenda y atender a sus pacientes
- **A los administradores:** Supervisar y administrar el funcionamiento del sistema

### 8.1.2. Beneficios del Sistema

✅ **Disponibilidad 24/7:** Agende citas en cualquier momento  
✅ **Sin colas:** Evite esperas innecesarias  
✅ **Confirmación inmediata:** Reciba confirmación por correo  
✅ **Recordatorios automáticos:** No olvide sus citas  
✅ **Historial completo:** Consulte sus citas pasadas  
✅ **Fácil cancelación:** Cancele con anticipación si es necesario

---

## 8.2. Requisitos para Usar el Sistema

### 8.2.1. Requisitos Técnicos

- **Dispositivo:** Computadora, tablet o smartphone
- **Navegador web actualizado:**
  - Google Chrome (recomendado)
  - Mozilla Firefox
  - Microsoft Edge
  - Safari
- **Conexión a internet:** Estable y funcional
- **Correo electrónico:** Activo y accesible

### 8.2.2. Información Necesaria

**Para Pacientes:**
- DNI (8 dígitos)
- Datos personales completos
- Correo electrónico válido
- Número telefónico

**Para Médicos:**
- DNI
- Número de colegiatura (CMP)
- Especialidades certificadas
- Datos de contacto

---

## 8.3. Acceso al Sistema

### 8.3.1. Ingresar al Sistema

1. Abra su navegador web
2. Ingrese la dirección: `http://sistema-consultas.hospital.pe`
3. Se mostrará la página principal

### 8.3.2. Registro de Nuevos Usuarios

**Si es la primera vez que usa el sistema:**

#### Para Pacientes:

1. Click en **"Registrarse"** en el menú principal
2. Seleccione **"Registro de Paciente"**
3. Complete el formulario con sus datos:
   - DNI (8 dígitos)
   - Nombres y apellidos
   - Fecha de nacimiento
   - Género
   - Dirección
   - Correo electrónico
   - Teléfono(s)
4. Cree sus credenciales:
   - Nombre de usuario
   - Contraseña (mínimo 8 caracteres)
   - Confirmar contraseña
5. Acepte los términos y condiciones
6. Click en **"Registrarse"**
7. Recibirá un correo de confirmación

**Consejos de Seguridad:**
- Use una contraseña segura (mayúsculas, minúsculas, números)
- No comparta su contraseña con nadie
- Guarde sus credenciales en un lugar seguro

### 8.3.3. Iniciar Sesión

1. Click en **"Iniciar Sesión"**
2. Ingrese su **usuario** o **correo electrónico**
3. Ingrese su **contraseña**
4. Click en **"Ingresar"**

**¿Olvidó su contraseña?**
1. Click en **"¿Olvidó su contraseña?"**
2. Ingrese su correo electrónico
3. Recibirá un enlace para restablecer su contraseña
4. Siga las instrucciones del correo

---

## 8.4. Guía para Pacientes

### 8.4.1. Panel Principal del Paciente

Después de iniciar sesión, verá:

```
┌─────────────────────────────────────────────────┐
│  🏥 Sistema de Consultas Médicas                │
│  👤 Bienvenido, Juan Pérez                      │
├─────────────────────────────────────────────────┤
│                                                 │
│  📅 Agendar Nueva Cita                         │
│  📋 Mis Citas                                   │
│  👤 Mi Perfil                                   │
│  🔔 Notificaciones (2)                         │
│  🚪 Cerrar Sesión                              │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 8.4.2. Agendar una Nueva Cita

#### Paso 1: Seleccionar Especialidad

1. Click en **"Agendar Nueva Cita"**
2. Seleccione la especialidad médica que necesita:
   - Cardiología
   - Pediatría
   - Dermatología
   - Traumatología
   - Medicina General
   - Ginecología
   - Oftalmología
   - Neurología
   - Psiquiatría
   - Nutrición
3. Click en **"Buscar Médicos"**

#### Paso 2: Seleccionar Médico

El sistema mostrará los médicos disponibles con esa especialidad:

```
┌─────────────────────────────────────────────────┐
│ Dr(a). María López Sánchez                      │
│ 🏥 Especialidad: Cardiología                    │
│ 📋 CMP: CMP-12345                               │
│ 📍 Consultorios: CONS-101, CONS-201            │
│ ⭐⭐⭐⭐⭐ (50 opiniones)                         │
│ [Seleccionar]                                   │
└─────────────────────────────────────────────────┘
```

1. Lea la información de cada médico
2. Click en **"Seleccionar"** en el médico deseado

#### Paso 3: Seleccionar Fecha

1. Se mostrará un calendario
2. Los días disponibles estarán en **verde**
3. Los días sin disponibilidad en **gris**
4. Click en la fecha deseada

**Restricciones:**
- Solo puede agendar citas futuras
- Máximo 60 días de anticipación
- Mínimo 2 horas de anticipación

#### Paso 4: Seleccionar Hora

El sistema mostrará los horarios disponibles del médico:

```
┌─────────────────────────────────────────────────┐
│ Horarios Disponibles - 15 de Noviembre 2025    │
├─────────────────────────────────────────────────┤
│ ⏰ 09:00 - 09:30  [CONS-201]  [Disponible]     │
│ ⏰ 09:30 - 10:00  [CONS-201]  [Disponible]     │
│ ⏰ 10:00 - 10:30  [CONS-201]  [Ocupado]        │
│ ⏰ 10:30 - 11:00  [CONS-201]  [Disponible]     │
│ ⏰ 11:00 - 11:30  [CONS-201]  [Disponible]     │
└─────────────────────────────────────────────────┘
```

1. Seleccione el horario que le conviene
2. Click en **"Continuar"**

#### Paso 5: Ingresar Motivo de Consulta

1. Escriba el motivo de su consulta (mínimo 10 caracteres)
   - Ejemplo: "Dolor en el pecho desde hace una semana, especialmente al hacer esfuerzo físico"
2. Sea específico pero conciso
3. Click en **"Continuar"**

#### Paso 6: Revisar y Confirmar

El sistema mostrará un resumen:

```
┌─────────────────────────────────────────────────┐
│ RESUMEN DE LA CITA                              │
├─────────────────────────────────────────────────┤
│ 👨‍⚕️ Médico: Dr(a). María López Sánchez         │
│ 🏥 Especialidad: Cardiología                    │
│ 📅 Fecha: Viernes, 15 de Noviembre 2025        │
│ 🕐 Hora: 09:00 - 09:30                         │
│ 🚪 Consultorio: CONS-201 (Piso 2)              │
│ 📝 Motivo: Dolor en el pecho...                │
└─────────────────────────────────────────────────┘

[Cancelar]  [Confirmar Reserva]
```

1. Revise cuidadosamente todos los datos
2. Si todo está correcto, click en **"Confirmar Reserva"**
3. Si desea cambiar algo, click en **"Cancelar"** y vuelva a empezar

#### Paso 7: Confirmación

Si la reserva fue exitosa, verá:

```
┌─────────────────────────────────────────────────┐
│ ✅ ¡CITA CONFIRMADA!                           │
├─────────────────────────────────────────────────┤
│ Su cita ha sido registrada exitosamente        │
│                                                 │
│ Código de Cita: CITA-2025-0001                 │
│                                                 │
│ 📧 Hemos enviado una confirmación a su correo  │
│ 🔔 Recibirá un recordatorio 24h antes          │
│                                                 │
│ Por favor, llegue 10 minutos antes de su cita  │
│                                                 │
│ [Ver Detalles]  [Mis Citas]  [Nueva Cita]    │
└─────────────────────────────────────────────────┘
```

**Importante:**
- Guarde el código de cita: **CITA-2025-0001**
- Revise su correo electrónico
- Agregue la cita a su calendario personal

### 8.4.3. Ver Mis Citas

1. En el menú principal, click en **"Mis Citas"**
2. Verá dos pestañas:
   - **Próximas Citas:** Citas futuras
   - **Historial:** Citas pasadas

**Vista de Próximas Citas:**

```
┌─────────────────────────────────────────────────┐
│ PRÓXIMAS CITAS                                  │
├─────────────────────────────────────────────────┤
│ 📅 Viernes, 15 de Noviembre 2025               │
│ 🕐 09:00 - 09:30                               │
│ 👨‍⚕️ Dr(a). María López Sánchez                 │
│ 🏥 Cardiología                                  │
│ 🚪 Consultorio CONS-201 (Piso 2)               │
│ 📋 Estado: CONFIRMADA ✅                        │
│                                                 │
│ [Ver Detalles]  [Cancelar Cita]               │
└─────────────────────────────────────────────────┘
```

**Para cada cita puede:**
- **Ver Detalles:** Información completa de la cita
- **Cancelar Cita:** Cancelar si es necesario (con anticipación)
- **Agregar a Calendario:** Descargar archivo .ics

### 8.4.4. Cancelar una Cita

**⚠️ IMPORTANTE:** Solo puede cancelar citas con al menos **2 horas de anticipación**.

**Pasos:**

1. Vaya a **"Mis Citas"**
2. Ubique la cita que desea cancelar
3. Click en **"Cancelar Cita"**
4. Aparecerá una ventana de confirmación:

```
┌─────────────────────────────────────────────────┐
│ ⚠️ CANCELAR CITA                               │
├─────────────────────────────────────────────────┤
│ ¿Está seguro que desea cancelar esta cita?     │
│                                                 │
│ 📅 Fecha: 15/11/2025 - 09:00                   │
│ 👨‍⚕️ Dr(a). María López Sánchez                 │
│                                                 │
│ Motivo de cancelación (obligatorio):           │
│ ┌─────────────────────────────────────────┐   │
│ │ Surgió un imprevisto familiar...        │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ ⚠️ Esta acción no se puede deshacer            │
│                                                 │
│ [No, Mantener Cita]  [Sí, Cancelar]          │
└─────────────────────────────────────────────────┘
```

5. Escriba el motivo de cancelación (mínimo 10 caracteres)
6. Click en **"Sí, Cancelar"**
7. Recibirá confirmación por correo

**Políticas de Cancelación:**
- ✅ Puede cancelar con 2+ horas de anticipación: **SIN PENALIZACIÓN**
- ⚠️ Menos de 2 horas: Debe contactar directamente con la institución
- ❌ Más de 3 cancelaciones al mes: El sistema puede limitar nuevas reservas

### 8.4.5. Actualizar Mi Perfil

1. Click en **"Mi Perfil"** en el menú
2. Podrá actualizar:
   - Dirección
   - Teléfonos (agregar o eliminar)
   - Correo electrónico
   - Contraseña
3. **NO puede cambiar:**
   - DNI
   - Nombres y apellidos
   - Fecha de nacimiento
4. Click en **"Guardar Cambios"**

**Para cambiar la contraseña:**
1. Ingrese su contraseña actual
2. Ingrese la nueva contraseña
3. Confirme la nueva contraseña
4. Click en **"Cambiar Contraseña"**

### 8.4.6. Notificaciones

El sistema le enviará correos electrónicos en los siguientes casos:

| Evento | Cuándo | Asunto del Correo |
|--------|--------|-------------------|
| Cita confirmada | Inmediatamente después de agendar | "Confirmación de Cita Médica" |
| Recordatorio | 24 horas antes de la cita | "Recordatorio: Cita Médica Mañana" |
| Cita cancelada | Cuando cancela una cita | "Cita Médica Cancelada" |
| Cambio de horario | Si el médico modifica su agenda | "Importante: Cambio en su Cita" |

**Consejos:**
- Revise su bandeja de entrada regularmente
- Agregue el correo del sistema a sus contactos
- Revise también la carpeta de spam

---

## 8.5. Guía para Médicos

### 8.5.1. Panel Principal del Médico

Después de iniciar sesión como médico:

```
┌─────────────────────────────────────────────────┐
│  🏥 Sistema de Consultas Médicas                │
│  👨‍⚕️ Dr(a). María López - Cardiología          │
├─────────────────────────────────────────────────┤
│                                                 │
│  📅 Mi Agenda (5 citas hoy)                    │
│  🗓️ Gestionar Horarios                         │
│  👥 Mis Pacientes                               │
│  👤 Mi Perfil                                   │
│  🚪 Cerrar Sesión                              │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 8.5.2. Ver Mi Agenda

1. Click en **"Mi Agenda"**
2. Verá las citas programadas del día:

```
┌─────────────────────────────────────────────────┐
│ MI AGENDA - Viernes, 15 de Noviembre 2025      │
├─────────────────────────────────────────────────┤
│ 🕐 09:00 - 09:30  [CONS-201]                   │
│   👤 Juan Pérez García                          │
│   📝 Motivo: Dolor en el pecho...              │
│   📋 Estado: CONFIRMADA                         │
│   [Ver Paciente]  [Atender]                    │
├─────────────────────────────────────────────────┤
│ 🕐 10:00 - 10:30  [CONS-201]                   │
│   👤 María Torres Sánchez                       │
│   📝 Motivo: Hipertensión arterial...          │
│   📋 Estado: CONFIRMADA                         │
│   [Ver Paciente]  [Atender]                    │
└─────────────────────────────────────────────────┘
```

**Opciones disponibles:**
- **Ver Paciente:** Información del paciente
- **Atender:** Marcar cita como atendida
- **Filtrar por fecha:** Ver agenda de otros días

### 8.5.3. Gestionar Horarios de Atención

#### Ver Horarios Actuales

1. Click en **"Gestionar Horarios"**
2. Verá sus horarios configurados:

```
┌─────────────────────────────────────────────────┐
│ MIS HORARIOS DE ATENCIÓN                        │
├─────────────────────────────────────────────────┤
│ 📅 LUNES                                        │
│   🕐 09:00 - 13:00                             │
│   🏥 Cardiología                                │
│   🚪 CONS-201 (Piso 2)                         │
│   [Editar]  [Eliminar]                         │
├─────────────────────────────────────────────────┤
│ 📅 MARTES                                       │
│   🕐 14:00 - 18:00                             │
│   🏥 Cardiología                                │
│   🚪 CONS-101 (Piso 1)                         │
│   [Editar]  [Eliminar]                         │
└─────────────────────────────────────────────────┘
```

#### Agregar Nuevo Horario

1. Click en **"Agregar Nuevo Horario"**
2. Complete el formulario:

```
┌─────────────────────────────────────────────────┐
│ NUEVO HORARIO DE ATENCIÓN                      │
├─────────────────────────────────────────────────┤
│ Día de la semana: [MIERCOLES ▼]               │
│                                                 │
│ Hora de inicio:   [09:00 ▼]                   │
│ Hora de fin:      [13:00 ▼]                   │
│                                                 │
│ Especialidad:     [Cardiología ▼]             │
│ Consultorio:      [CONS-201 ▼]                │
│                                                 │
│ Duración de cada cita: [30] minutos           │
│                                                 │
│ [Cancelar]  [Guardar Horario]                 │
└─────────────────────────────────────────────────┘
```

3. Seleccione día de la semana
4. Configure hora de inicio y fin
5. Seleccione especialidad
6. Seleccione consultorio
7. Click en **"Guardar Horario"**

**Validaciones del sistema:**
- No puede tener dos horarios simultáneos
- El consultorio debe estar disponible
- La especialidad debe ser una de las suyas

#### Modificar Horario Existente

1. Click en **"Editar"** en el horario deseado
2. Modifique los campos necesarios
3. Click en **"Actualizar"**

**⚠️ IMPORTANTE:** 
- Si hay citas programadas en ese horario, el sistema le avisará
- Los pacientes afectados recibirán una notificación

#### Eliminar Horario

1. Click en **"Eliminar"** en el horario deseado
2. Confirme la acción

**⚠️ CUIDADO:**
- Si hay citas futuras, debe confirmar que desea eliminarlas
- Los pacientes recibirán notificación de cancelación

### 8.5.4. Actualizar Estado de Citas

Después de atender a un paciente:

1. Vaya a **"Mi Agenda"**
2. Ubique la cita atendida
3. Click en **"Atender"**
4. Seleccione el estado:
   - **Atendida:** Paciente fue atendido
   - **No Presentado:** Paciente no asistió
5. Opcionalmente, agregue observaciones
6. Click en **"Guardar"**

```
┌─────────────────────────────────────────────────┐
│ ACTUALIZAR CITA                                 │
├─────────────────────────────────────────────────┤
│ Paciente: Juan Pérez García                    │
│ Fecha: 15/11/2025 - 09:00                      │
│                                                 │
│ Estado:                                         │
│ ⚪ Atendida                                     │
│ ⚪ No Presentado                                │
│                                                 │
│ Observaciones (opcional):                       │
│ ┌─────────────────────────────────────────┐   │
│ │                                         │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ [Cancelar]  [Guardar]                          │
└─────────────────────────────────────────────────┘
```

### 8.5.5. Ver Lista de Pacientes

1. Click en **"Mis Pacientes"**
2. Verá la lista de pacientes que ha atendido
3. Puede buscar por nombre o DNI
4. Click en un paciente para ver su historial de citas

---

## 8.6. Guía para Administradores

### 8.6.1. Panel de Control (Dashboard)

El administrador tiene acceso completo al sistema:

```
┌─────────────────────────────────────────────────┐
│  🏥 Panel de Administración                     │
│  👨‍💼 Admin: Carlos Ruiz                         │
├─────────────────────────────────────────────────┤
│                                                 │
│  📊 Dashboard                                   │
│  👥 Gestionar Pacientes                         │
│  👨‍⚕️ Gestionar Médicos                          │
│  🏥 Gestionar Especialidades                    │
│  🚪 Gestionar Consultorios                      │
│  📈 Reportes                                    │
│  ⚙️ Configuración                               │
│  🚪 Cerrar Sesión                              │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 8.6.2. Dashboard Principal

Muestra métricas en tiempo real:

```
┌─────────────────────────────────────────────────┐
│ MÉTRICAS DEL SISTEMA                            │
├─────────────────────────────────────────────────┤
│  👥 Total Pacientes: 1,250                     │
│  👨‍⚕️ Total Médicos: 45                          │
│  📅 Citas del Día: 120                         │
│    ✅ Confirmadas: 85                          │
│    ⏳ Pendientes: 15                           │
│    ✔️ Atendidas: 20                            │
│                                                 │
│  📊 Tasa de Cancelación: 8.5%                  │
│  📊 Tasa de No Presentación: 3.2%              │
├─────────────────────────────────────────────────┤
│ TOP 5 ESPECIALIDADES MÁS SOLICITADAS           │
│  1. Medicina General (28%)                     │
│  2. Cardiología (18%)                          │
│  3. Pediatría (15%)                            │
│  4. Dermatología (12%)                         │
│  5. Traumatología (10%)                        │
└─────────────────────────────────────────────────┘
```

### 8.6.3. Gestionar Especialidades

**Agregar Nueva Especialidad:**

1. Click en **"Gestionar Especialidades"**
2. Click en **"Nueva Especialidad"**
3. Complete:
   - Código (ej: ENDO-01)
   - Nombre (ej: Endocrinología)
   - Descripción
4. Click en **"Guardar"**

**Editar o Desactivar:**
- Click en **"Editar"** para modificar
- Click en **"Desactivar"** para inhabilitar temporalmente

### 8.6.4. Gestionar Consultorios

Similar a especialidades:
1. Click en **"Gestionar Consultorios"**
2. Puede agregar, editar o desactivar consultorios
3. Configure: código, nombre, piso, capacidad, equipamiento

### 8.6.5. Generar Reportes

1. Click en **"Reportes"**
2. Seleccione tipo de reporte:
   - Citas por especialidad
   - Citas por médico
   - Cancelaciones
   - No presentaciones
   - Pacientes frecuentes
3. Seleccione rango de fechas
4. Click en **"Generar"**
5. Opciones de exportación:
   - 📄 Descargar PDF
   - 📊 Descargar Excel
   - 🖨️ Imprimir

---

## 8.7. Preguntas Frecuentes (FAQ)

### 8.7.1. Para Pacientes

**P: ¿Puedo agendar una cita para otra persona?**  
R: No, cada paciente debe tener su propia cuenta y agendar sus propias citas.

**P: ¿Puedo cambiar la fecha/hora de mi cita?**  
R: Debe cancelar la cita actual y agendar una nueva con la fecha/hora deseada.

**P: ¿Qué pasa si llego tarde a mi cita?**  
R: Se le atenderá si el médico aún tiene disponibilidad. Si pasan más de 15 minutos, puede perder su turno.

**P: ¿Cuántas citas puedo tener al mismo tiempo?**  
R: Máximo 3 citas pendientes o confirmadas simultáneamente.

**P: No recibí el correo de confirmación, ¿qué hago?**  
R: Revise su carpeta de spam. Si no está ahí, contacte al soporte técnico.

**P: ¿El sistema funciona en mi celular?**  
R: Sí, el sistema es responsive y funciona en cualquier dispositivo con navegador web.

### 8.7.2. Para Médicos

**P: ¿Puedo atender en varios consultorios?**  
R: Sí, puede configurar diferentes horarios en diferentes consultorios.

**P: ¿Cómo cancelo todas las citas de un día si no puedo asistir?**  
R: Contacte al administrador para una cancelación masiva.

**P: ¿Los pacientes ven mis observaciones?**  
R: No, las observaciones son confidenciales y solo visibles para usted.

### 8.7.3. Para Todos los Usuarios

**P: ¿Es seguro el sistema?**  
R: Sí, todas las contraseñas están encriptadas y las comunicaciones son seguras (HTTPS).

**P: ¿Qué hago si olvidé mi contraseña?**  
R: Use la opción "¿Olvidó su contraseña?" en la página de login.

**P: ¿El sistema está disponible las 24 horas?**  
R: Sí, puede acceder en cualquier momento, aunque puede haber mantenimientos programados.

**P: ¿Cómo contacto con soporte técnico?**  
R: Email: soporte@hospital.pe | Teléfono: (01) 123-4567

---

## 8.8. Solución de Problemas Comunes

### 8.8.1. No puedo iniciar sesión

**Problema:** Dice "Usuario o contraseña incorrectos"

**Soluciones:**
1. Verifique que está escribiendo correctamente
2. Asegúrese de no tener CAPS LOCK activado
3. Use la opción "¿Olvidó su contraseña?"
4. Si el problema persiste, contacte soporte

### 8.8.2. No aparecen horarios disponibles

**Posibles causas:**
- El médico no ha configurado horarios
- Todos los horarios están ocupados
- Está intentando agendar con muy poca anticipación

**Solución:**
- Intente con otra fecha
- Seleccione otro médico
- Contacte con el hospital

### 8.8.3. Error al confirmar cita

**Mensaje:** "El horario ya no está disponible"

**Causa:** Otro paciente reservó el horario mientras usted completaba el formulario

**Solución:**
- Seleccione otro horario
- El sistema le mostrará horarios actualizados

### 8.8.4. No recibo correos del sistema

**Soluciones:**
1. Revise la carpeta de spam/correo no deseado
2. Agregue el correo del sistema a sus contactos
3. Verifique que su correo está correcto en su perfil
4. Contacte soporte para verificar configuración

---

## 8.9. Consejos y Mejores Prácticas

### 8.9.1. Para Pacientes

✅ **Agende con anticipación:** Reserve sus citas con al menos 3-5 días de anticipación  
✅ **Llegue temprano:** Llegue 10 minutos antes de su cita  
✅ **Revise sus correos:** Especialmente 24 horas antes de la cita  
✅ **Actualice sus datos:** Mantenga su perfil actualizado  
✅ **Cancele con tiempo:** Si no puede asistir, cancele con anticipación  
✅ **Guarde sus códigos:** Anote los códigos de sus citas  

### 8.9.2. Para Médicos

✅ **Configure horarios realistas:** No sobrecargue su agenda  
✅ **Actualice estados:** Marque las citas como atendidas el mismo día  
✅ **Revise su agenda:** Consulte su agenda diariamente  
✅ **Notifique cambios:** Si debe cancelar un día, hágalo con anticipación  

### 8.9.3. Para Todos

✅ **Use contraseñas seguras:** Combine letras, números y símbolos  
✅ **No comparta su cuenta:** Cada usuario debe tener su propia cuenta  
✅ **Cierre sesión:** Especialmente en computadoras compartidas  
✅ **Reporte problemas:** Ayude a mejorar el sistema reportando errores  

---

## 8.10. Glosario de Términos

| Término | Definición |
|---------|------------|
| **Cita** | Reserva de atención médica en fecha y hora específica |
| **Código de Cita** | Identificador único de la cita (ej: CITA-2025-0001) |
| **Consultorio** | Espacio físico donde se realiza la atención |
| **CMP** | Colegio Médico del Perú - Número de colegiatura |
| **Estado de Cita** | Situación actual (Pendiente, Confirmada, Atendida, etc.) |
| **Especialidad** | Rama de la medicina (Cardiología, Pediatría, etc.) |
| **Horario de Atención** | Periodo en que el médico atiende |
| **Token/Sesión** | Permiso de acceso temporal al sistema |

---

## 8.11. Contacto y Soporte

### 8.11.1. Canales de Soporte

📧 **Email:** soporte@hospital.pe  
📞 **Teléfono:** (01) 123-4567  
💬 **WhatsApp:** +51 987 654 321  
🌐 **Web:** www.hospital.pe/soporte

### 8.11.2. Horarios de Atención

**Soporte Técnico:**
- Lunes a Viernes: 8:00 AM - 8:00 PM
- Sábados: 9:00 AM - 1:00 PM
- Domingos y feriados: Cerrado

**Emergencias Críticas del Sistema:**
- 24/7 vía email: emergencias@hospital.pe

---

## 8.12. Política de Privacidad

Sus datos personales están protegidos según la **Ley N° 29733 - Ley de Protección de Datos Personales del Perú**.

**Sus derechos:**
- ✅ Acceder a sus datos
- ✅ Rectificar información incorrecta
- ✅ Cancelar su cuenta
- ✅ Oponerse al tratamiento de sus datos

Para ejercer estos derechos, contacte: privacidad@hospital.pe

---

[⬅️ Anterior: Manual Técnico](07-manual-tecnico.md) | [Volver al índice](README.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I<br><br>
  
  <p>Gracias por usar nuestro sistema</p>
  <p>Para más información visite: www.hospital.pe</p>
</div>