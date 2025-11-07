package com.hospital.reservas.repository;

import com.hospital.reservas.entity.HorarioAtencion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HorarioAtencionRepository extends JpaRepository<HorarioAtencion, Long> {
    List<HorarioAtencion> findByMedicoIdMedicoAndEstado(Long idMedico, String estado);
    List<HorarioAtencion> findByDiaSemanaAndEstado(String diaSemana, String estado);
    List<HorarioAtencion> findByConsultorioIdConsultorioAndEstado(Long idConsultorio, String estado);
    List<HorarioAtencion> findByEstado(String estado);

    @Query("SELECT h FROM HorarioAtencion h WHERE " +
           "h.medico.idMedico = :idMedico AND " +
           "h.diaSemana = :diaSemana AND " +
           "h.estado = 'ACTIVO'")
    List<HorarioAtencion> buscarPorMedicoYDia(Long idMedico, String diaSemana);
}
