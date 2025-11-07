package com.hospital.reservas.repository;

import com.hospital.reservas.entity.Piso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PisoRepository extends JpaRepository<Piso, Long> {
    Optional<Piso> findByNumeroPiso(Integer numeroPiso);
    List<Piso> findByActivoTrue();
}
