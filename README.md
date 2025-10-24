# 🏥 Sistema de Reserva de Consultas Médicas Externas

![Estado](https://img.shields.io/badge/Estado-En%20Desarrollo-yellow)
![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-green)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)
![HTML5](https://img.shields.io/badge/HTML5-CSS3-red)

## 📋 Descripción del Proyecto

Sistema web completo para la gestión de reservas de consultas médicas externas, desarrollado como proyecto académico para el curso de **Construcción de Software I** de la Universidad Nacional de Ingeniería (UNI).

El sistema permite a los pacientes agendar citas médicas, a los médicos gestionar sus horarios de atención y a los administradores supervisar el funcionamiento completo del sistema.

---

## 🎯 Objetivos

### Objetivo General
Diseñar y construir una aplicación web funcional que permita al usuario registrar, consultar y gestionar reservas de consultas médicas, aplicando principios de diseño modular, arquitectura cliente-servidor y conexión con base de datos relacional.

### Objetivos Específicos
- ✅ Analizar los requerimientos funcionales y no funcionales del sistema
- ✅ Modelar la base de datos relacional en PostgreSQL
- ✅ Implementar el backend con Spring Boot (Java)
- ✅ Desarrollar el frontend usando HTML5, CSS3 y JavaScript
- ✅ Realizar pruebas de funcionalidad y validación de datos
- ✅ Documentar y presentar el flujo de interacción de usuarios

---

## 🚀 Características Principales

### Para Pacientes
- 📝 Registro y autenticación de usuarios
- 🔍 Búsqueda de médicos por especialidad
- 📅 Visualización de horarios disponibles
- ✅ Reserva de citas médicas
- ❌ Cancelación de citas
- 📧 Notificaciones por correo electrónico
- 📊 Historial de citas

### Para Médicos
- 👨‍⚕️ Registro con especialidades
- 🗓️ Gestión de agenda y horarios de atención
- 📋 Visualización de citas programadas
- ✔️ Actualización de estado de citas
- 👥 Lista de pacientes atendidos

### Para Administradores
- 📊 Dashboard con estadísticas en tiempo real
- 👥 Gestión de usuarios (pacientes y médicos)
- 📈 Generación de reportes
- ⚙️ Configuración del sistema
- 🔔 Gestión de notificaciones

---

## 🛠️ Tecnologías Utilizadas

### Backend
- **Lenguaje:** Java 17
- **Framework:** Spring Boot 3.2
  - Spring Data JPA
  - Spring Security
  - Spring Validation
  - Spring Mail
- **Base de Datos:** PostgreSQL 15
- **Build Tool:** Maven
- **Otras librerías:**
  - Lombok
  - MapStruct (DTOs)
  - Swagger/OpenAPI (Documentación API)

### Frontend
- **HTML5:** Estructura
- **CSS3:** Estilos personalizados
- **JavaScript:** Lógica del cliente (Vanilla JS)
- **Bootstrap 5:** Framework CSS
- **Font Awesome:** Iconos

### Herramientas de Desarrollo
- **IDE:** IntelliJ IDEA / VS Code
- **Control de versiones:** Git & GitHub
- **Base de Datos:** pgAdmin 4
- **Servidor local:** XAMPP (PostgreSQL)
- **Testing:** JUnit 5, Mockito
- **Documentación:** Markdown

---

## 📁 Estructura del Proyecto

```
sistema-reserva-consultas-medicas/
│
├── docs/                    # 📚 Documentación completa del proyecto
│   ├── 01-introduccion.md
│   ├── 02-requerimientos.md
│   ├── 03-especificacion-requisitos.md
│   ├── 04-diseño-conceptual.md
│   ├── 05-diseño-logico.md
│   ├── diagramas/          # Diagramas UML
│   └── prototipos/         # Mockups de interfaces
│
├── database/               # 💾 Scripts SQL
│   ├── ddl/               # Creación de estructuras
│   ├── dml/               # Inserción de datos
│   └── dql/               # Consultas
│
├── backend/               # ☕ Código Spring Boot
│   └── src/
│       ├── main/java/
│       └── test/java/
│
└── frontend/              # 🎨 Código HTML/CSS/JS
    ├── pages/
    ├── css/
    └── js/
```

---

## 📊 Diagramas UML

El proyecto incluye los siguientes diagramas UML completos:

- 📌 **Diagrama de Casos de Uso:** Interacciones de actores con el sistema
- 🏗️ **Diagrama de Clases:** Estructura estática del sistema
- 🔄 **Diagrama de Secuencias:** Flujos de interacción
- 📈 **Diagrama de Actividades:** Procesos de negocio
- 🔀 **Diagrama de Estados:** Estados de las citas
- 🗄️ **Diagrama Entidad-Relación:** Modelo conceptual de datos
- 📊 **Diagrama Relacional:** Modelo lógico de base de datos

> 📂 Todos los diagramas están disponibles en: [`docs/diagramas/`](docs/diagramas/)

---

## 🗃️ Modelo de Base de Datos

### Entidades Principales
- `paciente` - Información de pacientes
- `medico` - Información de médicos
- `especialidad` - Especialidades médicas
- `consultorio` - Consultorios disponibles
- `horario_atencion` - Horarios de médicos
- `cita` - Reservas de citas
- `estado_cita` - Estados de las citas (Lookup)
- `notificacion` - Notificaciones del sistema
- `usuario` - Autenticación

### Características del Diseño
- ✅ Normalizado hasta 3FN
- ✅ Índices optimizados para consultas frecuentes
- ✅ Constraints de integridad referencial
- ✅ Triggers para validaciones
- ✅ Funciones almacenadas para lógica de negocio
- ✅ Vistas para reportes

> 📂 Scripts SQL disponibles en: [`database/`](database/)

---

## 🔧 Instalación y Configuración

### Prerrequisitos
- Java JDK 17 o superior
- PostgreSQL 15 o superior
- Maven 3.6+
- Git

### Paso 1: Clonar el repositorio
```bash
git clone https://github.com/TU-USUARIO/sistema-reserva-consultas-medicas.git
cd sistema-reserva-consultas-medicas
```

### Paso 2: Configurar Base de Datos
```bash
# Crear base de datos
psql -U postgres
CREATE DATABASE sistema_consultas_medicas;
\q

# Ejecutar scripts en orden
cd database/ddl
psql -U postgres -d sistema_consultas_medicas -f 01_create_database.sql
psql -U postgres -d sistema_consultas_medicas -f 02_create_schemas.sql
# ... continuar con todos los scripts
```

### Paso 3: Configurar Backend
```bash
cd backend

# Editar src/main/resources/application.properties
# Configurar credenciales de PostgreSQL

# Compilar y ejecutar
mvn clean install
mvn spring-boot:run
```

El backend estará disponible en: `http://localhost:8080`

### Paso 4: Configurar Frontend
```bash
cd frontend

# Opción 1: Abrir directamente index.html en el navegador

# Opción 2: Usar un servidor local
python -m http.server 8081
# o
npx live-server --port=8081
```

El frontend estará disponible en: `http://localhost:8081`

---

## 📖 Documentación

### Documentación Técnica Completa
Toda la documentación del proyecto está disponible en la carpeta [`docs/`](docs/):

1. [Introducción y Marco Teórico](docs/01-introduccion.md)
2. [Requerimientos Funcionales y No Funcionales](docs/02-requerimientos.md)
3. [Especificación de Requisitos y Casos de Uso](docs/03-especificacion-requisitos.md)
4. [Diseño Conceptual (Modelo ER)](docs/04-diseño-conceptual.md)
5. [Diseño Lógico (Modelo Relacional)](docs/05-diseño-logico.md)
6. [Implementación de Base de Datos](docs/06-implementacion-bd.md)
7. [Manual Técnico](docs/07-manual-tecnico.md)
8. [Manual de Usuario](docs/08-manual-usuario.md)

### API REST Endpoints

La documentación interactiva de la API está disponible con Swagger:
- **Swagger UI:** http://localhost:8080/swagger-ui.html
- **OpenAPI JSON:** http://localhost:8080/v3/api-docs

#### Principales Endpoints

**Pacientes**
```
GET    /api/pacientes          - Listar pacientes
POST   /api/pacientes          - Registrar paciente
GET    /api/pacientes/{id}     - Obtener paciente
PUT    /api/pacientes/{id}     - Actualizar paciente
DELETE /api/pacientes/{id}     - Eliminar paciente
```

**Médicos**
```
GET    /api/medicos                      - Listar médicos
POST   /api/medicos                      - Registrar médico
GET    /api/medicos/{id}                 - Obtener médico
GET    /api/medicos/especialidad/{id}   - Médicos por especialidad
```

**Citas**
```
POST   /api/citas                 - Registrar cita
GET    /api/citas/{id}            - Obtener cita
GET    /api/citas/paciente/{id}   - Citas de paciente
PUT    /api/citas/{id}/cancelar   - Cancelar cita
GET    /api/citas/fecha           - Citas por fecha
```

---

## 🧪 Testing

### Ejecutar Tests Unitarios
```bash
cd backend
mvn test
```

### Ejecutar Tests de Integración
```bash
mvn verify
```

### Cobertura de Código
```bash
mvn clean test jacoco:report
# Ver reporte en: target/site/jacoco/index.html
```

---

## 📸 Capturas de Pantalla

### Página Principal
![Home](docs/prototipos/home-preview.png)

### Registro de Cita
![Nueva Cita](docs/prototipos/nueva-cita-preview.png)

### Dashboard Administrador
![Dashboard](docs/prototipos/dashboard-preview.png)

> 📂 Más capturas en: [`docs/prototipos/`](docs/prototipos/)

---

## 👥 Autor

**Tu Nombre Completo**
- 👨‍🎓 Estudiante de Ingeniería de Software - UNI
- 📧 Email: tu.email@uni.edu.pe
- 💼 LinkedIn: [tu-perfil](https://linkedin.com/in/tu-perfil)
- 🐱 GitHub: [@tu-usuario](https://github.com/tu-usuario)

---

## 🎓 Información Académica

- **Universidad:** Universidad Nacional de Ingeniería (UNI)
- **Facultad:** Facultad de Ingeniería Industrial y de Sistemas (FIIS)
- **Escuela:** Ingeniería de Software
- **Curso:** Construcción de Software I
- **Ciclo:** 2025-1
- **Profesor:** [Nombre del Profesor]

---

## 📝 Requerimientos del Proyecto

Este proyecto fue desarrollado siguiendo los requerimientos de la **Segunda Práctica Calificada** que incluye:

### Caso 1: Reserva de Consultas Médicas Externas
- ✅ Registro de pacientes y médicos
- ✅ Agenda de horarios disponibles
- ✅ Reserva y cancelación de citas
- ✅ Notificación (correo o alerta en pantalla)
- ✅ Panel de control para el administrador

### Cumplimiento de Objetivos
- ✅ Análisis de requerimientos completo
- ✅ Modelado de base de datos en PostgreSQL
- ✅ Backend implementado con Spring Boot
- ✅ Frontend desarrollado con HTML5, CSS3, JavaScript
- ✅ Pruebas de funcionalidad realizadas
- ✅ Documentación completa del proyecto

---

## 📄 Licencia

Este proyecto es de uso **exclusivamente académico** y fue desarrollado como parte de un curso universitario.

---

## 🙏 Agradecimientos

- A la **Universidad Nacional de Ingeniería** por la formación académica
- Al profesor del curso por la guía y asesoría
- A mis compañeros de clase por el apoyo mutuo

---

## 📞 Contacto y Soporte

Si tienes preguntas o sugerencias sobre este proyecto:

- 📧 **Email:** tu.email@uni.edu.pe
- 💬 **Issues:** [Crear un issue](https://github.com/tu-usuario/sistema-reserva-consultas-medicas/issues)
- 📖 **Wiki:** [Documentación adicional](https://github.com/tu-usuario/sistema-reserva-consultas-medicas/wiki)

---

## ⭐ Si te fue útil

Si este proyecto te sirvió como referencia o te fue útil, no olvides darle una ⭐ estrella al repositorio.

---

<div align="center">
  <strong>Desarrollado con ❤️ por [Tu Nombre]</strong>
  <br>
  Universidad Nacional de Ingeniería - 2025
</div>