package com.hospital.reservas.repository;

import com.hospital.reservas.entity.EstadoCita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EstadoCitaRepository extends JpaRepository<EstadoCita, Long> {
    Optional<EstadoCita> findByCodigo(String codigo);
}
