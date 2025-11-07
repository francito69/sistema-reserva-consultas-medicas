package com.hospital.reservas.dto.response;

import java.time.LocalTime;

public class HorarioAtencionResponse {

    private Long idHorario;
    private String diaSemana;
    private LocalTime horaInicio;
    private LocalTime horaFin;
    private Integer duracionCita;
    private String estado;
    private MedicoSimpleResponse medico;
    private ConsultorioResponse consultorio;
    private EspecialidadResponse especialidad;

    // Constructor
    public HorarioAtencionResponse() {
    }

    // Getters and Setters
    public Long getIdHorario() {
        return idHorario;
    }

    public void setIdHorario(Long idHorario) {
        this.idHorario = idHorario;
    }

    public String getDiaSemana() {
        return diaSemana;
    }

    public void setDiaSemana(String diaSemana) {
        this.diaSemana = diaSemana;
    }

    public LocalTime getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(LocalTime horaInicio) {
        this.horaInicio = horaInicio;
    }

    public LocalTime getHoraFin() {
        return horaFin;
    }

    public void setHoraFin(LocalTime horaFin) {
        this.horaFin = horaFin;
    }

    public Integer getDuracionCita() {
        return duracionCita;
    }

    public void setDuracionCita(Integer duracionCita) {
        this.duracionCita = duracionCita;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public MedicoSimpleResponse getMedico() {
        return medico;
    }

    public void setMedico(MedicoSimpleResponse medico) {
        this.medico = medico;
    }

    public ConsultorioResponse getConsultorio() {
        return consultorio;
    }

    public void setConsultorio(ConsultorioResponse consultorio) {
        this.consultorio = consultorio;
    }

    public EspecialidadResponse getEspecialidad() {
        return especialidad;
    }

    public void setEspecialidad(EspecialidadResponse especialidad) {
        this.especialidad = especialidad;
    }

    // Inner class para respuesta simple de médico
    public static class MedicoSimpleResponse {
        private Long idMedico;
        private String nombreCompleto;
        private String codigoMedico;

        public MedicoSimpleResponse() {
        }

        public MedicoSimpleResponse(Long idMedico, String nombreCompleto, String codigoMedico) {
            this.idMedico = idMedico;
            this.nombreCompleto = nombreCompleto;
            this.codigoMedico = codigoMedico;
        }

        public Long getIdMedico() {
            return idMedico;
        }

        public void setIdMedico(Long idMedico) {
            this.idMedico = idMedico;
        }

        public String getNombreCompleto() {
            return nombreCompleto;
        }

        public void setNombreCompleto(String nombreCompleto) {
            this.nombreCompleto = nombreCompleto;
        }

        public String getCodigoMedico() {
            return codigoMedico;
        }

        public void setCodigoMedico(String codigoMedico) {
            this.codigoMedico = codigoMedico;
        }
    }
}
