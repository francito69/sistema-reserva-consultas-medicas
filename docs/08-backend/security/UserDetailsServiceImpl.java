package com.hospital.reservas.security;

import com.hospital.reservas.entity.Usuario;
import com.hospital.reservas.repository.UsuarioRepository;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.Collections;
import java.util.logging.Logger;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private static final Logger logger = Logger.getLogger(UserDetailsServiceImpl.class.getName());

    private final UsuarioRepository usuarioRepository;

    public UserDetailsServiceImpl(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        logger.info("Cargando usuario: " + username);

        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException(
                        "Usuario no encontrado con username: " + username));

        if (!usuario.getActivo()) {
            throw new UsernameNotFoundException("Usuario inactivo: " + username);
        }

        // DEBUG: Mostrar información del hash de la BD
        String hash = usuario.getPasswordHash();
        logger.info("=== DEBUG PASSWORD HASH ===");
        logger.info("Hash de BD - Longitud: " + (hash != null ? hash.length() : "null"));
        logger.info("Hash de BD - Primeros 20 chars: " + (hash != null && hash.length() >= 20 ? hash.substring(0, 20) : hash));
        logger.info("Hash de BD - Últimos 20 chars: " + (hash != null && hash.length() >= 20 ? hash.substring(hash.length() - 20) : hash));
        logger.info("Hash esperado para admin123: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy");
        logger.info("¿Son iguales?: " + "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy".equals(hash));
        logger.info("===========================");

        return new org.springframework.security.core.userdetails.User(
                usuario.getUsername(),
                usuario.getPasswordHash(),
                usuario.getActivo(),
                true, // accountNonExpired
                true, // credentialsNonExpired
                true, // accountNonLocked
                getAuthorities(usuario)
        );
    }

    /**
     * Obtiene las autoridades (roles) del usuario
     */
    private Collection<? extends GrantedAuthority> getAuthorities(Usuario usuario) {
        // El rol ya viene en formato "PACIENTE", "MEDICO", "ADMIN"
        // Spring Security requiere el prefijo "ROLE_" para hasRole()
        String role = "ROLE_" + usuario.getRol();
        logger.info("Usuario " + usuario.getUsername() + " tiene rol: " + role);
        return Collections.singletonList(new SimpleGrantedAuthority(role));
    }
}
