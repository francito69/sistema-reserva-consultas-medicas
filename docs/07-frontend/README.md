# Actividad 3: Diseño del Frontend
## Interfaz de Usuario del Sistema de Reserva de Consultas Médicas

---

## Descripción

Este módulo contiene el diseño e implementación completa del frontend del sistema, desarrollado con **HTML5, CSS3 y JavaScript Vanilla**. La interfaz proporciona una experiencia de usuario intuitiva y responsiva para los tres tipos de usuarios del sistema: Pacientes, Médicos y Administradores.

---

## Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| HTML5 | - | Estructura de las páginas |
| CSS3 | - | Diseño y estilos |
| JavaScript | ES6+ | Lógica del cliente |
| Fetch API | - | Comunicación con backend |
| LocalStorage | - | Almacenamiento de sesión |

---

## Estructura de Carpetas

```
07-frontend/
├── pages/
│   ├── admin/              # Páginas del administrador
│   │   ├── dashboard.html
│   │   ├── especialidades.html
│   │   ├── medicos.html
│   │   ├── pacientes.html
│   │   ├── consultorios.html
│   │   ├── citas.html
│   │   └── reportes.html
│   │
│   ├── auth/               # Autenticación
│   │   ├── login.html
│   │   └── registro.html
│   │
│   ├── medico/             # Páginas del médico
│   │   ├── dashboard.html
│   │   ├── citas.html
│   │   └── horarios.html
│   │
│   └── paciente/           # Páginas del paciente
│       ├── dashboard.html
│       ├── reservar.html
│       └── mis-citas.html
│
├── css/
│   ├── design-system.css   # Sistema de diseño (variables, colores)
│   ├── components.css      # Componentes reutilizables
│   └── layouts.css         # Layouts y estructuras
│
└── js/
    ├── main.js             # Configuración general
    ├── auth/
    │   ├── login.js
    │   └── registro.js
    └── utils/
        └── auth-guard.js   # Protección de rutas
```

---

## Características Principales

### 1. Sistema de Diseño

El frontend implementa un **Design System** consistente con:

- **Variables CSS** para colores, espaciados y tipografía
- **Componentes reutilizables** (botones, formularios, tarjetas)
- **Sistema de colores** basado en paleta primaria azul
- **Tipografía** con la fuente Inter
- **Espaciado** consistente usando sistema de 8px

```css
:root {
    --primary-500: #3B82F6;
    --success-500: #10B981;
    --error-500: #EF4444;
    --space-1: 0.25rem;
    --space-2: 0.5rem;
    /* ... más variables */
}
```

### 2. Autenticación y Seguridad

**Login (`pages/auth/login.html`)**
- Formulario de inicio de sesión
- Validación en tiempo real
- Almacenamiento seguro de tokens JWT
- Redirección según rol de usuario

**Registro (`pages/auth/registro.html`)**
- Registro de nuevos pacientes
- Validación de campos (DNI, email, teléfono)
- Verificación de disponibilidad de username
- Creación automática de sesión tras registro

**Auth Guard (`js/utils/auth-guard.js`)**
- Protección de rutas por rol
- Verificación de tokens
- Funciones globales: `getToken()`, `getCurrentUser()`, `logout()`

### 3. Panel de Administrador

**Dashboard (`pages/admin/dashboard.html`)**
- Estadísticas generales del sistema
- Gráficos de actividad
- Accesos rápidos a módulos

**Gestión de Especialidades (`pages/admin/especialidades.html`)**
- Listar especialidades médicas
- Crear, editar y eliminar especialidades
- Búsqueda y filtrado

**Gestión de Médicos (`pages/admin/medicos.html`)**
- Registro de médicos con credenciales
- Asignación de especialidades
- Gestión de números de colegiatura
- Activación/desactivación de médicos

**Gestión de Pacientes (`pages/admin/pacientes.html`)**
- Visualización de pacientes registrados
- Búsqueda por DNI, nombre o email
- Historial de citas

**Gestión de Citas (`pages/admin/citas.html`)**
- Ver todas las citas del sistema
- Filtrar por estado, médico o especialidad
- Cambiar estado de citas

### 4. Panel de Médico

**Dashboard (`pages/medico/dashboard.html`)**
- Citas del día
- Próximas consultas
- Estadísticas personales

**Mis Citas (`pages/medico/citas.html`)**
- Listar citas asignadas
- Marcar citas como atendidas
- Añadir observaciones

**Horarios (`pages/medico/horarios.html`)**
- Configurar horarios de atención
- Definir días y horas disponibles
- Gestionar consultorios asignados

### 5. Panel de Paciente

**Dashboard (`pages/paciente/dashboard.html`)**
- Próximas citas
- Historial de consultas
- Accesos rápidos

**Reservar Cita (`pages/paciente/reservar.html`)**
- Seleccionar especialidad
- Elegir médico
- Seleccionar fecha y hora disponible
- Confirmar reserva

**Mis Citas (`pages/paciente/mis-citas.html`)**
- Ver citas agendadas
- Cancelar citas
- Descargar comprobantes

---

## Componentes Principales

### 1. Modales

Ventanas emergentes para formularios:

```javascript
function openModal() {
    document.getElementById('formModal').classList.add('active');
}

function closeModal() {
    document.getElementById('formModal').classList.remove('active');
}
```

### 2. Tablas Dinámicas

Renderizado de datos desde la API:

```javascript
function renderTable(data) {
    const html = data.map(item => `
        <tr>
            <td>${item.nombre}</td>
            <td>${item.email}</td>
            <td>
                <button onclick="edit(${item.id})">Editar</button>
                <button onclick="delete(${item.id})">Eliminar</button>
            </td>
        </tr>
    `).join('');

    container.innerHTML = html;
}
```

