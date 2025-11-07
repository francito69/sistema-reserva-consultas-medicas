package com.hospital.reservas.dto.response;

public class PisoResponse {
    private Long idPiso;
    private Integer numero;
    private String nombre;
    private String descripcion;

    // Constructores
    public PisoResponse() {
    }

    // Getters y Setters
    public Long getIdPiso() {
        return idPiso;
    }

    public void setIdPiso(Long idPiso) {
        this.idPiso = idPiso;
    }

    public Integer getNumero() {
        return numero;
    }

    public void setNumero(Integer numero) {
        this.numero = numero;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}
