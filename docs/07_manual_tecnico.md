# 7. Manual Técnico

## Sistema de Reserva de Consultas Médicas Externas

---

## 7.1. Introducción

Este manual técnico está dirigido a desarrolladores, administradores de sistemas y personal técnico responsable de la instalación, configuración, mantenimiento y evolución del **Sistema de Reserva de Consultas Médicas Externas**.

### 7.1.1. Audiencia

- **Desarrolladores:** Programadores que trabajarán en el código fuente
- **Administradores de BD:** Responsables de la base de datos PostgreSQL
- **DevOps:** Encargados del despliegue y operaciones
- **Soporte Técnico:** Personal de soporte de primer y segundo nivel

### 7.1.2. Alcance del Manual

Este manual cubre:
- Arquitectura del sistema
- Tecnologías utilizadas
- Guía de instalación y configuración
- Estructura del código fuente
- API REST Endpoints
- Procedimientos de mantenimiento
- Solución de problemas comunes

---

## 7.2. Arquitectura del Sistema

### 7.2.1. Arquitectura General

El sistema sigue una **arquitectura en tres capas**:

```
┌─────────────────────────────────────────────────────┐
│                CAPA DE PRESENTACIÓN                 │
│              (Frontend - HTML/CSS/JS)               │
│  - Interfaz de usuario                              │
│  - Validación del lado del cliente                  │
│  - Llamadas AJAX a la API REST                      │
└────────────────────┬────────────────────────────────┘
                     │ HTTP/HTTPS
                     │ JSON
┌────────────────────▼────────────────────────────────┐
│                 CAPA DE APLICACIÓN                  │
│              (Backend - Spring Boot)                │
│                                                      │
│  ┌─────────────────────────────────────────────┐   │
│  │         Controladores (Controllers)         │   │
│  │  - Reciben peticiones HTTP                  │   │
│  │  - Retornan respuestas JSON                 │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                               │
│  ┌──────────────────▼──────────────────────────┐   │
│  │           Servicios (Services)              │   │
│  │  - Lógica de negocio                        │   │
│  │  - Validaciones complejas                   │   │
│  │  - Orquestación de operaciones              │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                               │
│  ┌──────────────────▼──────────────────────────┐   │
│  │       Repositorios (Repositories)           │   │
│  │  - Acceso a datos (Spring Data JPA)         │   │
│  │  - Queries personalizadas                   │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                               │
│  ┌──────────────────▼──────────────────────────┐   │
│  │         Entidades (Entities)                │   │
│  │  - Modelo de dominio                        │   │
│  │  - Mapeo objeto-relacional (JPA)            │   │
│  └──────────────────┬──────────────────────────┘   │
└────────────────────┬────────────────────────────────┘
                     │ JDBC
┌────────────────────▼────────────────────────────────┐
│                  CAPA DE DATOS                      │
│              (PostgreSQL Database)                  │
│  - Almacenamiento persistente                       │
│  - Triggers y funciones                             │
│  - Integridad referencial                           │
└─────────────────────────────────────────────────────┘
```

### 7.2.2. Patrón de Diseño MVC

El backend implementa el patrón **MVC (Modelo-Vista-Controlador)**:

| Componente | Responsabilidad | Ubicación |
|------------|----------------|-----------|
| **Modelo** | Entidades JPA, DTOs | `model/entity`, `model/dto` |
| **Vista** | Respuestas JSON (no HTML) | Implícito en respuestas REST |
| **Controlador** | Controladores REST | `controller/` |

### 7.2.3. Flujo de una Petición

```
1. Usuario → Frontend (JavaScript)
2. Frontend → HTTP Request → Backend (Controller)
3. Controller → Valida datos → Service
4. Service → Lógica de negocio → Repository
5. Repository → Query → Base de Datos
6. Base de Datos → Resultados → Repository
7. Repository → Entity → Service
8. Service → DTO → Controller
9. Controller → JSON Response → Frontend
10. Frontend → Actualiza UI → Usuario
```

---

## 7.3. Stack Tecnológico

### 7.3.1. Backend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Java** | 17 LTS | Lenguaje de programación |
| **Spring Boot** | 3.2.x | Framework principal |
| **Spring Data JPA** | 3.2.x | ORM y acceso a datos |
| **Spring Security** | 6.x | Autenticación y autorización |
| **Spring Validation** | 3.x | Validación de datos |
| **PostgreSQL Driver** | 42.x | Conector JDBC |
| **Lombok** | 1.18.x | Reducción de boilerplate |
| **MapStruct** | 1.5.x | Mapeo DTO ↔ Entity |
| **SpringDoc OpenAPI** | 2.x | Documentación API (Swagger) |
| **JUnit 5** | 5.10.x | Testing unitario |
| **Mockito** | 5.x | Mocking para tests |
| **Maven** | 3.9.x | Gestión de dependencias |