### 3. Validación de Formularios

Validación en tiempo real:

```javascript
function validateField(fieldName, value) {
    const patterns = {
        dni: /^\d{8}$/,
        telefono: /^9\d{8}$/,
        email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    };

    if (!patterns[fieldName].test(value)) {
        showError(fieldName, 'Formato inválido');
        return false;
    }

    clearError(fieldName);
    return true;
}
```

---

## Comunicación con Backend

Todas las peticiones utilizan **Fetch API** con tokens JWT:

```javascript
async function fetchData(endpoint, options = {}) {
    const token = getToken();

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
            ...options.headers
        }
    });

    if (!response.ok) {
        throw new Error('Error en la petición');
    }

    return response.json();
}
```

**Endpoints principales:**
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/register` - Registrar paciente
- `GET /api/medicos` - Listar médicos
- `POST /api/medicos` - Crear médico
- `GET /api/citas` - Listar citas
- `POST /api/citas` - Crear cita

---

## Flujos de Usuario

### Flujo de Registro y Login

```
1. Usuario accede a /pages/auth/registro.html
   ↓
2. Completa formulario de registro
   ↓
3. Sistema valida datos y envía POST /api/auth/register
   ↓
4. Backend crea usuario y devuelve JWT token
   ↓
5. Frontend guarda token en localStorage
   ↓
6. Redirección automática al dashboard según rol
```

### Flujo de Reserva de Cita (Paciente)

```
1. Paciente entra a /pages/paciente/reservar.html
   ↓
2. Selecciona especialidad
   ↓
3. Sistema carga médicos de esa especialidad
   ↓
4. Paciente selecciona médico
   ↓
5. Sistema carga horarios disponibles
   ↓
6. Paciente elige fecha y hora
   ↓
7. Confirma reserva → POST /api/citas
   ↓
8. Sistema muestra confirmación
```

### Flujo de Registro de Médico (Admin)

```
1. Admin entra a /pages/admin/medicos.html
   ↓
2. Click en "Nuevo Médico"
   ↓
3. Modal se abre con formulario
   ↓
4. Admin completa datos:
   - Código médico
   - Número de colegiatura
   - Nombres y apellidos
   - Especialidad
   - Teléfono y email
   - Usuario y contraseña
   ↓
5. Click en "Guardar" → POST /api/medicos
   ↓
6. Backend valida, crea médico y usuario
   ↓
7. Tabla se actualiza con nuevo médico
```

---

## Diseño Responsivo

El frontend es completamente responsivo con breakpoints:

```css
/* Desktop */
@media (min-width: 1024px) {
    .dashboard-grid {
        grid-template-columns: 250px 1fr;
    }
}

/* Tablet */
@media (max-width: 768px) {
    .dashboard-sidebar {
        display: none;
    }
    .form-row {
        grid-template-columns: 1fr;
    }
}

/* Mobile */
@media (max-width: 480px) {
    .table {
        font-size: 0.875rem;
    }
}
```

---

## Accesibilidad

- **Labels en formularios** para screen readers
- **Contraste de colores** según WCAG 2.1
- **Navegación por teclado** habilitada
- **Mensajes de error** claros y descriptivos
- **Focus visible** en elementos interactivos

---

## Optimizaciones

1. **Carga asíncrona** de datos con Fetch API
2. **LocalStorage** para cachear datos de sesión
3. **Validación del lado del cliente** para reducir peticiones
4. **Spinner de carga** durante peticiones
5. **Debounce** en búsquedas en tiempo real

---

## Capturas de Pantalla

### Login
![Login](../09-pruebas/capturas/login.png)

### Dashboard Admin
![Dashboard Admin](../09-pruebas/capturas/admin-dashboard.png)

### Registro de Médico
![Registro Médico](../09-pruebas/capturas/registro-medico.png)

### Reserva de Cita
![Reserva Cita](../09-pruebas/capturas/reserva-cita.png)

---

## Instrucciones de Uso

### 1. Instalación

No requiere instalación. El frontend es servido por Spring Boot desde `src/main/resources/static/`.

### 2. Acceder al Sistema

```
http://localhost:8080/pages/auth/login.html
```

### 3. Usuarios de Prueba

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| admin | admin123 | ADMIN |
| medico1 | Med123456 | MEDICO |
| paciente1 | Pac123456 | PACIENTE |

---

## Problemas Conocidos y Soluciones

### Problema: Modal no se abre

**Causa:** Funciones `getCurrentUser()` o `getToken()` no definidas.

**Solución:** Verificar que `auth-guard.js` se carga antes que el script principal.

### Problema: Datos no aparecen en tabla

**Causa:** URLs de endpoints incorrectas o falta token.

**Solución:** Verificar que todos los `@RequestMapping` en controladores tengan el formato `/api/recurso`.

---

## Mejoras Futuras

- [ ] Implementar notificaciones en tiempo real
- [ ] Añadir dark mode
- [ ] Mejorar animaciones y transiciones
- [ ] Implementar PWA para uso offline
- [ ] Agregar gráficos con Chart.js

---

## Créditos

**Desarrollador:** Franz
**Universidad:** Universidad Nacional de Ingeniería (UNI)
**Curso:** Desarrollo de Aplicaciones Web
**Fecha:** 2025

---

## Enlaces

- [Volver a Actividades](../README.md)
- [Backend →](../08-backend/README.md)
- [Pruebas →](../09-pruebas/README.md)
