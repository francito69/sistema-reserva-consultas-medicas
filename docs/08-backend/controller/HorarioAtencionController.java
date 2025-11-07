package com.hospital.reservas.controller;

import com.hospital.reservas.dto.request.HorarioAtencionRequest;
import com.hospital.reservas.dto.response.HorarioAtencionResponse;
import com.hospital.reservas.service.HorarioAtencionService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/horarios")
@CrossOrigin(origins = "*")
public class HorarioAtencionController {

    private static final Logger logger = LoggerFactory.getLogger(HorarioAtencionController.class);
    private final HorarioAtencionService horarioService;

    public HorarioAtencionController(HorarioAtencionService horarioService) {
        this.horarioService = horarioService;
    }

    @PostMapping("/")
    public ResponseEntity<HorarioAtencionResponse> crear(@Valid @RequestBody HorarioAtencionRequest request) {
        logger.info("POST /api/horarios/ - Crear horario de atención");
        HorarioAtencionResponse response = horarioService.crear(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping("/")
    public ResponseEntity<List<HorarioAtencionResponse>> listarTodos() {
        logger.info("GET /api/horarios/ - Listar todos los horarios");
        List<HorarioAtencionResponse> horarios = horarioService.listarActivos();
        return ResponseEntity.ok(horarios);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HorarioAtencionResponse> obtenerPorId(@PathVariable Long id) {
        logger.info("GET /api/horarios/{} - Obtener horario por ID", id);
        HorarioAtencionResponse response = horarioService.obtenerPorId(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/medico/{idMedico}")
    public ResponseEntity<List<HorarioAtencionResponse>> listarPorMedico(@PathVariable Long idMedico) {
        logger.info("GET /api/horarios/medico/{} - Listar horarios por médico", idMedico);
        List<HorarioAtencionResponse> horarios = horarioService.listarPorMedico(idMedico);
        return ResponseEntity.ok(horarios);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HorarioAtencionResponse> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody HorarioAtencionRequest request) {
        logger.info("PUT /api/horarios/{} - Actualizar horario", id);
        HorarioAtencionResponse response = horarioService.actualizar(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        logger.info("DELETE /api/horarios/{} - Eliminar horario", id);
        horarioService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