### 7.3.2. Frontend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **HTML5** | - | Estructura de páginas |
| **CSS3** | - | Estilos y diseño |
| **JavaScript** | ES6+ | Lógica del cliente |
| **Bootstrap** | 5.3.x | Framework CSS responsivo |
| **Font Awesome** | 6.x | Iconos |
| **Fetch API** | Nativo | Peticiones HTTP asíncronas |

### 7.3.3. Base de Datos

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **PostgreSQL** | 15.x | Sistema de gestión de BD |
| **pgAdmin 4** | 8.x | Administración gráfica |

---

## 7.4. Requisitos del Sistema

### 7.4.1. Hardware Mínimo

**Servidor/Equipo de Desarrollo:**
- **Procesador:** Intel Core i5 o equivalente (2.5 GHz o superior)
- **RAM:** 8 GB mínimo (16 GB recomendado)
- **Disco Duro:** 20 GB de espacio libre
- **Red:** Conexión a internet estable

### 7.4.2. Software Requerido

**Sistema Operativo:**
- Windows 10/11
- Linux (Ubuntu 20.04+, Debian 11+)
- macOS 11+

**Software Base:**
- **JDK 17** o superior
- **PostgreSQL 15** o superior
- **Maven 3.9** o superior
- **Git 2.x**

**Herramientas de Desarrollo (Opcionales):**
- IntelliJ IDEA Community/Ultimate
- Visual Studio Code
- Postman (para testing de API)

---

## 7.5. Instalación y Configuración

### 7.5.1. Instalación de PostgreSQL

**En Windows:**
1. Descargar instalador desde: https://www.postgresql.org/download/windows/
2. Ejecutar instalador y seguir wizard
3. Configurar:
   - Puerto: 5432 (default)
   - Usuario: postgres
   - Contraseña: [elegir una segura]
4. Verificar instalación:
   ```bash
   psql --version
   ```

**En Linux (Ubuntu/Debian):**
```bash
# Actualizar repositorios
sudo apt update

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib

# Verificar servicio
sudo systemctl status postgresql

# Configurar contraseña del usuario postgres
sudo -u postgres psql
postgres=# \password postgres
postgres=# \q
```

### 7.5.2. Instalación de Java JDK 17

**En Windows:**
1. Descargar desde: https://adoptium.net/
2. Ejecutar instalador
3. Configurar variable de entorno `JAVA_HOME`
4. Verificar:
   ```bash
   java --version
   javac --version
   ```

**En Linux:**
```bash
sudo apt install openjdk-17-jdk

java --version
```

### 7.5.3. Instalación de Maven

**En Windows:**
1. Descargar desde: https://maven.apache.org/download.cgi
2. Extraer en `C:\Program Files\Maven`
3. Configurar variable `M2_HOME` y agregar `bin` a PATH
4. Verificar:
   ```bash
   mvn --version
   ```

**En Linux:**
```bash
sudo apt install maven

mvn --version
```

### 7.5.4. Clonar el Repositorio

```bash
# Clonar repositorio
git clone https://github.com/francito69/sistema-reserva-consultas-medicas.git

# Entrar al directorio
cd sistema-reserva-consultas-medicas
```

### 7.5.5. Configurar Base de Datos

**Paso 1: Crear la base de datos**
```bash
# Conectarse a PostgreSQL
psql -U postgres

# Ejecutar script de creación
\i database/ddl/01_create_database.sql

# Conectarse a la nueva BD
\c sistema_consultas_medicas

# Ejecutar resto de scripts DDL
\i database/ddl/02_create_schemas.sql
\i database/ddl/03_create_lookup_tables.sql
\i database/ddl/04_create_main_tables.sql
\i database/ddl/05_create_associative_tables.sql
\i database/ddl/06_create_views.sql
\i database/ddl/07_create_functions.sql
\i database/ddl/08_create_triggers.sql

# Insertar datos de catálogo
\i database/dml/09_insert_lookup_data.sql

# Salir
\q
```

**Alternativa: Usar script automático**
```bash
cd database
chmod +x setup_db.sh
./setup_db.sh
```

### 7.5.6. Configurar Backend

**Paso 1: Editar application.properties**

