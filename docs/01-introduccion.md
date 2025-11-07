# 1. Introducción y Marco Teórico

## Sistema de Reserva de Consultas Médicas Externas

---

## 1.1. Descripción del Proyecto

El **Sistema de Reserva de Consultas Médicas Externas** es una aplicación web diseñada para facilitar y optimizar el proceso de agendamiento de citas médicas en instituciones de salud. Este sistema permite a los pacientes reservar consultas de manera autónoma, a los médicos gestionar su agenda de atención, y a los administradores supervisar el funcionamiento completo del servicio.

### Contexto

En el ámbito de la salud, la gestión eficiente de citas médicas es fundamental para proporcionar un servicio de calidad a los pacientes. Tradicionalmente, este proceso se realiza de forma presencial o telefónica, lo que genera:

- **Largas colas de espera** en ventanillas de atención
- **Pérdida de tiempo** tanto para pacientes como para personal administrativo
- **Errores en el registro** de información por transcripción manual
- **Dificultad para reprogramar** o cancelar citas
- **Falta de visibilidad** de horarios disponibles
- **Sobrecarga de trabajo** del personal de recepción
- **Ausencias de pacientes** por falta de recordatorios

### Propuesta de Solución

El sistema propuesto digitaliza completamente el proceso de reserva de consultas médicas, ofreciendo:

- **Acceso 24/7** para agendar citas desde cualquier dispositivo
- **Visualización en tiempo real** de horarios disponibles
- **Notificaciones automáticas** por correo electrónico
- **Gestión centralizada** de información de pacientes y médicos
- **Reducción de no-asistencias** mediante recordatorios
- **Reportes y estadísticas** para la toma de decisiones
- **Interfaz intuitiva** y fácil de usar

### Alcance del Proyecto ----me quede aqui

El sistema abarca los siguientes módulos principales:

1. **Gestión de Pacientes**
   - Registro y autenticación de usuarios
   - Actualización de datos personales
   - Historial de citas médicas

2. **Gestión de Médicos**
   - Registro con especialidades médicas
   - Configuración de horarios de atención
   - Visualización de agenda diaria/semanal
   - Gestión de consultorios asignados

3. **Gestión de Citas**
   - Búsqueda de médicos por especialidad
   - Reserva de citas con validación de disponibilidad
   - Cancelación de citas
   - Actualización de estados (Pendiente, Confirmada, Atendida, Cancelada)

4. **Sistema de Notificaciones**
   - Envío de correos electrónicos de confirmación
   - Recordatorios automáticos de citas próximas
   - Alertas de cancelación

5. **Panel Administrativo**
   - Dashboard con métricas del sistema
   - Gestión de especialidades y consultorios
   - Generación de reportes estadísticos
   - Administración de usuarios

### Limitaciones

El sistema **NO incluye** en esta versión:

- ❌ Historia clínica electrónica
- ❌ Integración con sistemas de facturación
- ❌ Telemedicina o consultas virtuales
- ❌ Gestión de inventario de medicamentos
- ❌ Gestión de exámenes de laboratorio
- ❌ Sistema de pagos en línea

Estas funcionalidades quedan como trabajo futuro para versiones posteriores del sistema.

---

## 1.2. Objetivos

### 1.2.1. Objetivo General

Diseñar y construir una aplicación web funcional que permita al usuario registrar, consultar y gestionar reservas de consultas médicas externas, aplicando principios de diseño modular, arquitectura cliente-servidor y conexión con base de datos relacional.

### 1.2.2. Objetivos Específicos

1. **Análisis del Sistema**
   - Identificar y documentar los requerimientos funcionales y no funcionales del sistema
   - Definir los actores y casos de uso principales
   - Establecer las reglas de negocio del dominio médico

2. **Diseño de Base de Datos**
   - Modelar la base de datos relacional siguiendo el paradigma Entidad-Relación
   - Diseñar el modelo lógico relacional aplicando normalización hasta 3FN
   - Implementar el esquema de base de datos en PostgreSQL con constraints e índices

3. **Implementación del Backend**
   - Desarrollar una API REST robusta utilizando Spring Boot (Java)
   - Implementar la capa de persistencia con Spring Data JPA
   - Aplicar el patrón de arquitectura en capas (Controller, Service, Repository)
   - Gestionar la seguridad y autenticación de usuarios

