package com.hospital.reservas.repository;

import com.hospital.reservas.entity.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificacionRepository extends JpaRepository<Notificacion, Long> {
    List<Notificacion> findByEnviadoFalse();
    List<Notificacion> findByCitaIdCita(Long idCita);
}
