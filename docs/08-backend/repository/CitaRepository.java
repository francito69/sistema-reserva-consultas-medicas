package com.hospital.reservas.repository;

import com.hospital.reservas.entity.Cita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface CitaRepository extends JpaRepository<Cita, Long> {

    List<Cita> findByPacienteIdPacienteOrderByFechaCitaDescHoraCitaDesc(Long idPaciente);

    List<Cita> findByMedicoIdMedicoOrderByFechaCitaDescHoraCitaDesc(Long idMedico);

    List<Cita> findByFechaCitaOrderByHoraCita(LocalDate fecha);

    @Query("SELECT COUNT(c) FROM Cita c WHERE " +
           "c.paciente.idPaciente = :idPaciente AND " +
           "c.estado.nombre IN :estados")
    Long countByPacienteIdPacienteAndEstadoNombreIn(
            @Param("idPaciente") Long idPaciente,
            @Param("estados") List<String> estados);

    Boolean existsByMedicoIdMedicoAndFechaCitaAndHoraCita(
            Long idMedico,
            LocalDate fechaCita,
            LocalTime horaCita);

    @Query("SELECT c FROM Cita c WHERE " +
           "c.fechaCita >= :fechaInicio AND " +
           "c.fechaCita <= :fechaFin")
    List<Cita> buscarPorRangoFechas(
            @Param("fechaInicio") LocalDate fechaInicio,
            @Param("fechaFin") LocalDate fechaFin);
}
