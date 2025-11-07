package com.hospital.reservas.controller;

import com.hospital.reservas.dto.request.LoginRequest;
import com.hospital.reservas.dto.request.PacienteRequest;
import com.hospital.reservas.dto.response.LoginResponse;
import com.hospital.reservas.dto.response.PacienteResponse;
import com.hospital.reservas.entity.Usuario;
import com.hospital.reservas.repository.UsuarioRepository;
import com.hospital.reservas.security.JwtUtils;
import com.hospital.reservas.service.PacienteService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = Logger.getLogger(AuthController.class.getName());

    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final UsuarioRepository usuarioRepository;
    private final PacienteService pacienteService;

    public AuthController(AuthenticationManager authenticationManager,
                         JwtUtils jwtUtils,
                         UsuarioRepository usuarioRepository,
                         PacienteService pacienteService) {
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
        this.usuarioRepository = usuarioRepository;
        this.pacienteService = pacienteService;
    }

    /**
     * Endpoint para iniciar sesión
     * POST /api/auth/login
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            logger.info("Intento de login para usuario: " + loginRequest.getUsername());

            // DEBUG: Información de la contraseña recibida
            logger.info("=== DEBUG PASSWORD REQUEST ===");
            logger.info("Password recibida - Longitud: " + (loginRequest.getPassword() != null ? loginRequest.getPassword().length() : "null"));
            logger.info("Password recibida: " + loginRequest.getPassword());
            logger.info("Username recibido: " + loginRequest.getUsername());
            logger.info("==============================");

            // Autenticar usuario
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);

            // Generar token JWT
            String jwt = jwtUtils.generateJwtToken(authentication);
            Date expiresAt = jwtUtils.getExpirationDateFromJwtToken(jwt);

            // Obtener información del usuario
            Usuario usuario = usuarioRepository.findByUsername(loginRequest.getUsername())
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            LoginResponse response = new LoginResponse(
                    jwt,
                    usuario.getUsername(),
                    usuario.getRol(),
                    usuario.getIdReferencia() != null ? usuario.getIdReferencia().longValue() : null,
                    expiresAt
            );

            logger.info("Login exitoso para usuario: " + loginRequest.getUsername() + " con rol: " + usuario.getRol());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.severe("Error en login: " + e.getMessage());

            Map<String, String> error = new HashMap<>();
            error.put("error", "Credenciales inválidas");
            error.put("message", "Usuario o contraseña incorrectos");

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    /**
     * Endpoint para registrar un nuevo paciente
     * POST /api/auth/register
     */
    @PostMapping("/register")
    public ResponseEntity<?> registerPaciente(@Valid @RequestBody PacienteRequest request) {
        try {
            logger.info("=== INICIO REGISTRO DE PACIENTE ===");
            logger.info("DNI: " + request.getDni());
            logger.info("Nombres: " + request.getNombres());
            logger.info("Apellidos: " + request.getApellidoPaterno() + " " + request.getApellidoMaterno());
            logger.info("Sexo: " + request.getSexo());
            logger.info("Email: " + request.getEmail());
            logger.info("Telefono: " + request.getTelefono());
            logger.info("Username: " + request.getNombreUsuario());

            // Verificar si el DNI ya existe
            if (pacienteService.existePorDni(request.getDni())) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "DNI ya registrado");
                error.put("message", "Ya existe un paciente con el DNI: " + request.getDni());
                return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
            }

            // Verificar si el username ya existe
            if (usuarioRepository.findByUsername(request.getNombreUsuario()).isPresent()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Username ya existe");
                error.put("message", "El nombre de usuario ya está en uso");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
            }

            // Crear paciente (que automáticamente crea el usuario)
            PacienteResponse paciente = pacienteService.crear(request);

            // Generar token automáticamente después del registro
            String jwt = jwtUtils.generateTokenFromUsername(request.getNombreUsuario());
            Date expiresAt = jwtUtils.getExpirationDateFromJwtToken(jwt);

            LoginResponse response = new LoginResponse(
                    jwt,
                    request.getNombreUsuario(),
                    "PACIENTE",
                    paciente.getIdPaciente(),
                    expiresAt
            );

            logger.info("Paciente registrado exitosamente con ID: " + paciente.getIdPaciente());
            logger.info("Token JWT generado para usuario: " + request.getNombreUsuario());
            logger.info("=== FIN REGISTRO EXITOSO ===");

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (IllegalArgumentException e) {
            logger.warning("Error de validación en registro: " + e.getMessage());

            Map<String, String> error = new HashMap<>();
            error.put("error", "Error de validación");
            error.put("message", e.getMessage());

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);

        } catch (Exception e) {
            logger.severe("Error inesperado en registro: " + e.getMessage());
            e.printStackTrace();

            Map<String, String> error = new HashMap<>();
            error.put("error", "Error en el registro");
            error.put("message", e.getMessage() != null ? e.getMessage() : "Error interno del servidor");

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Endpoint para verificar si el token es válido
     * GET /api/auth/validate
     */
    @GetMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader("Authorization") String authHeader) {
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                        Map.of("valid", false, "message", "Token no proporcionado")
                );
            }

            String token = authHeader.substring(7);

            if (jwtUtils.validateJwtToken(token)) {
                String username = jwtUtils.getUsernameFromJwtToken(token);
                Usuario usuario = usuarioRepository.findByUsername(username).orElse(null);

                if (usuario != null && usuario.getActivo()) {
                    return ResponseEntity.ok(Map.of(
                            "valid", true,
                            "username", usuario.getUsername(),
                            "rol", usuario.getRol(),
                            "idReferencia", usuario.getIdReferencia()
                    ));
                }
            }

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    Map.of("valid", false, "message", "Token inválido o expirado")
            );

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    Map.of("valid", false, "message", e.getMessage())
            );
        }
    }

    /**
     * Endpoint para obtener información del usuario actual
     * GET /api/auth/me
     */
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    Map.of("error", "No autenticado")
            );
        }

        String username = authentication.getName();
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("username", usuario.getUsername());
        userInfo.put("rol", usuario.getRol());
        userInfo.put("idReferencia", usuario.getIdReferencia());
        userInfo.put("activo", usuario.getActivo());

        return ResponseEntity.ok(userInfo);
    }
}
