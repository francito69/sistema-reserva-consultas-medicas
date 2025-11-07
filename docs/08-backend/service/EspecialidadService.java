package com.hospital.reservas.service;

import com.hospital.reservas.dto.request.EspecialidadRequest;
import com.hospital.reservas.dto.response.EspecialidadResponse;
import com.hospital.reservas.entity.Especialidad;
import com.hospital.reservas.exception.ResourceNotFoundException;
import com.hospital.reservas.repository.EspecialidadRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Service
@Transactional
public class EspecialidadService {

    private static final Logger logger = Logger.getLogger(EspecialidadService.class.getName());

    private final EspecialidadRepository especialidadRepository;

    public EspecialidadService(EspecialidadRepository especialidadRepository) {
        this.especialidadRepository = especialidadRepository;
    }

    public List<EspecialidadResponse> listarTodas() {
        logger.info("Listando todas las especialidades");
        return especialidadRepository.findAll()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public List<EspecialidadResponse> listarActivas() {
        logger.info("Listando especialidades activas");
        return especialidadRepository.findByActivoTrue()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public EspecialidadResponse obtenerPorId(Long id) {
        logger.info("Obteniendo especialidad con ID: " + id);
        Especialidad especialidad = especialidadRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Especialidad no encontrada con ID: " + id));
        return convertirAResponse(especialidad);
    }

    public EspecialidadResponse obtenerPorCodigo(String codigo) {
        logger.info("Obteniendo especialidad con código: " + codigo);
        Especialidad especialidad = especialidadRepository.findByCodigo(codigo)
                .orElseThrow(() -> new ResourceNotFoundException("Especialidad no encontrada con código: " + codigo));
        return convertirAResponse(especialidad);
    }

    public EspecialidadResponse crear(EspecialidadRequest request) {
        logger.info("Creando nueva especialidad: " + request.getCodigo());

        // Validar que no exista
        if (especialidadRepository.existsByCodigo(request.getCodigo())) {
            throw new IllegalArgumentException("Ya existe una especialidad con código: " + request.getCodigo());
        }
        if (especialidadRepository.existsByNombre(request.getNombre())) {
            throw new IllegalArgumentException("Ya existe una especialidad con nombre: " + request.getNombre());
        }

        Especialidad especialidad = new Especialidad();
        especialidad.setCodigo(request.getCodigo());
        especialidad.setNombre(request.getNombre());
        especialidad.setDescripcion(request.getDescripcion());
        especialidad.setActivo(true);

        especialidad = especialidadRepository.save(especialidad);
        logger.info("Especialidad creada exitosamente con ID: " + especialidad.getIdEspecialidad());

        return convertirAResponse(especialidad);
    }

    public EspecialidadResponse actualizar(Long id, EspecialidadRequest request) {
        logger.info("Actualizando especialidad con ID: " + id);

        Especialidad especialidad = especialidadRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Especialidad no encontrada con ID: " + id));

        especialidad.setNombre(request.getNombre());
        especialidad.setDescripcion(request.getDescripcion());

        especialidad = especialidadRepository.save(especialidad);
        logger.info("Especialidad actualizada exitosamente");

        return convertirAResponse(especialidad);
    }

    public void eliminar(Long id) {
        logger.info("Eliminando especialidad con ID: " + id);

        Especialidad especialidad = especialidadRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Especialidad no encontrada con ID: " + id));

        especialidad.setActivo(false);
        especialidadRepository.save(especialidad);

        logger.info("Especialidad eliminada (desactivada) exitosamente");
    }

    private EspecialidadResponse convertirAResponse(Especialidad especialidad) {
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