Archivo: `backend/src/main/resources/application.properties`

```properties
# ========================================
# CONFIGURACIÓN DE BASE DE DATOS
# ========================================
spring.datasource.url=jdbc:postgresql://localhost:5432/sistema_consultas_medicas
spring.datasource.username=postgres
spring.datasource.password=TU_CONTRASEÑA_AQUI
spring.datasource.driver-class-name=org.postgresql.Driver

# ========================================
# CONFIGURACIÓN DE JPA/HIBERNATE
# ========================================
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# ========================================
# CONFIGURACIÓN DEL SERVIDOR
# ========================================
server.port=8080
server.servlet.context-path=/api

# ========================================
# CONFIGURACIÓN DE CORREO (Gmail SMTP)
# ========================================
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=tu.email@gmail.com
spring.mail.password=tu_contraseña_aplicacion
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# ========================================
# CONFIGURACIÓN DE SEGURIDAD
# ========================================
jwt.secret=MI_CLAVE_SECRETA_MUY_LARGA_Y_SEGURA
jwt.expiration=86400000

# ========================================
# CONFIGURACIÓN DE LOGS
# ========================================
logging.level.root=INFO
logging.level.com.hospital.consultas=DEBUG
logging.file.name=logs/application.log
```

**Paso 2: Compilar el proyecto**
```bash
cd backend

# Limpiar y compilar
mvn clean install

# O sin ejecutar tests
mvn clean install -DskipTests
```

**Paso 3: Ejecutar el backend**
```bash
# Opción 1: Con Maven
mvn spring-boot:run

# Opción 2: Ejecutar JAR
java -jar target/consultas-0.0.1-SNAPSHOT.jar
```

**Verificar que el servidor está corriendo:**
- Abrir navegador en: http://localhost:8080/api
- Debe aparecer un mensaje o redirección

### 7.5.7. Configurar Frontend

**Paso 1: Editar configuración**

Archivo: `frontend/js/config.js`

```javascript
// Configuración de la API
const API_CONFIG = {
    BASE_URL: 'http://localhost:8080/api',
    TIMEOUT: 30000,  // 30 segundos
    HEADERS: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
};

// Endpoints de la API
const API_ENDPOINTS = {
    // Autenticación
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    
    // Pacientes
    PACIENTES: '/pacientes',
    PACIENTE_BY_ID: '/pacientes/:id',
    
    // Médicos
    MEDICOS: '/medicos',
    MEDICO_BY_ID: '/medicos/:id',
    MEDICOS_BY_ESPECIALIDAD: '/medicos/especialidad/:id',
    
    // Citas
    CITAS: '/citas',
    CITA_BY_ID: '/citas/:id',
    CITAS_BY_PACIENTE: '/citas/paciente/:id',
    CITAS_BY_MEDICO: '/citas/medico/:id',
    CANCELAR_CITA: '/citas/:id/cancelar',
    
    // Especialidades
    ESPECIALIDADES: '/especialidades',
    
    // Consultorios
    CONSULTORIOS: '/consultorios'
};
```

**Paso 2: Servir el frontend**

**Opción 1: Servidor HTTP simple (Python)**
```bash
cd frontend
python -m http.server 8081
```

**Opción 2: Live Server (VS Code)**
1. Instalar extensión "Live Server" en VS Code
2. Click derecho en `index.html` → "Open with Live Server"

**Opción 3: Navegador directamente**
- Abrir `frontend/index.html` directamente en el navegador

**Verificar funcionamiento:**
- Abrir: http://localhost:8081
- Debe cargar la página principal

---

## 7.6. Estructura del Proyecto

### 7.6.1. Estructura del Backend

