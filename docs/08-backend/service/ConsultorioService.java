package com.hospital.reservas.service;

import com.hospital.reservas.dto.response.ConsultorioResponse;
import com.hospital.reservas.dto.response.PisoResponse;
import com.hospital.reservas.entity.Consultorio;
import com.hospital.reservas.exception.ResourceNotFoundException;
import com.hospital.reservas.repository.ConsultorioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Service
@Transactional
public class ConsultorioService {

    private static final Logger logger = Logger.getLogger(ConsultorioService.class.getName());

    private final ConsultorioRepository consultorioRepository;

    public ConsultorioService(ConsultorioRepository consultorioRepository) {
        this.consultorioRepository = consultorioRepository;
    }

    public List<ConsultorioResponse> listarTodos() {
        logger.info("Listando todos los consultorios");
        return consultorioRepository.findAll()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public List<ConsultorioResponse> listarActivos() {
        logger.info("Listando consultorios activos");
        return consultorioRepository.findByActivoTrue()
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public ConsultorioResponse obtenerPorId(Long id) {
        logger.info("Obteniendo consultorio con ID: " + id);
        Consultorio consultorio = consultorioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Consultorio no encontrado con ID: " + id));
        return convertirAResponse(consultorio);
    }

    private ConsultorioResponse convertirAResponse(Consultorio consultorio) {
        ConsultorioResponse response = new ConsultorioResponse();
        response.setIdConsultorio(consultorio.getIdConsultorio());
        response.setNumero(consultorio.getNumero());
        response.setNombre(consultorio.getNombre());
        response.setUbicacion(consultorio.getUbicacion());
        response.setCapacidad(consultorio.getCapacidad());
        response.setEquipamiento(consultorio.getEquipamiento());
        response.setActivo(consultorio.getActivo());
        response.setFechaCreacion(consultorio.getFechaCreacion());

        if (consultorio.getPiso() != null) {
            PisoResponse pisoResponse = new PisoResponse();
            pisoResponse.setIdPiso(consultorio.getPiso().getIdPiso());
            pisoResponse.setNumero(consultorio.getPiso().getNumeroPiso());
            pisoResponse.setNombre(consultorio.getPiso().getNombre());
            pisoResponse.setDescripcion(consultorio.getPiso().getDescripcion());
            response.setPiso(pisoResponse);
        }

        return response;
    }
}