4. **Desarrollo del Frontend**
   - Construir interfaces de usuario responsivas usando HTML5, CSS3 y JavaScript
   - Implementar la comunicación asíncrona con el backend mediante fetch API
   - Diseñar una experiencia de usuario intuitiva y accesible

5. **Validación y Pruebas**
   - Realizar pruebas de funcionalidad de todos los casos de uso
   - Validar la integridad de los datos en la base de datos
   - Ejecutar pruebas unitarias y de integración en el backend

6. **Documentación**
   - Documentar el análisis, diseño e implementación del sistema
   - Elaborar manuales de usuario y técnico
   - Presentar el flujo de interacción de los diferentes actores del sistema

---

## 1.3. Justificación

### 1.3.1. Justificación Académica

Este proyecto integra los conocimientos adquiridos en el curso de **Construcción de Software I**, aplicando:

- **Ingeniería de Requisitos:** Análisis y especificación de requerimientos funcionales y no funcionales
- **Modelado UML:** Diagramas de casos de uso, clases, secuencias, actividades y estados
- **Diseño de Bases de Datos:** Modelado ER, normalización, SQL y PostgreSQL
- **Programación Orientada a Objetos:** Aplicación de principios SOLID en Java
- **Arquitectura de Software:** Patrón MVC y arquitectura en capas
- **Desarrollo Web:** Tecnologías frontend y backend
- **Metodologías Ágiles:** Desarrollo iterativo e incremental

### 1.3.2. Justificación Práctica

La implementación de un sistema de reserva de consultas médicas aporta los siguientes beneficios:

**Para los Pacientes:**
- ✅ **Comodidad:** Agendar citas desde casa, sin necesidad de desplazarse
- ✅ **Disponibilidad:** Acceso al sistema las 24 horas del día, 7 días de la semana
- ✅ **Transparencia:** Visualización clara de horarios disponibles
- ✅ **Control:** Posibilidad de cancelar o reprogramar citas fácilmente
- ✅ **Recordatorios:** Notificaciones automáticas para evitar olvidos

**Para los Médicos:**
- ✅ **Organización:** Agenda digital ordenada y actualizada en tiempo real
- ✅ **Eficiencia:** Reducción de tiempo en coordinación de citas
- ✅ **Visibilidad:** Panorama completo de sus citas programadas
- ✅ **Historial:** Registro de pacientes atendidos

**Para la Institución de Salud:**
- ✅ **Optimización:** Mejor aprovechamiento de recursos y consultorios
- ✅ **Reducción de costos:** Menor necesidad de personal administrativo para agendamiento
- ✅ **Métricas:** Datos estadísticos para análisis y toma de decisiones
- ✅ **Calidad de servicio:** Mejora en la experiencia del paciente
- ✅ **Reducción de no-asistencias:** Sistema de recordatorios disminuye las ausencias

### 1.3.3. Justificación Técnica

El uso de tecnologías modernas y robustas garantiza:

- **Escalabilidad:** La arquitectura permite crecer conforme aumenta la demanda
- **Mantenibilidad:** Código organizado y documentado facilita futuras mejoras
- **Seguridad:** Protección de datos sensibles de pacientes
- **Rendimiento:** Respuestas rápidas incluso con múltiples usuarios concurrentes
- **Portabilidad:** Acceso desde cualquier dispositivo con navegador web

---

## 1.4. Marco Teórico

### 1.4.1. Arquitectura Cliente-Servidor

El sistema implementa el modelo **cliente-servidor**, donde:

- **Cliente (Frontend):** Interfaz de usuario en el navegador web
  - Presenta información al usuario
  - Captura datos ingresados por el usuario
  - Envía peticiones HTTP al servidor
  - Recibe y procesa respuestas del servidor

- **Servidor (Backend):** Aplicación Spring Boot
  - Procesa las peticiones del cliente
  - Ejecuta la lógica de negocio
  - Interactúa con la base de datos
  - Retorna respuestas al cliente

