package com.hospital.reservas.service;

import com.hospital.reservas.dto.request.PacienteRequest;
import com.hospital.reservas.dto.response.PacienteResponse;
import com.hospital.reservas.entity.Paciente;
import com.hospital.reservas.entity.Usuario;
import com.hospital.reservas.exception.ResourceNotFoundException;
import com.hospital.reservas.repository.PacienteRepository;
import com.hospital.reservas.repository.UsuarioRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Service
@Transactional
public class PacienteService{

    private static final Logger logger = Logger.getLogger(PacienteService.class.getName());

    private final PacienteRepository pacienteRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public PacienteService(PacienteRepository pacienteRepository,
                           UsuarioRepository usuarioRepository,
                           PasswordEncoder passwordEncoder) {
        this.pacienteRepository = pacienteRepository;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<PacienteResponse> listarTodos() {
        logger.info("Listando todos los pacientes");
        return pacienteRepository.findAll()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public List<PacienteResponse> listarActivos() {
        logger.info("Listando pacientes activos");
        return pacienteRepository.findByActivoTrue()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public PacienteResponse obtenerPorId(Long id) {
        logger.info("Obteniendo paciente con ID: " + id);
        Paciente paciente = pacienteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado con ID: " + id));
        return convertirAResponse(paciente);
    }

    public PacienteResponse obtenerPorDni(String dni) {
        logger.info("Obteniendo paciente con DNI: " + dni);
        Paciente paciente = pacienteRepository.findByDni(dni)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado con DNI: " + dni));
        return convertirAResponse(paciente);
    }

    public PacienteResponse crear(PacienteRequest request) {
        logger.info("=== SERVICIO PACIENTE - CREAR ===");
        logger.info("DNI: " + request.getDni());
        logger.info("Email: " + request.getEmail());
        logger.info("Sexo recibido: [" + request.getSexo() + "]");

        // Validar que no exista
        if (pacienteRepository.existsByDni(request.getDni())) {
            logger.warning("DNI duplicado: " + request.getDni());
            throw new IllegalArgumentException("Ya existe un paciente con DNI: " + request.getDni());
        }
        if (request.getEmail() != null && pacienteRepository.existsByEmail(request.getEmail())) {
            logger.warning("Email duplicado: " + request.getEmail());
            throw new IllegalArgumentException("Ya existe un paciente con email: " + request.getEmail());
        }

        // Crear usuario si se proporcionaron credenciales
        if (request.getNombreUsuario() != null && request.getContrasena() != null) {
            logger.info("Creando paciente con usuario: " + request.getNombreUsuario());

            // Validar que el username no exista
            if (usuarioRepository.existsByUsername(request.getNombreUsuario())) {
                logger.warning("Username duplicado: " + request.getNombreUsuario());
                throw new IllegalArgumentException("Ya existe un usuario con nombre de usuario: " + request.getNombreUsuario());
            }

            logger.info("Creando usuario en BD...");
            Usuario usuario = new Usuario();
            usuario.setUsername(request.getNombreUsuario());
            usuario.setPasswordHash(passwordEncoder.encode(request.getContrasena()));
            usuario.setRol("PACIENTE");
            usuario.setActivo(true);
            usuario = usuarioRepository.save(usuario);
            logger.info("Usuario creado con ID: " + usuario.getIdUsuario());

            // Guardar paciente primero para obtener el ID
            logger.info("Creando paciente en BD...");
            Paciente paciente = crearPacienteDesdeRequest(request);
            paciente = pacienteRepository.save(paciente);
            logger.info("Paciente guardado con ID: " + paciente.getIdPaciente());

            // Actualizar usuario con referencia al paciente
            logger.info("Actualizando referencia en usuario...");
            usuario.setIdReferencia(paciente.getIdPaciente().intValue());
            usuarioRepository.save(usuario);
            logger.info("Usuario actualizado con idReferencia: " + usuario.getIdReferencia());

            logger.info("Paciente creado exitosamente con ID: " + paciente.getIdPaciente());
            return convertirAResponse(paciente);
        }

        // Crear paciente sin usuario
        logger.info("Creando paciente sin usuario");
        Paciente paciente = crearPacienteDesdeRequest(request);
        paciente = pacienteRepository.save(paciente);
        logger.info("Paciente creado exitosamente con ID: " + paciente.getIdPaciente());

        return convertirAResponse(paciente);
    }

    private Paciente crearPacienteDesdeRequest(PacienteRequest request) {
        Paciente paciente = new Paciente();
        paciente.setDni(request.getDni());
        paciente.setNombres(request.getNombres());
        paciente.setApellidoPaterno(request.getApellidoPaterno());
        paciente.setApellidoMaterno(request.getApellidoMaterno());
        paciente.setFechaNacimiento(request.getFechaNacimiento());
        paciente.setSexo(request.getSexo());
        paciente.setDireccion(request.getDireccion());
        paciente.setTelefono(request.getTelefono());
        paciente.setEmail(request.getEmail());
        paciente.setNumeroSeguro(request.getNumeroSeguro());
        paciente.setActivo(true);
        return paciente;
    }

    public PacienteResponse actualizar(Long id, PacienteRequest request) {
        logger.info("Actualizando paciente con ID: " + id);

        Paciente paciente = pacienteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado con ID: " + id));

        // Actualizar campos
        paciente.setNombres(request.getNombres());
        paciente.setApellidoPaterno(request.getApellidoPaterno());
        paciente.setApellidoMaterno(request.getApellidoMaterno());
        paciente.setFechaNacimiento(request.getFechaNacimiento());
        paciente.setSexo(request.getSexo());
        paciente.setDireccion(request.getDireccion());
        paciente.setTelefono(request.getTelefono());
        paciente.setEmail(request.getEmail());
        paciente.setNumeroSeguro(request.getNumeroSeguro());

        paciente = pacienteRepository.save(paciente);
        logger.info("Paciente actualizado exitosamente");

        return convertirAResponse(paciente);
    }

    public void eliminar(Long id) {
        logger.info("Eliminando paciente con ID: " + id);

        Paciente paciente = pacienteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado con ID: " + id));

        paciente.setActivo(false);
        pacienteRepository.save(paciente);

        logger.info("Paciente eliminado (desactivado) exitosamente");
    }

    public List<PacienteResponse> buscar(String filtro) {
        logger.info("Buscando pacientes con filtro: " + filtro);
        return pacienteRepository.buscarPorFiltro(filtro)
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public boolean existePorDni(String dni) {
        logger.info("Verificando existencia de paciente con DNI: " + dni);
        return pacienteRepository.findByDni(dni).isPresent();
    }

    private PacienteResponse convertirAResponse(Paciente paciente) {
        PacienteResponse response = new PacienteResponse();
        response.setIdPaciente(paciente.getIdPaciente());
        response.setDni(paciente.getDni());
        response.setNombres(paciente.getNombres());
        response.setApellidoPaterno(paciente.getApellidoPaterno());
        response.setApellidoMaterno(paciente.getApellidoMaterno());
        response.setNombreCompleto(paciente.getNombres() + " " +
                                   paciente.getApellidoPaterno() + " " +
                                   paciente.getApellidoMaterno());
        response.setFechaNacimiento(paciente.getFechaNacimiento());
        response.setSexo(paciente.getSexo());
        response.setDireccion(paciente.getDireccion());
        response.setTelefono(paciente.getTelefono());
        response.setEmail(paciente.getEmail());
        response.setNumeroSeguro(paciente.getNumeroSeguro());
        response.setActivo(paciente.getActivo());
        response.setFechaRegistro(paciente.getFechaRegistro());
        return response;
    }
}
