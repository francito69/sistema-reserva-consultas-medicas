package com.hospital.reservas.entity;

import jakarta.persistence.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "consultorio")
@EntityListeners(AuditingEntityListener.class)
public class Consultorio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idConsultorio;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_piso", nullable = false)
    private Piso piso;

    @Column(nullable = false, length = 10)
    private String numero;

    @Column(length = 100)
    private String nombre;

    @Column(length = 200)
    private String ubicacion;

    @Column(nullable = false)
    private Integer capacidad = 1;

    @Lob
    @Column(columnDefinition = "TEXT")
    private String equipamiento;

    @Column(nullable = false)
    private Boolean activo = true;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime fechaCreacion;

    // Constructores
    public Consultorio() {
        this.capacidad = 1;
        this.activo = true;
    }

    public Consultorio(Long idConsultorio, Piso piso, String numero, String nombre,
                       String ubicacion, Integer capacidad, String equipamiento,
                       Boolean activo, LocalDateTime fechaCreacion) {
        this.idConsultorio = idConsultorio;
        this.piso = piso;
        this.numero = numero;
        this.nombre = nombre;
        this.ubicacion = ubicacion;
        this.capacidad = capacidad != null ? capacidad : 1;
        this.equipamiento = equipamiento;
        this.activo = activo != null ? activo : true;
        this.fechaCreacion = fechaCreacion;
    }

    // Getters y Setters
    public Long getIdConsultorio() {
        return idConsultorio;
    }

    public void setIdConsultorio(Long idConsultorio) {
        this.idConsultorio = idConsultorio;
    }

    public Piso getPiso() {
        return piso;
    }

    public void setPiso(Piso piso) {
        this.piso = piso;
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
}