**Ventajas de esta arquitectura:**
- ✅ Separación de responsabilidades
- ✅ Facilita el mantenimiento independiente de cada capa
- ✅ Permite múltiples clientes (web, móvil, desktop)
- ✅ Centraliza la lógica de negocio en el servidor

### 1.4.2. Modelo CRUD (Create, Read, Update, Delete)

Las operaciones básicas sobre las entidades del sistema siguen el patrón CRUD:

| Operación | Descripción | Método HTTP |
|-----------|-------------|-------------|
| **Create** | Crear un nuevo registro | POST |
| **Read** | Consultar registros existentes | GET |
| **Update** | Actualizar un registro | PUT/PATCH |
| **Delete** | Eliminar un registro | DELETE |

**Ejemplo aplicado a Pacientes:**
- **Create:** Registrar un nuevo paciente en el sistema
- **Read:** Consultar los datos de un paciente
- **Update:** Actualizar información personal del paciente
- **Delete:** Eliminar un paciente del sistema (soft delete)

### 1.4.3. Patrón MVC (Modelo-Vista-Controlador)

El sistema implementa el patrón arquitectónico MVC:

```
┌─────────────────────────────────────────────┐
│              VISTA (Frontend)               │
│    HTML + CSS + JavaScript                  │
│    - Presentación de datos                  │
│    - Captura de entrada del usuario         │
└──────────────────┬──────────────────────────┘
                   │ Peticiones HTTP
                   ↓
┌─────────────────────────────────────────────┐
│         CONTROLADOR (Controllers)           │
│    - Recibe peticiones HTTP                 │
│    - Valida datos de entrada                │
│    - Invoca servicios de negocio            │
│    - Retorna respuestas HTTP                │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│          SERVICIO (Services)                │
│    - Lógica de negocio                      │
│    - Validaciones complejas                 │
│    - Coordinación de operaciones            │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│         MODELO (Entities + DTOs)            │
│    - Representación de datos                │
│    - Mapeo objeto-relacional (JPA)          │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│        PERSISTENCIA (Repositories)          │
│    - Acceso a la base de datos              │
│    - Operaciones CRUD                       │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│         BASE DE DATOS (PostgreSQL)          │
└─────────────────────────────────────────────┘
```

**Ventajas del patrón MVC:**
- ✅ Separación clara de responsabilidades
- ✅ Facilita el testing unitario
- ✅ Permite trabajar en paralelo en diferentes capas
- ✅ Reutilización de componentes

### 1.4.4. API REST (Representational State Transfer)

El backend expone una **API RESTful** que cumple con los principios:

1. **Arquitectura Cliente-Servidor:** Separación de preocupaciones
2. **Sin Estado (Stateless):** Cada petición contiene toda la información necesaria
3. **Cacheable:** Las respuestas indican si pueden ser cacheadas
4. **Interfaz Uniforme:** Uso consistente de métodos HTTP y URIs
5. **Sistema en Capas:** Arquitectura modular y escalable

**Ejemplo de endpoints REST:**

```
# Pacientes
GET    /api/pacientes           → Listar todos los pacientes
GET    /api/pacientes/{id}      → Obtener un paciente por ID
POST   /api/pacientes           → Crear un nuevo paciente
PUT    /api/pacientes/{id}      → Actualizar un paciente
DELETE /api/pacientes/{id}      → Eliminar un paciente

# Citas
GET    /api/citas               → Listar todas las citas
GET    /api/citas/{id}          → Obtener una cita por ID
POST   /api/citas               → Registrar una nueva cita
PUT    /api/citas/{id}/cancelar → Cancelar una cita
```

**Códigos de respuesta HTTP:**

| Código | Significado | Uso |
|--------|-------------|-----|
| 200 | OK | Operación exitosa |
| 201 | Created | Recurso creado exitosamente |
| 204 | No Content | Operación exitosa sin contenido de respuesta |
| 400 | Bad Request | Datos de entrada inválidos |
| 404 | Not Found | Recurso no encontrado |
| 500 | Internal Server Error | Error del servidor |

### 1.4.5. Gestión de Sesiones y Autenticación

El sistema implementa autenticación basada en **sesiones** o **tokens JWT**:

**Flujo de Autenticación:**

