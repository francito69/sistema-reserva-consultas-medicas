package com.hospital.reservas.service;

import com.hospital.reservas.dto.request.CitaRequest;
import com.hospital.reservas.dto.response.*;
import com.hospital.reservas.entity.*;
import com.hospital.reservas.exception.ResourceNotFoundException;
import com.hospital.reservas.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Service
@Transactional
public class CitaService {

    private static final Logger logger = Logger.getLogger(CitaService.class.getName());

    private final CitaRepository citaRepository;
    private final PacienteRepository pacienteRepository;
    private final MedicoRepository medicoRepository;
    private final ConsultorioRepository consultorioRepository;
    private final EstadoCitaRepository estadoCitaRepository;

    public CitaService(CitaRepository citaRepository,
                       PacienteRepository pacienteRepository,
                       MedicoRepository medicoRepository,
                       ConsultorioRepository consultorioRepository,
                       EstadoCitaRepository estadoCitaRepository) {
        this.citaRepository = citaRepository;
        this.pacienteRepository = pacienteRepository;
        this.medicoRepository = medicoRepository;
        this.consultorioRepository = consultorioRepository;
        this.estadoCitaRepository = estadoCitaRepository;
    }

    public CitaResponse crear(CitaRequest request) {
        logger.info("Creando nueva cita para paciente: " + request.getIdPaciente());

        // Validar que existan las entidades
        Paciente paciente = pacienteRepository.findById(request.getIdPaciente())
                .orElseThrow(() -> new ResourceNotFoundException("Paciente no encontrado"));

        Medico medico = medicoRepository.findById(request.getIdMedico())
                .orElseThrow(() -> new ResourceNotFoundException("Médico no encontrado"));

        Consultorio consultorio = consultorioRepository.findById(request.getIdConsultorio())
                .orElseThrow(() -> new ResourceNotFoundException("Consultorio no encontrado"));

        // Validar fecha futura
        if (request.getFechaCita().isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("La fecha de la cita debe ser futura");
        }

        // Validar máximo 3 citas pendientes por paciente
        long citasPendientes = citaRepository.countByPacienteIdPacienteAndEstadoNombreIn(
                request.getIdPaciente(), List.of("Pendiente", "Confirmada"));

        if (citasPendientes >= 3) {
            throw new IllegalArgumentException("El paciente ya tiene 3 citas pendientes/confirmadas");
        }

        // Validar disponibilidad del médico
        boolean existeConflicto = citaRepository.existsByMedicoIdMedicoAndFechaCitaAndHoraCita(
                request.getIdMedico(), request.getFechaCita(), request.getHoraCita());

        if (existeConflicto) {
            throw new IllegalArgumentException("El médico ya tiene una cita en ese horario");
        }

        // Obtener estado PENDIENTE (ID = 1)
        EstadoCita estadoPendiente = estadoCitaRepository.findById(1L)
                .orElseThrow(() -> new ResourceNotFoundException("Estado de cita no encontrado"));

        // Crear cita
        Cita cita = new Cita();
        cita.setPaciente(paciente);
        cita.setMedico(medico);
        cita.setConsultorio(consultorio);
        cita.setEstado(estadoPendiente);
        cita.setFechaCita(request.getFechaCita());
        cita.setHoraCita(request.getHoraCita());
        cita.setMotivoConsulta(request.getMotivoConsulta());
        cita.setObservaciones(request.getObservaciones());

        cita = citaRepository.save(cita);
        logger.info("Cita creada exitosamente con ID: " + cita.getIdCita());

        return convertirAResponse(cita);
    }

    public CitaResponse obtenerPorId(Long id) {
        logger.info("Obteniendo cita con ID: " + id);
        Cita cita = citaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cita no encontrada con ID: " + id));
        return convertirAResponse(cita);
    }

