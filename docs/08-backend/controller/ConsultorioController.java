package com.hospital.reservas.controller;

import com.hospital.reservas.dto.response.ConsultorioResponse;
import com.hospital.reservas.service.ConsultorioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/consultorios")
@CrossOrigin(origins = "*")
public class ConsultorioController {

    private static final Logger logger = Logger.getLogger(ConsultorioController.class.getName());

    private final ConsultorioService consultorioService;

    public ConsultorioController(ConsultorioService consultorioService) {
        this.consultorioService = consultorioService;
    }

    @GetMapping
    public ResponseEntity<List<ConsultorioResponse>> listarTodos() {
        logger.info("GET /api/consultorios - Listar todos los consultorios");
        List<ConsultorioResponse> consultorios = consultorioService.listarTodos();
        return ResponseEntity.ok(consultorios);
    }

    @GetMapping("/activos")
    public ResponseEntity<List<ConsultorioResponse>> listarActivos() {
        logger.info("GET /api/consultorios/activos - Listar consultorios activos");
        List<ConsultorioResponse> consultorios = consultorioService.listarActivos();
        return ResponseEntity.ok(consultorios);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ConsultorioResponse> obtenerPorId(@PathVariable Long id) {
        logger.info("GET /api/consultorios/" + id + " - Obtener consultorio por ID");
        ConsultorioResponse consultorio = consultorioService.obtenerPorId(id);
        return ResponseEntity.ok(consultorio);
    }
}
