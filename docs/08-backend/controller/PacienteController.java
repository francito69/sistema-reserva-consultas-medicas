package com.hospital.reservas.controller;

import com.hospital.reservas.dto.request.PacienteRequest;
import com.hospital.reservas.dto.response.PacienteResponse;
import com.hospital.reservas.service.PacienteService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/pacientes")
@CrossOrigin(origins = "*")
public class PacienteController {

    private static final Logger logger = Logger.getLogger(PacienteController.class.getName());

    private final PacienteService pacienteService;

    public PacienteController(PacienteService pacienteService) {
        this.pacienteService = pacienteService;
    }

    @GetMapping
    public ResponseEntity<List<PacienteResponse>> listarTodos() {
        logger.info("GET /api/pacientes - Listar todos los pacientes");
        List<PacienteResponse> pacientes = pacienteService.listarTodos();
        return ResponseEntity.ok(pacientes);
    }

    @GetMapping("/activos")
    public ResponseEntity<List<PacienteResponse>> listarActivos() {
        logger.info("GET /api/pacientes/activos - Listar pacientes activos");
        List<PacienteResponse> pacientes = pacienteService.listarActivos();
        return ResponseEntity.ok(pacientes);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PacienteResponse> obtenerPorId(@PathVariable Long id) {
        logger.info("GET /api/pacientes/" + id + " - Obtener paciente por ID");
        PacienteResponse paciente = pacienteService.obtenerPorId(id);
        return ResponseEntity.ok(paciente);
    }

    @GetMapping("/dni/{dni}")
    public ResponseEntity<PacienteResponse> obtenerPorDni(@PathVariable String dni) {
        logger.info("GET /api/pacientes/dni/" + dni + " - Obtener paciente por DNI");
        PacienteResponse paciente = pacienteService.obtenerPorDni(dni);
        return ResponseEntity.ok(paciente);
    }

    @PostMapping
    public ResponseEntity<PacienteResponse> crear(@Valid @RequestBody PacienteRequest request) {
        logger.info("POST /api/pacientes - Crear nuevo paciente");
        PacienteResponse paciente = pacienteService.crear(request);
        return new ResponseEntity<>(paciente, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PacienteResponse> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody PacienteRequest request) {
        logger.info("PUT /api/pacientes/" + id + " - Actualizar paciente");
        PacienteResponse paciente = pacienteService.actualizar(id, request);
        return ResponseEntity.ok(paciente);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        logger.info("DELETE /api/pacientes/" + id + " - Eliminar paciente");
        pacienteService.eliminar(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/buscar")
    public ResponseEntity<List<PacienteResponse>> buscar(@RequestParam String filtro) {
        logger.info("GET /api/pacientes/buscar?filtro=" + filtro);
        List<PacienteResponse> pacientes = pacienteService.buscar(filtro);
        return ResponseEntity.ok(pacientes);
    }
}
