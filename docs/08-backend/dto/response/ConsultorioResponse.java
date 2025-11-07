package com.hospital.reservas.dto.response;

import java.time.LocalDateTime;

public class ConsultorioResponse {
    private Long idConsultorio;
    private String numero;
    private String nombre;
    private String ubicacion;
    private Integer capacidad;
    private String equipamiento;
    private Boolean activo;
    private LocalDateTime fechaCreacion;
    private PisoResponse piso;

    // Constructores
    public ConsultorioResponse() {
    }

    // Getters y Setters
    public Long getIdConsultorio() {
        return idConsultorio;
    }

    public void setIdConsultorio(Long idConsultorio) {
        this.idConsultorio = idConsultorio;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
    }

    public Integer getCapacidad() {
        return capacidad;
    }

    public void setCapacidad(Integer capacidad) {
        this.capacidad = capacidad;
    }

    public String getEquipamiento() {
        return equipamiento;
    }

    public void setEquipamiento(String equipamiento) {
        this.equipamiento = equipamiento;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public PisoResponse getPiso() {
        return piso;
    }

    public void setPiso(PisoResponse piso) {
        this.piso = piso;
    }
}
