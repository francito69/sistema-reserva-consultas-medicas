package com.hospital.reservas.repository;

import com.hospital.reservas.entity.Medico;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MedicoRepository extends JpaRepository<Medico, Long> {
    Optional<Medico> findByCodigoMedico(String codigoMedico);
    Optional<Medico> findByNumeroColegiatura(String numeroColegiatura);
    List<Medico> findByActivoTrue();
    List<Medico> findByEspecialidadIdEspecialidad(Long idEspecialidad);
    List<Medico> findByEspecialidadIdEspecialidadAndActivoTrue(Long idEspecialidad);
    Boolean existsByCodigoMedico(String codigoMedico);
    Boolean existsByNumeroColegiatura(String numeroColegiatura);
    
    @Query("SELECT m FROM Medico m WHERE " +
           "LOWER(m.nombres) LIKE LOWER(CONCAT('%', :filtro, '%')) OR " +
           "LOWER(m.apellidoPaterno) LIKE LOWER(CONCAT('%', :filtro, '%')) OR " +
           "LOWER(m.apellidoMaterno) LIKE LOWER(CONCAT('%', :filtro, '%')) OR " +
           "m.codigoMedico LIKE CONCAT('%', :filtro, '%') OR " +
           "m.numeroColegiatura LIKE CONCAT('%', :filtro, '%')")
    List<Medico> buscarPorFiltro(String filtro);
}
