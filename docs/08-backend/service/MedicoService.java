package com.hospital.reservas.service;

import com.hospital.reservas.dto.request.MedicoRequest;
import com.hospital.reservas.dto.response.EspecialidadResponse;
import com.hospital.reservas.dto.response.MedicoResponse;
import com.hospital.reservas.entity.Especialidad;
import com.hospital.reservas.entity.Medico;
import com.hospital.reservas.entity.Usuario;
import com.hospital.reservas.exception.ResourceNotFoundException;
import com.hospital.reservas.repository.EspecialidadRepository;
import com.hospital.reservas.repository.MedicoRepository;
import com.hospital.reservas.repository.UsuarioRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Service
@Transactional
public class MedicoService {

    private static final Logger logger = Logger.getLogger(MedicoService.class.getName());

    private final MedicoRepository medicoRepository;
    private final EspecialidadRepository especialidadRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public MedicoService(MedicoRepository medicoRepository,
                         EspecialidadRepository especialidadRepository,
                         UsuarioRepository usuarioRepository,
                         PasswordEncoder passwordEncoder) {
        this.medicoRepository = medicoRepository;
        this.especialidadRepository = especialidadRepository;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<MedicoResponse> listarTodos() {
        logger.info("Listando todos los médicos");
        return medicoRepository.findAll()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public List<MedicoResponse> listarActivos() {
        logger.info("Listando médicos activos");
        return medicoRepository.findByActivoTrue()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public MedicoResponse obtenerPorId(Long id) {
        logger.info("Obteniendo médico con ID: " + id);
        Medico medico = medicoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Médico no encontrado con ID: " + id));
        return convertirAResponse(medico);
    }

    public MedicoResponse obtenerPorCodigo(String codigo) {
        logger.info("Obteniendo médico con código: " + codigo);
        Medico medico = medicoRepository.findByCodigoMedico(codigo)
                .orElseThrow(() -> new ResourceNotFoundException("Médico no encontrado con código: " + codigo));
        return convertirAResponse(medico);
    }

    public List<MedicoResponse> buscarPorEspecialidad(Long idEspecialidad) {
        logger.info("Buscando médicos por especialidad: " + idEspecialidad);
        return medicoRepository.findByEspecialidadIdEspecialidad(idEspecialidad)
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public MedicoResponse crear(MedicoRequest request) {
        logger.info("=== SERVICIO MEDICO - CREAR ===");
        logger.info("Código Médico: " + request.getCodigoMedico());
        logger.info("Número Colegiatura: " + request.getNumeroColegiatura());
        logger.info("Email: " + request.getEmail());
        logger.info("Username: " + request.getNombreUsuario());

        // Validar que no exista
        if (medicoRepository.existsByCodigoMedico(request.getCodigoMedico())) {
            logger.warning("Código médico duplicado: " + request.getCodigoMedico());
            throw new IllegalArgumentException("Ya existe un médico con código: " + request.getCodigoMedico());
        }
        if (medicoRepository.existsByNumeroColegiatura(request.getNumeroColegiatura())) {
            logger.warning("Número de colegiatura duplicado: " + request.getNumeroColegiatura());
            throw new IllegalArgumentException("Ya existe un médico con número de colegiatura: " + request.getNumeroColegiatura());
        }

        // Buscar especialidad
        Especialidad especialidad = especialidadRepository.findById(request.getIdEspecialidad())
                .orElseThrow(() -> new ResourceNotFoundException("Especialidad no encontrada con ID: " + request.getIdEspecialidad()));
        logger.info("Especialidad encontrada: " + especialidad.getNombre());

        // Crear usuario si se proporcionaron credenciales
        if (request.getNombreUsuario() != null && request.getContrasena() != null) {
            logger.info("Creando médico con usuario: " + request.getNombreUsuario());

            // Validar que el username no exista
            if (usuarioRepository.existsByUsername(request.getNombreUsuario())) {
                logger.warning("Username duplicado: " + request.getNombreUsuario());
                throw new IllegalArgumentException("Ya existe un usuario con nombre de usuario: " + request.getNombreUsuario());
            }

            logger.info("Creando usuario en BD...");
            Usuario usuario = new Usuario();
            usuario.setUsername(request.getNombreUsuario());
            usuario.setPasswordHash(passwordEncoder.encode(request.getContrasena()));
            usuario.setRol("MEDICO");
            usuario.setActivo(true);
            usuario = usuarioRepository.save(usuario);
            logger.info("Usuario creado con ID: " + usuario.getIdUsuario());

            // Crear médico
            logger.info("Creando médico en BD...");
            Medico medico = crearMedicoDesdeRequest(request, especialidad);
            medico = medicoRepository.save(medico);
            logger.info("Médico guardado con ID: " + medico.getIdMedico());

            // Actualizar usuario con referencia al médico
            logger.info("Actualizando referencia en usuario...");
            usuario.setIdReferencia(medico.getIdMedico().intValue());
            usuarioRepository.save(usuario);
            logger.info("Usuario actualizado con idReferencia: " + usuario.getIdReferencia());

            logger.info("Médico creado exitosamente con ID: " + medico.getIdMedico());
            logger.info("=== FIN CREACION MEDICO EXITOSO ===");
            return convertirAResponse(medico);
        }

        // Crear médico sin usuario
        logger.info("Creando médico sin usuario");
        Medico medico = crearMedicoDesdeRequest(request, especialidad);
        medico = medicoRepository.save(medico);
        logger.info("Médico creado exitosamente con ID: " + medico.getIdMedico());

        return convertirAResponse(medico);
    }

    private Medico crearMedicoDesdeRequest(MedicoRequest request, Especialidad especialidad) {
        Medico medico = new Medico();
        medico.setCodigoMedico(request.getCodigoMedico());
        medico.setNumeroColegiatura(request.getNumeroColegiatura());
        medico.setNombres(request.getNombres());
        medico.setApellidoPaterno(request.getApellidoPaterno());
        medico.setApellidoMaterno(request.getApellidoMaterno());
        medico.setTelefono(request.getTelefono());
        medico.setEmail(request.getEmail());
        medico.setObservaciones(request.getObservaciones());
        medico.setEspecialidad(especialidad);
        medico.setActivo(true);
        return medico;
    }

    public MedicoResponse actualizar(Long id, MedicoRequest request) {
        logger.info("Actualizando médico con ID: " + id);

        Medico medico = medicoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Médico no encontrado con ID: " + id));

        // Buscar especialidad
        Especialidad especialidad = especialidadRepository.findById(request.getIdEspecialidad())
                .orElseThrow(() -> new ResourceNotFoundException("Especialidad no encontrada con ID: " + request.getIdEspecialidad()));

        // Actualizar campos
        medico.setNombres(request.getNombres());
        medico.setApellidoPaterno(request.getApellidoPaterno());
        medico.setApellidoMaterno(request.getApellidoMaterno());
        medico.setTelefono(request.getTelefono());
        medico.setEmail(request.getEmail());
        medico.setObservaciones(request.getObservaciones());
        medico.setEspecialidad(especialidad);

        medico = medicoRepository.save(medico);
        logger.info("Médico actualizado exitosamente");

        return convertirAResponse(medico);
    }

    public void eliminar(Long id) {
        logger.info("Eliminando médico con ID: " + id);

        Medico medico = medicoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Médico no encontrado con ID: " + id));

        medico.setActivo(false);
        medicoRepository.save(medico);

        logger.info("Médico eliminado (desactivado) exitosamente");
    }

    private MedicoResponse convertirAResponse(Medico medico) {
        MedicoResponse response = new MedicoResponse();
        response.setIdMedico(medico.getIdMedico());
        response.setCodigoMedico(medico.getCodigoMedico());
        response.setNumeroColegiatura(medico.getNumeroColegiatura());
        response.setNombres(medico.getNombres());
        response.setApellidoPaterno(medico.getApellidoPaterno());
        response.setApellidoMaterno(medico.getApellidoMaterno());
        response.setNombreCompleto(medico.getNombres() + " " +
                                   medico.getApellidoPaterno() + " " +
                                   medico.getApellidoMaterno());
        response.setTelefono(medico.getTelefono());
        response.setEmail(medico.getEmail());
        response.setObservaciones(medico.getObservaciones());
        response.setActivo(medico.getActivo());
        response.setFechaRegistro(medico.getFechaRegistro());

        // Convertir especialidad
        if (medico.getEspecialidad() != null) {
            response.setEspecialidad(convertirEspecialidadAResponse(medico.getEspecialidad()));
        }

        return response;
    }

    private EspecialidadResponse convertirEspecialidadAResponse(Especialidad especialidad) {
        EspecialidadResponse response = new EspecialidadResponse();
        response.setIdEspecialidad(especialidad.getIdEspecialidad());
        response.setCodigo(especialidad.getCodigo());
        response.setNombre(especialidad.getNombre());
        response.setDescripcion(especialidad.getDescripcion());
        response.setActivo(especialidad.getActivo());
        response.setFechaCreacion(especialidad.getFechaCreacion());
        return response;
    }
}