```
backend/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── hospital/
│   │   │           └── consultas/
│   │   │               ├── ConsultasApplication.java    # Clase principal
│   │   │               │
│   │   │               ├── config/                      # Configuraciones
│   │   │               │   ├── SecurityConfig.java
│   │   │               │   ├── CorsConfig.java
│   │   │               │   └── SwaggerConfig.java
│   │   │               │
│   │   │               ├── model/                       # Modelo de datos
│   │   │               │   ├── entity/                  # Entidades JPA
│   │   │               │   │   ├── Usuario.java
│   │   │               │   │   ├── Paciente.java
│   │   │               │   │   ├── Medico.java
│   │   │               │   │   ├── Especialidad.java
│   │   │               │   │   ├── Consultorio.java
│   │   │               │   │   ├── HorarioAtencion.java
│   │   │               │   │   ├── Cita.java
│   │   │               │   │   ├── EstadoCita.java
│   │   │               │   │   └── Notificacion.java
│   │   │               │   │
│   │   │               │   └── dto/                     # Data Transfer Objects
│   │   │               │       ├── PacienteDTO.java
│   │   │               │       ├── MedicoDTO.java
│   │   │               │       ├── CitaDTO.java
│   │   │               │       └── ResponseDTO.java
│   │   │               │
│   │   │               ├── repository/                  # Repositorios (Data Access)
│   │   │               │   ├── UsuarioRepository.java
│   │   │               │   ├── PacienteRepository.java
│   │   │               │   ├── MedicoRepository.java
│   │   │               │   ├── CitaRepository.java
│   │   │               │   └── EspecialidadRepository.java
│   │   │               │
│   │   │               ├── service/                     # Servicios (Lógica de negocio)
│   │   │               │   ├── UsuarioService.java
│   │   │               │   ├── PacienteService.java
│   │   │               │   ├── MedicoService.java
│   │   │               │   ├── CitaService.java
│   │   │               │   └── NotificacionService.java
│   │   │               │
│   │   │               ├── controller/                  # Controladores REST
│   │   │               │   ├── AuthController.java
│   │   │               │   ├── PacienteController.java
│   │   │               │   ├── MedicoController.java
│   │   │               │   ├── CitaController.java
│   │   │               │   └── AdminController.java
│   │   │               │
│   │   │               ├── exception/                   # Manejo de excepciones
│   │   │               │   ├── GlobalExceptionHandler.java
│   │   │               │   ├── ResourceNotFoundException.java
│   │   │               │   └── ValidationException.java
│   │   │               │
│   │   │               ├── security/                    # Seguridad
│   │   │               │   ├── JwtTokenProvider.java
│   │   │               │   ├── JwtAuthenticationFilter.java
│   │   │               │   └── UserDetailsServiceImpl.java
│   │   │               │
│   │   │               └── util/                        # Utilidades
│   │   │                   ├── DateUtils.java
│   │   │                   └── ValidationUtils.java
│   │   │
│   │   └── resources/
│   │       ├── application.properties                   # Configuración principal
│   │       ├── application-dev.properties               # Perfil desarrollo
│   │       ├── application-prod.properties              # Perfil producción
│   │       └── static/                                  # Recursos estáticos
│   │
│   └── test/
│       └── java/
│           └── com/
│               └── hospital/
│                   └── consultas/
│                       ├── service/                     # Tests de servicios
│                       └── controller/                  # Tests de controladores
│
├── pom.xml                                              # Dependencias Maven
├── .gitignore
└── README.md
```

### 7.6.2. Estructura del Frontend

```
frontend/
├── index.html                       # Página principal
├── login.html                       # Página de login
│
├── css/
│   ├── styles.css                   # Estilos personalizados
│   ├── bootstrap.min.css            # Bootstrap 5
│   └── fontawesome.min.css          # Font Awesome
│
├── js/
│   ├── main.js                      # Script principal
│   ├── config.js                    # Configuración de API
│   │
│   ├── api/                         # Módulos de API
│   │   ├── authAPI.js
│   │   ├── pacienteAPI.js
│   │   ├── medicoAPI.js
│   │   └── citaAPI.js
│   │
│   ├── components/                  # Componentes reutilizables
│   │   ├── navbar.js
│   │   ├── modal.js
│   │   └── notification.js
│   │
│   └── pages/                       # Lógica por página
│       ├── pacientes.js
│       ├── medicos.js
│       ├── citas.js
│       └── dashboard.js
│
├── pages/
│   ├── paciente/
│   │   ├── registro.html
│   │   ├── perfil.html
│   │   └── mis-citas.html
│   │
│   ├── medico/
│   │   ├── registro.html
│   │   ├── agenda.html
│   │   └── pacientes.html
│   │
│   ├── admin/
│   │   ├── dashboard.html
│   │   ├── reportes.html
│   │   └── configuracion.html
│   │
│   └── citas/
│       ├── nueva.html
│       ├── lista.html
│       └── detalle.html
│
└── assets/
    ├── images/
    │   └── logo.png
    └── icons/
```

---

## 7.7. API REST Endpoints

### 7.7.1. Autenticación

#### POST /api/auth/login
**Descripción:** Autenticar usuario y obtener token JWT.

**Request Body:**
```json
{
    "username": "juan.perez",
    "password": "MiPassword123"
}
```

