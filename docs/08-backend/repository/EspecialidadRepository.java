package com.hospital.reservas.repository;

import com.hospital.reservas.entity.Especialidad;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EspecialidadRepository extends JpaRepository<Especialidad, Long> {
    Optional<Especialidad> findByCodigo(String codigo);
    List<Especialidad> findByActivoTrue();
    Boolean existsByCodigo(String codigo);
    Boolean existsByNombre(String nombre);
}
