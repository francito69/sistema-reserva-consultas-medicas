package com.hospital.reservas.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    private String token;
    private String type = "Bearer";
    private String username;
    private String rol;
    private Long idReferencia;
    private Date expiresAt;

    public LoginResponse(String token, String username, String rol, Long idReferencia, Date expiresAt) {
        this.token = token;
        this.username = username;
        this.rol = rol;
        this.idReferencia = idReferencia;
        this.expiresAt = expiresAt;
    }
}
