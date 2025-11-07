package com.hospital.reservas.service;

import com.hospital.reservas.dto.request.HorarioAtencionRequest;
import com.hospital.reservas.dto.response.ConsultorioResponse;
import com.hospital.reservas.dto.response.EspecialidadResponse;
import com.hospital.reservas.dto.response.HorarioAtencionResponse;
import com.hospital.reservas.dto.response.PisoResponse;
import com.hospital.reservas.entity.*;
import com.hospital.reservas.exception.ResourceNotFoundException;
import com.hospital.reservas.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class HorarioAtencionService {

    private static final Logger logger = LoggerFactory.getLogger(HorarioAtencionService.class);

    private final HorarioAtencionRepository horarioRepository;
    private final MedicoRepository medicoRepository;
    private final ConsultorioRepository consultorioRepository;
    private final EspecialidadRepository especialidadRepository;

    public HorarioAtencionService(HorarioAtencionRepository horarioRepository,
                                  MedicoRepository medicoRepository,
                                  ConsultorioRepository consultorioRepository,
                                  EspecialidadRepository especialidadRepository) {
        this.horarioRepository = horarioRepository;
        this.medicoRepository = medicoRepository;
        this.consultorioRepository = consultorioRepository;
        this.especialidadRepository = especialidadRepository;
    }

    public HorarioAtencionResponse crear(HorarioAtencionRequest request) {
        logger.info("Creando horario de atención para médico ID: {}", request.getIdMedico());

        Medico medico = medicoRepository.findById(request.getIdMedico())
                .orElseThrow(() -> new ResourceNotFoundException("Médico no encontrado con ID: " + request.getIdMedico()));

        Consultorio consultorio = consultorioRepository.findById(request.getIdConsultorio())
                .orElseThrow(() -> new ResourceNotFoundException("Consultorio no encontrado con ID: " + request.getIdConsultorio()));

        Especialidad especialidad = especialidadRepository.findById(request.getIdEspecialidad())
                .orElseThrow(() -> new ResourceNotFoundException("Especialidad no encontrada con ID: " + request.getIdEspecialidad()));

        // Validar que hora inicio sea menor que hora fin
        if (request.getHoraInicio().isAfter(request.getHoraFin()) ||
            request.getHoraInicio().equals(request.getHoraFin())) {
            throw new IllegalArgumentException("La hora de inicio debe ser menor que la hora de fin");
        }

        HorarioAtencion horario = new HorarioAtencion();
        horario.setMedico(medico);
        horario.setConsultorio(consultorio);
        horario.setEspecialidad(especialidad);
        horario.setDiaSemana(request.getDiaSemana().toUpperCase());
        horario.setHoraInicio(request.getHoraInicio());
        horario.setHoraFin(request.getHoraFin());
        horario.setDuracionCita(request.getDuracionCita() != null ? request.getDuracionCita() : 30);
        horario.setEstado("ACTIVO");

        HorarioAtencion horarioGuardado = horarioRepository.save(horario);
        logger.info("Horario de atención creado con ID: {}", horarioGuardado.getIdHorario());

        return mapToResponse(horarioGuardado);
    }

    @Transactional(readOnly = true)
    public List<HorarioAtencionResponse> listarPorMedico(Long idMedico) {
        logger.info("Listando horarios para médico ID: {}", idMedico);
        List<HorarioAtencion> horarios = horarioRepository.findByMedicoIdMedicoAndEstado(idMedico, "ACTIVO");
        return horarios.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<HorarioAtencionResponse> listarActivos() {
        logger.info("Listando todos los horarios activos");
        List<HorarioAtencion> horarios = horarioRepository.findByEstado("ACTIVO");
        return horarios.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public HorarioAtencionResponse obtenerPorId(Long id) {
        logger.info("Obteniendo horario con ID: {}", id);
        HorarioAtencion horario = horarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Horario no encontrado con ID: " + id));
        return mapToResponse(horario);
    }

    public HorarioAtencionResponse actualizar(Long id, HorarioAtencionRequest request) {
        logger.info("Actualizando horario ID: {}", id);

        HorarioAtencion horario = horarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Horario no encontrado con ID: " + id));

        if (request.getIdConsultorio() != null) {
            Consultorio consultorio = consultorioRepository.findById(request.getIdConsultorio())
                    .orElseThrow(() -> new ResourceNotFoundException("Consultorio no encontrado"));
            horario.setConsultorio(consultorio);
        }

        if (request.getDiaSemana() != null) {
            horario.setDiaSemana(request.getDiaSemana().toUpperCase());
        }

        if (request.getHoraInicio() != null) {
            horario.setHoraInicio(request.getHoraInicio());
        }

        if (request.getHoraFin() != null) {
            horario.setHoraFin(request.getHoraFin());
        }

        if (request.getDuracionCita() != null) {
            horario.setDuracionCita(request.getDuracionCita());
        }

        // Validar horas
        if (horario.getHoraInicio().isAfter(horario.getHoraFin()) ||
            horario.getHoraInicio().equals(horario.getHoraFin())) {
            throw new IllegalArgumentException("La hora de inicio debe ser menor que la hora de fin");
        }

        HorarioAtencion horarioActualizado = horarioRepository.save(horario);
        logger.info("Horario actualizado exitosamente");

        return mapToResponse(horarioActualizado);
    }

    public void eliminar(Long id) {
        logger.info("Eliminando horario ID: {}", id);
        HorarioAtencion horario = horarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Horario no encontrado con ID: " + id));

        horario.setEstado("INACTIVO");
        horarioRepository.save(horario);
        logger.info("Horario marcado como inactivo");
    }

    private HorarioAtencionResponse mapToResponse(HorarioAtencion horario) {
        HorarioAtencionResponse response = new HorarioAtencionResponse();
        response.setIdHorario(horario.getIdHorario());
        response.setDiaSemana(horario.getDiaSemana());
        response.setHoraInicio(horario.getHoraInicio());
        response.setHoraFin(horario.getHoraFin());
        response.setDuracionCita(horario.getDuracionCita());
        response.setEstado(horario.getEstado());

        // Médico
        Medico medico = horario.getMedico();
        HorarioAtencionResponse.MedicoSimpleResponse medicoResponse =
            new HorarioAtencionResponse.MedicoSimpleResponse(
                medico.getIdMedico(),
                medico.getNombres() + " " + medico.getApellidoPaterno() + " " + medico.getApellidoMaterno(),
                medico.getCodigoMedico()
            );
        response.setMedico(medicoResponse);

        // Consultorio
        Consultorio consultorio = horario.getConsultorio();
        ConsultorioResponse consultorioResponse = new ConsultorioResponse();
        consultorioResponse.setIdConsultorio(consultorio.getIdConsultorio());
        consultorioResponse.setNumero(consultorio.getNumero());
        consultorioResponse.setNombre(consultorio.getNombre());
        consultorioResponse.setActivo(consultorio.getActivo());

        if (consultorio.getPiso() != null) {
            PisoResponse pisoResponse = new PisoResponse();
            pisoResponse.setIdPiso(consultorio.getPiso().getIdPiso());
            pisoResponse.setNumero(consultorio.getPiso().getNumeroPiso());
            pisoResponse.setNombre(consultorio.getPiso().getNombre());
            consultorioResponse.setPiso(pisoResponse);
        }
        response.setConsultorio(consultorioResponse);

        // Especialidad
        Especialidad especialidad = horario.getEspecialidad();
        EspecialidadResponse especialidadResponse = new EspecialidadResponse();
        especialidadResponse.setIdEspecialidad(especialidad.getIdEspecialidad());
        especialidadResponse.setCodigo(especialidad.getCodigo());
        especialidadResponse.setNombre(especialidad.getNombre());
        especialidadResponse.setDescripcion(especialidad.getDescripcion());
        especialidadResponse.setActivo(especialidad.getActivo());
        response.setEspecialidad(especialidadResponse);

        return response;
    }
}
