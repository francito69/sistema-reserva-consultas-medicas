package com.hospital.reservas.controller;

import com.hospital.reservas.dto.request.MedicoRequest;
import com.hospital.reservas.dto.response.MedicoResponse;
import com.hospital.reservas.service.MedicoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/medicos")
@CrossOrigin(origins = "*")
public class MedicoController {

    private static final Logger logger = Logger.getLogger(MedicoController.class.getName());

    private final MedicoService medicoService;

    public MedicoController(MedicoService medicoService) {
        this.medicoService = medicoService;
    }

    @GetMapping
    public ResponseEntity<List<MedicoResponse>> listarTodos() {
        logger.info("GET /api/medicos - Listar todos los médicos");
        List<MedicoResponse> medicos = medicoService.listarTodos();
        return ResponseEntity.ok(medicos);
    }

    @GetMapping("/activos")
    public ResponseEntity<List<MedicoResponse>> listarActivos() {
        logger.info("GET /api/medicos/activos - Listar médicos activos");
        List<MedicoResponse> medicos = medicoService.listarActivos();
        return ResponseEntity.ok(medicos);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MedicoResponse> obtenerPorId(@PathVariable Long id) {
        logger.info("GET /api/medicos/" + id + " - Obtener médico por ID");
        MedicoResponse medico = medicoService.obtenerPorId(id);
        return ResponseEntity.ok(medico);
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<MedicoResponse> obtenerPorCodigo(@PathVariable String codigo) {
        logger.info("GET /api/medicos/codigo/" + codigo + " - Obtener médico por código");
        MedicoResponse medico = medicoService.obtenerPorCodigo(codigo);
        return ResponseEntity.ok(medico);
    }

    @GetMapping("/especialidad/{idEspecialidad}")
    public ResponseEntity<List<MedicoResponse>> buscarPorEspecialidad(@PathVariable Long idEspecialidad) {
        logger.info("GET /api/medicos/especialidad/" + idEspecialidad + " - Buscar médicos por especialidad");
        List<MedicoResponse> medicos = medicoService.buscarPorEspecialidad(idEspecialidad);
        return ResponseEntity.ok(medicos);
    }

    @PostMapping
    public ResponseEntity<MedicoResponse> crear(@Valid @RequestBody MedicoRequest request) {
        logger.info("POST /api/medicos - Crear nuevo médico");
        MedicoResponse medico = medicoService.crear(request);
        return new ResponseEntity<>(medico, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<MedicoResponse> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody MedicoRequest request) {
        logger.info("PUT /api/medicos/" + id + " - Actualizar médico");
        MedicoResponse medico = medicoService.actualizar(id, request);
        return ResponseEntity.ok(medico);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        logger.info("DELETE /api/medicos/" + id + " - Eliminar médico");
        medicoService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