**Response (200 OK):**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tipo": "Bearer",
    "usuario": {
        "id": 1,
        "username": "juan.perez",
        "email": "juan@email.com",
        "rol": "PACIENTE"
    }
}
```

---

### 7.7.2. Pacientes

#### POST /api/pacientes
**Descripción:** Registrar nuevo paciente.

**Request Body:**
```json
{
    "dni": "12345678",
    "nombres": "Juan Carlos",
    "apellidoPaterno": "Pérez",
    "apellidoMaterno": "García",
    "fechaNacimiento": "1990-05-15",
    "genero": "M",
    "direccion": "Av. Principal 123",
    "email": "juan.perez@email.com",
    "telefonos": [
        {
            "numero": "987654321",
            "tipo": "MOVIL",
            "esPrincipal": true
        }
    ],
    "usuario": {
        "nombreUsuario": "juan.perez",
        "contraseña": "Password123"
    }
}
```

**Response (201 Created):**
```json
{
    "id": 1,
    "dni": "12345678",
    "nombreCompleto": "Juan Carlos Pérez García",
    "email": "juan.perez@email.com",
    "mensaje": "Paciente registrado exitosamente"
}
```

#### GET /api/pacientes/{id}
**Descripción:** Obtener datos de un paciente.

**Response (200 OK):**
```json
{
    "id": 1,
    "dni": "12345678",
    "nombres": "Juan Carlos",
    "apellidoPaterno": "Pérez",
    "apellidoMaterno": "García",
    "fechaNacimiento": "1990-05-15",
    "edad": 35,
    "genero": "M",
    "direccion": "Av. Principal 123",
    "email": "juan.perez@email.com",
    "telefonos": [
        {
            "numero": "987654321",
            "tipo": "MOVIL",
            "esPrincipal": true
        }
    ],
    "estado": "ACTIVO"
}
```

---

### 7.7.3. Médicos

#### GET /api/medicos/especialidad/{id}
**Descripción:** Listar médicos por especialidad.

**Response (200 OK):**
```json
[
    {
        "id": 1,
        "nombreCompleto": "Dr(a). María López Sánchez",
        "numeroColegiatura": "CMP-12345",
        "email": "maria.lopez@hospital.pe",
        "telefono": "987123456",
        "especialidades": ["Cardiología"]
    },
    {
        "id": 2,
        "nombreCompleto": "Dr(a). Pedro Ramírez Torres",
        "numeroColegiatura": "CMP-67890",
        "email": "pedro.ramirez@hospital.pe",
        "telefono": "987654321",
        "especialidades": ["Cardiología", "Medicina General"]
    }
]
```

---

### 7.7.4. Citas

#### POST /api/citas
**Descripción:** Registrar nueva cita.

**Request Body:**
```json
{
    "idPaciente": 1,
    "idMedico": 2,
    "idEspecialidad": 1,
    "idConsultorio": 3,
    "fechaCita": "2025-11-15",
    "horaInicio": "09:00",
    "horaFin": "09:30",
    "motivoConsulta": "Dolor en el pecho desde hace una semana"
}
```

**Response (201 Created):**
```json
{
    "id": 1,
    "codigoCita": "CITA-2025-0001",
    "fechaCita": "2025-11-15",
    "horaInicio": "09:00",
    "horaFin": "09:30",
    "paciente": "Juan Carlos Pérez García",
    "medico": "Dr(a). Pedro Ramírez Torres",
    "especialidad": "Cardiología",
    "consultorio": "CONS-201",
    "estado": "CONFIRMADA",
    "mensaje": "Cita registrada exitosamente"
}
```

#### GET /api/citas/paciente/{id}
**Descripción:** Obtener citas de un paciente.

**Response (200 OK):**
```json
[
    {
        "codigoCita": "CITA-2025-0001",
        "fechaCita": "2025-11-15",
        "horaInicio": "09:00",
        "medico": "Dr(a). Pedro Ramírez Torres",
        "especialidad": "Cardiología",
        "consultorio": "CONS-201",
        "estado": "CONFIRMADA",
        "puedeC ancelar": true
    }
]
```

---

## 7.8. Testing

### 7.8.1. Tests Unitarios

```bash
# Ejecutar todos los tests
mvn test

# Ejecutar tests de una clase específica
mvn test -Dtest=CitaServiceTest

# Ver reporte de cobertura
mvn clean test jacoco:report
```

---

[⬅️ Anterior: Implementación BD](06-implementacion-bd.md) | [Volver al índice](README.md) | [Siguiente: Manual de Usuario ➡️](08-manual-usuario.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div>