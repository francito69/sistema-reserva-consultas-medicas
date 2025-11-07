package com.hospital.reservas.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "piso")
public class Piso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idPiso;

    @Column(nullable = false, unique = true)
    private Integer numeroPiso;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(length = 500)
    private String descripcion;

    @Column(nullable = false)
    private Boolean activo = true;

    // Constructores
    public Piso() {
        this.activo = true;
    }

    public Piso(Long idPiso, Integer numeroPiso, String nombre, String descripcion, Boolean activo) {
        this.idPiso = idPiso;
        this.numeroPiso = numeroPiso;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.activo = activo != null ? activo : true;
    }

    // Getters y Setters
    public Long getIdPiso() {
        return idPiso;
    }

    public void setIdPiso(Long idPiso) {
        this.idPiso = idPiso;
    }

    public Integer getNumeroPiso() {
        return numeroPiso;
    }

    public void setNumeroPiso(Integer numeroPiso) {
        this.numeroPiso = numeroPiso;
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

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }
}
