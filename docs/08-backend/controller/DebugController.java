package com.hospital.reservas.controller;

import com.hospital.reservas.entity.Usuario;
import com.hospital.reservas.repository.UsuarioRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/debug")
@CrossOrigin(origins = "*")
public class DebugController {

    private final UsuarioRepository usuarioRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    public DebugController(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    /**
     * Endpoint temporal para debugging del hash de contraseña
     * GET /api/debug/check-password?username=admin&password=admin123
     */
    @GetMapping("/check-password")
    public Map<String, Object> checkPassword(
            @RequestParam String username,
            @RequestParam String password
    ) {
        Map<String, Object> response = new HashMap<>();

        // Buscar usuario en BD
        Usuario usuario = usuarioRepository.findByUsername(username).orElse(null);

        if (usuario == null) {
            response.put("error", "Usuario no encontrado");
            return response;
        }

        String hashFromDB = usuario.getPasswordHash();
        String hashEsperado = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy";

        // Información del usuario
        response.put("username", usuario.getUsername());
        response.put("rol", usuario.getRol());
        response.put("activo", usuario.getActivo());

        // Información del hash de la BD
        response.put("hash_bd_longitud", hashFromDB != null ? hashFromDB.length() : 0);
        response.put("hash_bd_primeros_20", hashFromDB != null && hashFromDB.length() >= 20 ? hashFromDB.substring(0, 20) : hashFromDB);
        response.put("hash_bd_ultimos_20", hashFromDB != null && hashFromDB.length() >= 20 ? hashFromDB.substring(hashFromDB.length() - 20) : hashFromDB);
        response.put("hash_bd_completo", hashFromDB);

        // Información del hash esperado
        response.put("hash_esperado", hashEsperado);

        // Comparación exacta
        response.put("hashes_son_identicos", hashEsperado.equals(hashFromDB));

        // Información de la contraseña probada
        response.put("password_probada", password);
        response.put("password_longitud", password.length());

        // Prueba de BCrypt
        boolean matchesWithDB = passwordEncoder.matches(password, hashFromDB);
        boolean matchesWithExpected = passwordEncoder.matches(password, hashEsperado);

        response.put("bcrypt_matches_con_hash_bd", matchesWithDB);
        response.put("bcrypt_matches_con_hash_esperado", matchesWithExpected);

        // Diagnóstico
        if (matchesWithDB && matchesWithExpected) {
            response.put("diagnostico", "✓ TODO CORRECTO - El login debería funcionar");
        } else if (!matchesWithDB && matchesWithExpected) {
            response.put("diagnostico", "✗ HASH DE BD INCORRECTO - Actualiza el hash en Supabase");
        } else if (matchesWithDB && !matchesWithExpected) {
            response.put("diagnostico", "⚠ HASH ESPERADO INCORRECTO - El hash de BD es correcto pero no coincide con admin123");
        } else {
            response.put("diagnostico", "✗ CONTRASEÑA INCORRECTA - Ni el hash de BD ni el esperado coinciden con la contraseña proporcionada");
        }

        // Generar nuevo hash para la contraseña
        String nuevoHash = passwordEncoder.encode(password);
        response.put("nuevo_hash_generado", nuevoHash);
        response.put("nuevo_hash_valida_correctamente", passwordEncoder.matches(password, nuevoHash));

        return response;
    }

    /**
     * Endpoint para generar un hash BCrypt para cualquier contraseña
     * GET /api/debug/generate-hash?password=admin123
     */
    @GetMapping("/generate-hash")
    public Map<String, Object> generateHash(@RequestParam String password) {
        Map<String, Object> response = new HashMap<>();

        String hash = passwordEncoder.encode(password);

        response.put("password", password);
        response.put("hash_generado", hash);
        response.put("longitud", hash.length());
        response.put("valida_correctamente", passwordEncoder.matches(password, hash));

        response.put("sql_update", "UPDATE usuario SET password_hash = '" + hash + "' WHERE username = 'admin';");

        return response;
    }
}
