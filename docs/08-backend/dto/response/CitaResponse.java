package com.hospital.reservas.dto.response;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class CitaResponse {
    private Long idCita;
    private LocalDate fechaCita;
    private LocalTime horaCita;
    private String motivoConsulta;
    private String observaciones;
    private String motivoCancelacion;
    private LocalDateTime fechaCancelacion;
    private LocalDateTime fechaRegistro;
    private LocalDateTime fechaActualizacion;

    private PacienteResponse paciente;
    private MedicoResponse medico;
    private ConsultorioResponse consultorio;
    private EstadoCitaResponse estado;

    // Constructores
    public CitaResponse() {
    }

    // Getters y Setters
    public Long getIdCita() {
        return idCita;
    }

    public void setIdCita(Long idCita) {
        this.idCita = idCita;
    }

    public LocalDate getFechaCita() {
        return fechaCita;
    }

    public void setFechaCita(LocalDate fechaCita) {
        this.fechaCita = fechaCita;
    }

    public LocalTime getHoraCita() {
        return horaCita;
    }

    public void setHoraCita(LocalTime horaCita) {
        this.horaCita = horaCita;
    }

    public String getMotivoConsulta() {
        return motivoConsulta;
    }

    public void setMotivoConsulta(String motivoConsulta) {
        this.motivoConsulta = motivoConsulta;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public String getMotivoCancelacion() {
        return motivoCancelacion;
    }

    public void setMotivoCancelacion(String motivoCancelacion) {
        this.motivoCancelacion = motivoCancelacion;
    }

    public LocalDateTime getFechaCancelacion() {
        return fechaCancelacion;
    }

    public void setFechaCancelacion(LocalDateTime fechaCancelacion) {
        this.fechaCancelacion = fechaCancelacion;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public LocalDateTime getFechaActualizacion() {
        return fechaActualizacion;
    }

    public void setFechaActualizacion(LocalDateTime fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }

    public PacienteResponse getPaciente() {
        return paciente;
    }

    public void setPaciente(PacienteResponse paciente) {
        this.paciente = paciente;
    }

    public MedicoResponse getMedico() {
        return medico;
    }

    public void setMedico(MedicoResponse medico) {
        this.medico = medico;
    }

    public ConsultorioResponse getConsultorio() {
        return consultorio;
    }

    public void setConsultorio(ConsultorioResponse consultorio) {
        this.consultorio = consultorio;
    }

    public EstadoCitaResponse getEstado() {
        return estado;
    }

    public void setEstado(EstadoCitaResponse estado) {
        this.estado = estado;
    }
}
