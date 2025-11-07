# Actividad 4: Implementación Backend
## API REST del Sistema de Reserva de Consultas Médicas

---

## Descripción

Este módulo contiene la implementación completa del backend del sistema, desarrollado con **Spring Boot** siguiendo una arquitectura en capas. La API REST proporciona endpoints seguros para la gestión de usuarios, médicos, pacientes, especialidades, citas y autenticación mediante JWT.

---

## Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| Spring Boot | 3.4.1 | Framework principal |
| Spring Security | 6.4.2 | Autenticación y autorización |
| Spring Data JPA | 3.4.1 | Persistencia de datos |
| PostgreSQL | 16+ | Base de datos |
| JWT (jjwt) | 0.12.6 | Tokens de autenticación |
| Maven | 3.9+ | Gestión de dependencias |
| Lombok | 1.18.34 | Reducción de código boilerplate |
| Jakarta Validation | 3.1.0 | Validación de datos |

---

## Arquitectura del Sistema

### Patrón de Capas

```
┌─────────────────────────────────────┐
│         CAPA CONTROLADOR            │
│   (Recepción de peticiones HTTP)    │
│   @RestController / @RequestMapping │
└───────────────┬─────────────────────┘
                │
                ↓
┌─────────────────────────────────────┐
│         CAPA DE SERVICIO            │
│      (Lógica de negocio)            │
│           @Service                  │
└───────────────┬─────────────────────┘
                │
                ↓
┌─────────────────────────────────────┐
│       CAPA DE REPOSITORIO           │
│    (Acceso a base de datos)         │
│  @Repository / JpaRepository        │
└───────────────┬─────────────────────┘
                │
                ↓
┌─────────────────────────────────────┐
│         BASE DE DATOS               │
│          PostgreSQL                 │
└─────────────────────────────────────┘
```

---

## Estructura de Carpetas

```
08-backend/
├── controller/             # Controladores REST
│   ├── AuthController.java
│   ├── CitaController.java
│   ├── ConsultorioController.java
│   ├── EspecialidadController.java
│   ├── HorarioAtencionController.java
│   ├── MedicoController.java
│   └── PacienteController.java
│
├── service/                # Lógica de negocio
│   ├── CitaService.java
│   ├── ConsultorioService.java
│   ├── EspecialidadService.java
│   ├── HorarioAtencionService.java
│   ├── MedicoService.java
│   └── PacienteService.java
│
├── repository/             # Acceso a datos
│   ├── CitaRepository.java
│   ├── ConsultorioRepository.java
│   ├── EspecialidadRepository.java
│   ├── EstadoCitaRepository.java
│   ├── HorarioAtencionRepository.java
│   ├── MedicoRepository.java
│   ├── PacienteRepository.java
│   └── UsuarioRepository.java
│
├── entity/                 # Entidades JPA
│   ├── Cita.java
│   ├── Consultorio.java
│   ├── Especialidad.java
│   ├── EstadoCita.java
│   ├── HorarioAtencion.java
│   ├── Medico.java
│   ├── Paciente.java
│   └── Usuario.java
│
├── dto/                    # Objetos de transferencia
│   ├── request/
│   │   ├── CitaRequest.java
│   │   ├── EspecialidadRequest.java
│   │   ├── LoginRequest.java
│   │   ├── MedicoRequest.java
│   │   └── PacienteRequest.java
│   └── response/
│       ├── CitaResponse.java
│       ├── EspecialidadResponse.java
│       ├── LoginResponse.java
│       ├── MedicoResponse.java
│       └── PacienteResponse.java
│
├── config/                 # Configuración
│   └── SecurityConfig.java
│
└── security/               # Seguridad JWT
    ├── JwtUtils.java
    ├── JwtAuthenticationFilter.java
    └── UserDetailsServiceImpl.java
```

---

## Entidades Principales

### 1. Usuario

```java
@Entity
@Table(name = "usuario")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idUsuario;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String rol; // ADMIN, MEDICO, PACIENTE

    @Column(nullable = false)
    private Boolean activo;

    private Integer idReferencia; // Referencia a Medico o Paciente
}
```

### 2. Paciente

```java
@Entity
@Table(name = "paciente")
public class Paciente {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idPaciente;

    @Column(nullable = false, unique = true)
    private String dni;

    @Column(nullable = false)
    private String nombres;

    @Column(nullable = false)
    private String apellidoPaterno;

    @Column(nullable = false)
    private String apellidoMaterno;

    private LocalDate fechaNacimiento;

    @Column(nullable = false)
    private String sexo; // M o F

    private String direccion;
    private String telefono;
    private String email;
}
```

### 3. Médico

