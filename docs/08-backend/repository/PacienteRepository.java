package com.hospital.reservas.repository;

import com.hospital.reservas.entity.Paciente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PacienteRepository extends JpaRepository<Paciente, Long> {
    Optional<Paciente> findByDni(String dni);
    Optional<Paciente> findByEmail(String email);
    List<Paciente> findByActivoTrue();
    Boolean existsByDni(String dni);
    Boolean existsByEmail(String email);
    
    @Query("SELECT p FROM Paciente p WHERE " +
           "LOWER(p.nombres) LIKE LOWER(CONCAT('%', :filtro, '%')) OR " +
           "LOWER(p.apellidoPaterno) LIKE LOWER(CONCAT('%', :filtro, '%')) OR " +
           "LOWER(p.apellidoMaterno) LIKE LOWER(CONCAT('%', :filtro, '%')) OR " +
           "p.dni LIKE CONCAT('%', :filtro, '%')")
    List<Paciente> buscarPorFiltro(String filtro);
}