    public List<CitaResponse> listarPorPaciente(Long idPaciente) {
        logger.info("Listando citas del paciente: " + idPaciente);
        return citaRepository.findByPacienteIdPacienteOrderByFechaCitaDescHoraCitaDesc(idPaciente)
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public List<CitaResponse> listarPorMedico(Long idMedico) {
        logger.info("Listando citas del médico: " + idMedico);
        return citaRepository.findByMedicoIdMedicoOrderByFechaCitaDescHoraCitaDesc(idMedico)
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public List<CitaResponse> listarPorFecha(LocalDate fecha) {
        logger.info("Listando citas para la fecha: " + fecha);
        return citaRepository.findByFechaCitaOrderByHoraCita(fecha)
                .stream()
                .map(this::convertirAResponse)
                .collect(Collectors.toList());
    }

    public CitaResponse cancelar(Long id, String motivo) {
        logger.info("Cancelando cita con ID: " + id);

        Cita cita = citaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cita no encontrada con ID: " + id));

        if (motivo == null || motivo.trim().isEmpty()) {
            throw new IllegalArgumentException("El motivo de cancelación es obligatorio");
        }

        // Validar que falten al menos 2 horas
        LocalDateTime fechaHoraCita = LocalDateTime.of(cita.getFechaCita(), cita.getHoraCita());
        if (LocalDateTime.now().plusHours(2).isAfter(fechaHoraCita)) {
            throw new IllegalArgumentException("Debe cancelar con al menos 2 horas de anticipación");
        }

        // Obtener estado CANCELADA (ID = 4)
        EstadoCita estadoCancelada = estadoCitaRepository.findById(4L)
                .orElseThrow(() -> new ResourceNotFoundException("Estado CANCELADA no encontrado"));

        cita.setEstado(estadoCancelada);
        cita.setMotivoCancelacion(motivo);
        cita.setFechaCancelacion(LocalDateTime.now());

        cita = citaRepository.save(cita);
        logger.info("Cita cancelada exitosamente");

        return convertirAResponse(cita);
    }

    public CitaResponse actualizarEstado(Long id, Long idEstado) {
        logger.info("Actualizando estado de cita: " + id + " a estado: " + idEstado);

        Cita cita = citaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cita no encontrada con ID: " + id));

        EstadoCita nuevoEstado = estadoCitaRepository.findById(idEstado)
                .orElseThrow(() -> new ResourceNotFoundException("Estado no encontrado con ID: " + idEstado));

        cita.setEstado(nuevoEstado);
        cita = citaRepository.save(cita);

        logger.info("Estado de cita actualizado exitosamente");
        return convertirAResponse(cita);
    }

    private CitaResponse convertirAResponse(Cita cita) {
        CitaResponse response = new CitaResponse();
        response.setIdCita(cita.getIdCita());
        response.setFechaCita(cita.getFechaCita());
        response.setHoraCita(cita.getHoraCita());
        response.setMotivoConsulta(cita.getMotivoConsulta());
        response.setObservaciones(cita.getObservaciones());
        response.setMotivoCancelacion(cita.getMotivoCancelacion());
        response.setFechaCancelacion(cita.getFechaCancelacion());
        response.setFechaRegistro(cita.getFechaRegistro());
        response.setFechaActualizacion(cita.getFechaActualizacion());

        // Convertir relaciones
        if (cita.getPaciente() != null) {
            response.setPaciente(convertirPacienteAResponse(cita.getPaciente()));
        }
        if (cita.getMedico() != null) {
            response.setMedico(convertirMedicoAResponse(cita.getMedico()));
        }
        if (cita.getConsultorio() != null) {
            response.setConsultorio(convertirConsultorioAResponse(cita.getConsultorio()));
        }
        if (cita.getEstado() != null) {
            response.setEstado(convertirEstadoCitaAResponse(cita.getEstado()));
        }

        return response;
    }

    private PacienteResponse convertirPacienteAResponse(Paciente paciente) {
        PacienteResponse response = new PacienteResponse();
        response.setIdPaciente(paciente.getIdPaciente());
        response.setDni(paciente.getDni());
        response.setNombres(paciente.getNombres());
        response.setApellidoPaterno(paciente.getApellidoPaterno());
        response.setApellidoMaterno(paciente.getApellidoMaterno());
        response.setNombreCompleto(paciente.getNombres() + " " +
                paciente.getApellidoPaterno() + " " +
                paciente.getApellidoMaterno());
        return response;
    }

    private MedicoResponse convertirMedicoAResponse(Medico medico) {
        MedicoResponse response = new MedicoResponse();
        response.setIdMedico(medico.getIdMedico());
        response.setCodigoMedico(medico.getCodigoMedico());
        response.setNombres(medico.getNombres());
        response.setApellidoPaterno(medico.getApellidoPaterno());
        response.setApellidoMaterno(medico.getApellidoMaterno());
        response.setNombreCompleto(medico.getNombres() + " " +
                medico.getApellidoPaterno() + " " +
                medico.getApellidoMaterno());

        if (medico.getEspecialidad() != null) {
            EspecialidadResponse especialidadResponse = new EspecialidadResponse();
            especialidadResponse.setIdEspecialidad(medico.getEspecialidad().getIdEspecialidad());
            especialidadResponse.setNombre(medico.getEspecialidad().getNombre());
            response.setEspecialidad(especialidadResponse);
        }

        return response;
    }

    private ConsultorioResponse convertirConsultorioAResponse(Consultorio consultorio) {
        ConsultorioResponse response = new ConsultorioResponse();
        response.setIdConsultorio(consultorio.getIdConsultorio());
        response.setNumero(consultorio.getNumero());
        response.setNombre(consultorio.getNombre());
        response.setUbicacion(consultorio.getUbicacion());
        return response;
    }

    private EstadoCitaResponse convertirEstadoCitaAResponse(EstadoCita estado) {
        EstadoCitaResponse response = new EstadoCitaResponse();
        response.setIdEstado(estado.getIdEstado());
        response.setCodigo(estado.getCodigo());
        response.setNombre(estado.getNombre());
        response.setDescripcion(estado.getDescripcion());
        response.setColor(estado.getColor());
        return response;
    }
}