```java
@Entity
@Table(name = "medico")
public class Medico {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idMedico;

    @Column(nullable = false, unique = true)
    private String codigoMedico;

    @Column(nullable = false, unique = true)
    private String numeroColegiatura;

    @Column(nullable = false)
    private String nombres;

    @Column(nullable = false)
    private String apellidoPaterno;

    @Column(nullable = false)
    private String apellidoMaterno;

    private String telefono;
    private String email;

    @ManyToOne
    @JoinColumn(name = "id_especialidad", nullable = false)
    private Especialidad especialidad;

    @Column(nullable = false)
    private Boolean activo;
}
```

### 4. Cita

```java
@Entity
@Table(name = "cita")
public class Cita {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idCita;

    @ManyToOne
    @JoinColumn(name = "id_paciente", nullable = false)
    private Paciente paciente;

    @ManyToOne
    @JoinColumn(name = "id_medico", nullable = false)
    private Medico medico;

    @ManyToOne
    @JoinColumn(name = "id_consultorio")
    private Consultorio consultorio;

    @Column(nullable = false)
    private LocalDateTime fechaHora;

    @Column(nullable = false)
    private String estado; // PROGRAMADA, ATENDIDA, CANCELADA

    @Lob
    private String observaciones;
}
```

---

## Endpoints de la API

### Autenticación

#### POST /api/auth/login
Iniciar sesión

**Request:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "username": "admin",
  "rol": "ADMIN",
  "idReferencia": null,
  "expiresAt": "2025-12-08T10:30:00"
}
```

#### POST /api/auth/register
Registrar nuevo paciente

**Request:**
```json
{
  "dni": "12345678",
  "nombres": "Juan",
  "apellidoPaterno": "García",
  "apellidoMaterno": "López",
  "fechaNacimiento": "1990-01-15",
  "sexo": "M",
  "direccion": "Av. Principal 123",
  "telefono": "987654321",
  "email": "juan@email.com",
  "nombreUsuario": "juan123",
  "contrasena": "Pass123456"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "username": "juan123",
  "rol": "PACIENTE",
  "idReferencia": 1,
  "expiresAt": "2025-12-08T10:30:00"
}
```

---

### Médicos

#### GET /api/medicos
Listar todos los médicos

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "idMedico": 1,
    "codigoMedico": "MED001",
    "numeroColegiatura": "CMP-12345",
    "nombreCompleto": "Dr. Juan García López",
    "telefono": "987654321",
    "email": "medico@hospital.com",
    "activo": true,
    "especialidad": {
      "idEspecialidad": 1,
      "nombre": "Cardiología"
    }
  }
]
```

#### POST /api/medicos
Crear nuevo médico (Solo ADMIN)

**Request:**
```json
{
  "codigoMedico": "MED002",
  "numeroColegiatura": "CMP-67890",
  "nombres": "María",
  "apellidoPaterno": "Rodríguez",
  "apellidoMaterno": "Silva",
  "idEspecialidad": 2,
  "telefono": "912345678",
  "email": "maria@hospital.com",
  "nombreUsuario": "mrodriguez",
  "contrasena": "Med123456"
}
```

---

### Citas

#### GET /api/citas
Listar citas (filtrado por rol)

**Response:**
```json
[
  {
    "idCita": 1,
    "paciente": {
      "idPaciente": 1,
      "nombreCompleto": "Juan García López"
    },
    "medico": {
      "idMedico": 1,
      "nombreCompleto": "Dr. Pedro Martínez"
    },
    "fechaHora": "2025-12-10T10:00:00",
    "estado": "PROGRAMADA",
    "consultorio": {
      "numero": "101",
      "piso": "Primer Piso"
    }
  }
]
```

#### POST /api/citas
Crear nueva cita (Paciente)

**Request:**
```json
{
  "idPaciente": 1,
  "idMedico": 1,
  "idHorarioAtencion": 5,
  "fechaHora": "2025-12-10T10:00:00",
  "observaciones": "Primera consulta"
}
```

---

### Especialidades

#### GET /api/especialidades
Listar especialidades

**Response:**
```json
[
  {
    "idEspecialidad": 1,
    "codigo": "CARD",
    "nombre": "Cardiología",
    "descripcion": "Especialidad del corazón",
    "activo": true
  }
]
```

#### POST /api/especialidades
Crear especialidad (Solo ADMIN)

**Request:**
```json
{
  "codigo": "NEUMOL",
  "nombre": "Neumología",
  "descripcion": "Especialidad de pulmones"
}
```

---

## Seguridad

### Autenticación JWT

El sistema utiliza **JSON Web Tokens (JWT)** para la autenticación:

```java
@Component
public class JwtUtils {
    private String jwtSecret = "clave-secreta-super-segura-para-jwt-tokens";
    private int jwtExpirationMs = 86400000; // 24 horas

    public String generateJwtToken(Authentication authentication) {
        UserDetails userPrincipal = (UserDetails) authentication.getPrincipal();

        return Jwts.builder()
                .setSubject(userPrincipal.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date((new Date()).getTime() + jwtExpirationMs))
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }

    public boolean validateJwtToken(String authToken) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(authToken);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
```

