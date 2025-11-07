package com.hospital.reservas.controller;

import com.hospital.reservas.dto.request.CitaRequest;
import com.hospital.reservas.dto.response.CitaResponse;
import com.hospital.reservas.service.CitaService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/citas")
@CrossOrigin(origins = "*")
public class CitaController {

    private static final Logger logger = Logger.getLogger(CitaController.class.getName());

    private final CitaService citaService;

    public CitaController(CitaService citaService) {
        this.citaService = citaService;
    }

    @PostMapping
    public ResponseEntity<CitaResponse> crear(@Valid @RequestBody CitaRequest request) {
        logger.info("POST /api/citas - Crear nueva cita");
        CitaResponse cita = citaService.crear(request);
        return new ResponseEntity<>(cita, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CitaResponse> obtenerPorId(@PathVariable Long id) {
        logger.info("GET /api/citas/" + id + " - Obtener cita por ID");
        CitaResponse cita = citaService.obtenerPorId(id);
        return ResponseEntity.ok(cita);
    }

    @GetMapping("/paciente/{idPaciente}")
    public ResponseEntity<List<CitaResponse>> listarPorPaciente(@PathVariable Long idPaciente) {
        logger.info("GET /api/citas/paciente/" + idPaciente + " - Listar citas por paciente");
        List<CitaResponse> citas = citaService.listarPorPaciente(idPaciente);
        return ResponseEntity.ok(citas);
    }

    @GetMapping("/medico/{idMedico}")
    public ResponseEntity<List<CitaResponse>> listarPorMedico(@PathVariable Long idMedico) {
        logger.info("GET /api/citas/medico/" + idMedico + " - Listar citas por médico");
        List<CitaResponse> citas = citaService.listarPorMedico(idMedico);
        return ResponseEntity.ok(citas);
    }

    @GetMapping("/fecha/{fecha}")
    public ResponseEntity<List<CitaResponse>> listarPorFecha(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
        logger.info("GET /api/citas/fecha/" + fecha + " - Listar citas por fecha");
        List<CitaResponse> citas = citaService.listarPorFecha(fecha);
        return ResponseEntity.ok(citas);
    }

    @PutMapping("/{id}/cancelar")
    public ResponseEntity<CitaResponse> cancelar(
            @PathVariable Long id,
            @RequestBody Map<String, String> payload) {
        logger.info("PUT /api/citas/" + id + "/cancelar - Cancelar cita");

        String motivo = payload.get("motivo");
        CitaResponse cita = citaService.cancelar(id, motivo);
        return ResponseEntity.ok(cita);
    }

    @PutMapping("/{id}/estado")
    public ResponseEntity<CitaResponse> actualizarEstado(
            @PathVariable Long id,
            @RequestBody Map<String, Long> payload) {
        logger.info("PUT /api/citas/" + id + "/estado - Actualizar estado de cita");

        Long idEstado = payload.get("idEstado");
        CitaResponse cita = citaService.actualizarEstado(id, idEstado);
        return ResponseEntity.ok(cita);
    }
}
