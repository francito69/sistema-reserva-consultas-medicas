package com.hospital.reservas.repository;

import com.hospital.reservas.entity.Consultorio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConsultorioRepository extends JpaRepository<Consultorio, Long> {
    List<Consultorio> findByActivoTrue();
    List<Consultorio> findByPisoIdPisoAndActivoTrue(Long idPiso);
}