### Configuración de Seguridad

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/medicos/**").hasAnyRole("ADMIN", "MEDICO")
                .anyRequest().authenticated()
            )
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS);

        http.addFilterBefore(jwtAuthenticationFilter(),
                           UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
```

### Roles y Permisos

| Rol | Permisos |
|-----|----------|
| **ADMIN** | Acceso completo a todos los endpoints |
| **MEDICO** | Ver y gestionar sus propias citas y horarios |
| **PACIENTE** | Ver y crear sus propias citas |

---

## Validaciones

Todas las entidades implementan validaciones con **Jakarta Validation**:

```java
public class MedicoRequest {
    @NotBlank(message = "El código del médico es obligatorio")
    @Size(max = 20, message = "El código no puede exceder 20 caracteres")
    private String codigoMedico;

    @NotBlank(message = "El número de colegiatura es obligatorio")
    private String numeroColegiatura;

    @NotBlank(message = "Los nombres son obligatorios")
    private String nombres;

    @NotBlank(message = "El teléfono es obligatorio")
    @Pattern(regexp = "\\d{9}", message = "El teléfono debe tener 9 dígitos")
    private String telefono;

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El email debe ser válido")
    private String email;

    @NotNull(message = "La especialidad es obligatoria")
    private Long idEspecialidad;
}
```

---

## Manejo de Errores

### GlobalExceptionHandler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<?> handleResourceNotFound(ResourceNotFoundException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", "Recurso no encontrado");
        error.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<?> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errors);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<?> handleIllegalArgument(IllegalArgumentException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", "Error de validación");
        error.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }
}
```

---

## Configuración

### application.properties

```properties
# Base de datos
spring.datasource.url=jdbc:postgresql://localhost:5432/sistema_consultas_medicas
spring.datasource.username=postgres
spring.datasource.password=123456789
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# JWT
jwt.secret=clave-secreta-super-segura-para-jwt-tokens
jwt.expiration=86400000

# Server
server.port=8080
```

---

## Logs

El sistema implementa logs detallados:

```java
@Service
public class MedicoService {
    private static final Logger logger = Logger.getLogger(MedicoService.class.getName());

    public MedicoResponse crear(MedicoRequest request) {
        logger.info("=== SERVICIO MEDICO - CREAR ===");
        logger.info("Código Médico: " + request.getCodigoMedico());

        // ... lógica

        logger.info("Médico creado exitosamente con ID: " + medico.getIdMedico());
        logger.info("=== FIN CREACION MEDICO EXITOSO ===");
    }
}
```

---

## Testing

### Pruebas Unitarias (JUnit 5)

```java
@SpringBootTest
class MedicoServiceTest {

    @Autowired
    private MedicoService medicoService;

    @Test
    void testCrearMedico() {
        MedicoRequest request = new MedicoRequest();
        request.setCodigoMedico("MED001");
        request.setNumeroColegiatura("CMP-12345");
        request.setNombres("Juan");
        // ...

        MedicoResponse response = medicoService.crear(request);

        assertNotNull(response);
        assertEquals("MED001", response.getCodigoMedico());
    }
}
```

---

## Despliegue

### 1. Compilar el Proyecto

```bash
mvn clean package
```

### 2. Ejecutar JAR

```bash
java -jar target/sistema-reserva-consultas-0.0.1-SNAPSHOT.jar
```

### 3. Acceder a la API

```
http://localhost:8080/api
```

---

## Diagrama de Flujo - Creación de Cita

```
Cliente → POST /api/citas
   ↓
CitaController.crear()
   ↓
Validar @Valid CitaRequest
   ↓
CitaService.crear()
   ↓
1. Verificar disponibilidad de horario
2. Verificar que médico esté activo
3. Verificar que consultorio esté disponible
   ↓
CitaRepository.save()
   ↓
Base de Datos
   ↓
CitaResponse ← Cliente
```

---

## Mejoras Futuras

- [ ] Implementar caché con Redis
- [ ] Añadir websockets para notificaciones en tiempo real
- [ ] Implementar paginación en listados
- [ ] Añadir filtros avanzados en endpoints
- [ ] Implementar auditoría de cambios
- [ ] Añadir health checks con Actuator

---

## Créditos

**Desarrollador:** Franz
**Universidad:** Universidad Nacional de Ingeniería (UNI)
**Curso:** Desarrollo de Aplicaciones Web
**Fecha:** 2025

---

## Enlaces

- [← Frontend](../07-frontend/README.md)
- [Volver a Actividades](../README.md)
- [Pruebas →](../09-pruebas/README.md)
