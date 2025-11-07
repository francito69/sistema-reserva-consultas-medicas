package com.hospital.reservas.controller;

import com.hospital.reservas.dto.request.EspecialidadRequest;
import com.hospital.reservas.dto.response.EspecialidadResponse;
import com.hospital.reservas.service.EspecialidadService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/especialidades")
@CrossOrigin(origins = "*")
public class EspecialidadController {

    private static final Logger logger = Logger.getLogger(EspecialidadController.class.getName());

    private final EspecialidadService especialidadService;

    public EspecialidadController(EspecialidadService especialidadService) {
        this.especialidadService = especialidadService;
    }

    @GetMapping
    public ResponseEntity<List<EspecialidadResponse>> listarTodas() {
        logger.info("GET /api/especialidades - Listar todas las especialidades");
        List<EspecialidadResponse> especialidades = especialidadService.listarTodas();
        return ResponseEntity.ok(especialidades);
    }

    @GetMapping("/activas")
    public ResponseEntity<List<EspecialidadResponse>> listarActivas() {
        logger.info("GET /api/especialidades/activas - Listar especialidades activas");
        List<EspecialidadResponse> especialidades = especialidadService.listarActivas();
        return ResponseEntity.ok(especialidades);
    }

    @GetMapping("/{id}")
    public ResponseEntity<EspecialidadResponse> obtenerPorId(@PathVariable Long id) {
        logger.info("GET /api/especialidades/" + id + " - Obtener especialidad por ID");
        EspecialidadResponse especialidad = especialidadService.obtenerPorId(id);
        return ResponseEntity.ok(especialidad);
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<EspecialidadResponse> obtenerPorCodigo(@PathVariable String codigo) {
        logger.info("GET /api/especialidades/codigo/" + codigo + " - Obtener especialidad por código");
        EspecialidadResponse especialidad = especialidadService.obtenerPorCodigo(codigo);
        return ResponseEntity.ok(especialidad);
    }

    @PostMapping
    public ResponseEntity<EspecialidadResponse> crear(@Valid @RequestBody EspecialidadRequest request) {
        logger.info("POST /api/especialidades - Crear nueva especialidad");
        EspecialidadResponse especialidad = especialidadService.crear(request);
        return new ResponseEntity<>(especialidad, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<EspecialidadResponse> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody EspecialidadRequest request) {
        logger.info("PUT /api/especialidades/" + id + " - Actualizar especialidad");
        EspecialidadResponse especialidad = especialidadService.actualizar(id, request);
        return ResponseEntity.ok(especialidad);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        logger.info("DELETE /api/especialidades/" + id + " - Eliminar especialidad");
        especialidadService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