```
1. Usuario envía credenciales (username, password)
   ↓
2. Servidor valida credenciales contra la BD
   ↓
3. Si es válido, genera un token de sesión
   ↓
4. Cliente almacena el token (localStorage)
   ↓
5. Cliente incluye el token en cada petición posterior
   ↓
6. Servidor valida el token antes de procesar la petición
```

**Niveles de Autorización:**

| Rol | Permisos |
|-----|----------|
| **Paciente** | Ver su perfil, agendar citas, ver sus citas, cancelar sus citas |
| **Médico** | Ver su agenda, ver pacientes, actualizar estado de citas |
| **Administrador** | Acceso total al sistema, gestión de usuarios, reportes |

### 1.4.6. Buenas Prácticas de UI/UX

El frontend se desarrolla siguiendo principios de usabilidad:

**Principios de Diseño:**
- ✅ **Simplicidad:** Interfaces limpias y sin elementos innecesarios
- ✅ **Consistencia:** Patrones visuales uniformes en todo el sistema
- ✅ **Feedback:** Confirmaciones y mensajes de error claros
- ✅ **Accesibilidad:** Cumplimiento de estándares WCAG 2.1
- ✅ **Responsive Design:** Adaptación a diferentes tamaños de pantalla
- ✅ **Performance:** Tiempos de carga optimizados

**Elementos de Usabilidad:**
- Formularios con validación en tiempo real
- Mensajes de error descriptivos
- Indicadores de carga (spinners)
- Confirmaciones antes de acciones críticas
- Breadcrumbs para navegación
- Tooltips informativos

### 1.4.7. Conexión a Base de Datos y ORM

El sistema utiliza **Spring Data JPA** como ORM (Object-Relational Mapping):

**Ventajas de usar JPA:**
- ✅ Abstracción del SQL nativo
- ✅ Mapeo automático objeto-relacional
- ✅ Queries mediante métodos de repositorio
- ✅ Manejo automático de transacciones
- ✅ Caché de primer nivel

**Ejemplo de Entidad JPA:**

```java
@Entity
@Table(name = "paciente")
public class Paciente {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_paciente")
    private Integer idPaciente;
    
    @Column(name = "dni", length = 8, unique = true)
    private String dni;
    
    @Column(name = "nombres")
    private String nombres;
    
    // ... más atributos
    
    @OneToMany(mappedBy = "paciente")
    private Set<Cita> citas;
}
```

**Capas de Persistencia:**

```
┌───────────────────────────────────┐
│   ENTITY (Modelo de dominio)     │
├───────────────────────────────────┤
│   DTO (Data Transfer Object)     │
├───────────────────────────────────┤
│   REPOSITORY (Acceso a datos)    │
├───────────────────────────────────┤
│   JPA / Hibernate                │
├───────────────────────────────────┤
│   JDBC                            │
├───────────────────────────────────┤
│   PostgreSQL                      │
└───────────────────────────────────┘
```

---

## 1.5. Tecnologías Utilizadas

### 1.5.1. Backend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Java** | 17 LTS | Lenguaje de programación |
| **Spring Boot** | 3.2.x | Framework de desarrollo |
| **Spring Data JPA** | 3.2.x | Capa de persistencia |
| **Spring Security** | 6.x | Autenticación y autorización |
| **Spring Validation** | 3.x | Validación de datos |
| **PostgreSQL, SUPABASE** | 15.x | Sistema de gestión de BD |
| **Maven** | 3.9.x | Gestión de dependencias |


### 1.5.2. Frontend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **HTML5** | - | Estructura de páginas |
| **CSS3** | - | Estilos y diseño |
| **JavaScript** | ES6+ | Lógica del cliente |

### 1.5.3. Herramientas de Desarrollo

| Herramienta | Propósito |
|-------------|-----------|
| **IntelliJ IDEA** | IDE para desarrollo Java |
| **Visual Studio Code** | Editor para frontend |
| **pgAdmin 4** | Administración de PostgreSQL |
| **Postman** | Testing de API REST |
| **Git** | Control de versiones |
| **GitHub** | Repositorio remoto |
| **Draw.io** | Creación de diagramas UML |

---

## 1.6. Metodología de Desarrollo

El proyecto sigue una metodología **incremental e iterativa**, dividida en fases:

### Fase 1: Análisis y Diseño (Semanas 1-2)
- ✅ Análisis de requerimientos
- ✅ Casos de uso y diagramas UML
- ✅ Diseño conceptual de base de datos
- ✅ Diseño lógico relacional
- ✅ Prototipos de interfaces

### Fase 2: Implementación de Base de Datos (Semana 3)
- ✅ Creación de scripts DDL
- ✅ Inserción de datos de prueba
- ✅ Creación de vistas y procedimientos

### Fase 3: Desarrollo Backend (Semanas 4-5)
- ✅ Configuración del proyecto Spring Boot
- ✅ Implementación de entidades JPA
- ✅ Desarrollo de repositorios
- ✅ Implementación de servicios
- ✅ Desarrollo de controladores REST

### Fase 4: Desarrollo Frontend (Semanas 6-7)
- ✅ Estructura HTML de páginas
- ✅ Estilos CSS y diseño responsivo
- ✅ Lógica JavaScript
- ✅ Integración con API REST

### Fase 5: Testing y Refinamiento (Semana 8)
- ✅ Pruebas unitarias
- ✅ Pruebas de integración
- ✅ Corrección de bugs
- ✅ Optimizaciones de rendimiento

### Fase 6: Documentación y Entrega (Semana 8)
- ✅ Documentación técnica
- ✅ Manuales de usuario
- ✅ Preparación de presentación
- ✅ Entrega final

---

## 1.7. Referencias Bibliográficas

1. **Sommerville, I. (2019).** *Ingeniería del Software* (10ª ed.). Pearson Educación.
   - Capítulo 4: Ingeniería de Requisitos
   - Capítulo 5: Modelado de Sistemas
   - Capítulo 7: Diseño e Implementación

2. **Fowler, M. (2018).** *Patterns of Enterprise Application Architecture*. Addison-Wesley Professional.
   - Patrones de arquitectura en capas
   - Patrones de acceso a datos

3. **Freeman, E., Robson, E., Bates, B., & Sierra, K. (2021).** *Head First Design Patterns* (2ª ed.). O'Reilly Media.
   - Patrones de diseño aplicados

4. **Richardson, C. (2018).** *Microservices Patterns*. Manning Publications.
   - Arquitectura de servicios REST

5. **Spring Framework Documentation** (2024). Spring Boot Reference Documentation.
   - Disponible en: https://docs.spring.io/spring-boot/docs/current/reference/html/

6. **PostgreSQL Documentation** (2024). PostgreSQL 15 Official Documentation.
   - Disponible en: https://www.postgresql.org/docs/15/

7. **Elmasri, R., & Navathe, S. B. (2015).** *Fundamentos de Sistemas de Bases de Datos* (7ª ed.). Pearson.
   - Capítulo 7: Modelo Entidad-Relación
   - Capítulo 9: Normalización

8. **Mozilla Developer Network** (2024). Web APIs and Technologies.
   - Disponible en: https://developer.mozilla.org/

---

## 1.8. Glosario de Términos

| Término | Definición |
|---------|------------|
| **API** | Application Programming Interface - Interfaz de comunicación entre sistemas |
| **CRUD** | Create, Read, Update, Delete - Operaciones básicas sobre datos |
| **DTO** | Data Transfer Object - Objeto para transferencia de datos |
| **JPA** | Java Persistence API - Estándar de persistencia para Java |
| **ORM** | Object-Relational Mapping - Mapeo objeto-relacional |
| **REST** | Representational State Transfer - Estilo arquitectónico para servicios web |
| **UML** | Unified Modeling Language - Lenguaje de modelado unificado |
| **MVC** | Model-View-Controller - Patrón de arquitectura de software |
| **JWT** | JSON Web Token - Estándar para tokens de autenticación |
| **3FN** | Tercera Forma Normal - Nivel de normalización de bases de datos |

---

[⬅️ Volver al índice de documentación](README.md) | [Siguiente: Requerimientos ➡️](02-requerimientos.md)

---

<div align="center">
  <strong>Sistema de Reserva de Consultas Médicas Externas</strong><br>
  Universidad Nacional de Ingeniería - 2025<br>
  Construcción de Software I
</div>