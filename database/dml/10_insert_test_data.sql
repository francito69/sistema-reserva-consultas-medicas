-- ============================================
-- Script: 10_insert_test_data.sql
-- Descripción: Insertar datos de prueba
-- Autor: [francito69]
-- Fecha: 2025-10-30
-- ============================================

BEGIN;

-- ===========================================
-- 1. INSERTAR USUARIOS
-- ===========================================

-- Usuarios Administrador
INSERT INTO usuario (nombre_usuario, contraseña, email, rol, estado) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@hospital.com', 'ADMIN', 'ACTIVO');
-- Contraseña: admin123

-- Usuarios Médicos
INSERT INTO usuario (nombre_usuario, contraseña, email, rol, estado) VALUES
('dr.garcia', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'garcia@hospital.com', 'MEDICO', 'ACTIVO'),
('dr.lopez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'lopez@hospital.com', 'MEDICO', 'ACTIVO'),
('dr.martinez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'martinez@hospital.com', 'MEDICO', 'ACTIVO'),
('dra.fernandez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'fernandez@hospital.com', 'MEDICO', 'ACTIVO');

-- Usuarios Pacientes
INSERT INTO usuario (nombre_usuario, contraseña, email, rol, estado) VALUES
('jperes', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'juan.perez@email.com', 'PACIENTE', 'ACTIVO'),
('mrodriguez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'maria.rodriguez@email.com', 'PACIENTE', 'ACTIVO'),
('cgonzalez', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'carlos.gonzalez@email.com', 'PACIENTE', 'ACTIVO'),
('asilva', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ana.silva@email.com', 'PACIENTE', 'ACTIVO'),
('ltorres', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'luis.torres@email.com', 'PACIENTE', 'ACTIVO');

-- ===========================================
-- 2. INSERTAR MÉDICOS
-- ===========================================

INSERT INTO medico (dni, nombres, apellido_paterno, apellido_materno, numero_colegiatura, email, telefono, id_usuario) VALUES
('45678901', 'Roberto Carlos', 'García', 'Mendoza', 'CMP-12345', 'garcia@hospital.com', '987654321', 2),
('45678902', 'Patricia Elena', 'López', 'Vargas', 'CMP-12346', 'lopez@hospital.com', '987654322', 3),
('45678903', 'Miguel Ángel', 'Martínez', 'Ramos', 'CMP-12347', 'martinez@hospital.com', '987654323', 4),
('45678904', 'Carmen Rosa', 'Fernández', 'Castro', 'CMP-12348', 'fernandez@hospital.com', '987654324', 5);

-- ===========================================
-- 3. ASIGNAR ESPECIALIDADES A MÉDICOS
-- ===========================================

-- Dr. García - Cardiología y Medicina General
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(1, 1, '2020-03-15', 'Colegio Médico del Perú'),
(1, 5, '2018-06-20', 'Universidad Nacional Mayor de San Marcos');

-- Dra. López - Pediatría
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(2, 2, '2019-08-10', 'Instituto Nacional de Salud del Niño');

-- Dr. Martínez - Traumatología
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(3, 4, '2021-01-25', 'Hospital Nacional Dos de Mayo');

-- Dra. Fernández - Ginecología y Medicina General
INSERT INTO medico_especialidad (id_medico, id_especialidad, fecha_certificacion, institucion_certificadora) VALUES
(4, 6, '2020-11-30', 'Instituto Nacional Materno Perinatal'),
(4, 5, '2017-05-15', 'Universidad Peruana Cayetano Heredia');

-- ===========================================
-- 4. INSERTAR HORARIOS DE ATENCIÓN
-- ===========================================

-- Dr. García - Cardiología (Lunes, Miércoles, Viernes)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(1, 1, 1, 'LUNES', '08:00', '13:00', 30),
(1, 1, 1, 'MIERCOLES', '08:00', '13:00', 30),
(1, 1, 1, 'VIERNES', '08:00', '13:00', 30);

-- Dr. García - Medicina General (Martes, Jueves)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(1, 3, 5, 'MARTES', '14:00', '18:00', 20),
(1, 3, 5, 'JUEVES', '14:00', '18:00', 20);

-- Dra. López - Pediatría (Lunes a Viernes por la mañana)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(2, 2, 2, 'LUNES', '09:00', '13:00', 25),
(2, 2, 2, 'MARTES', '09:00', '13:00', 25),
(2, 2, 2, 'MIERCOLES', '09:00', '13:00', 25),
(2, 2, 2, 'JUEVES', '09:00', '13:00', 25),
(2, 2, 2, 'VIERNES', '09:00', '13:00', 25);

-- Dr. Martínez - Traumatología (Martes, Jueves, Sábado)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(3, 5, 4, 'MARTES', '08:00', '12:00', 30),
(3, 5, 4, 'JUEVES', '08:00', '12:00', 30),
(3, 5, 4, 'SABADO', '08:00', '12:00', 30);

-- Dra. Fernández - Ginecología (Lunes, Miércoles, Viernes)
INSERT INTO horario_atencion (id_medico, id_consultorio, id_especialidad, dia_semana, hora_inicio, hora_fin, duracion_cita) VALUES
(4, 7, 6, 'LUNES', '15:00', '19:00', 40),
(4, 7, 6, 'MIERCOLES', '15:00', '19:00', 40),
(4, 7, 6, 'VIERNES', '15:00', '19:00', 40);

-- ===========================================
-- 5. INSERTAR PACIENTES
-- ===========================================

INSERT INTO paciente (dni, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, genero, direccion, email, id_usuario) VALUES
('70123456', 'Juan Carlos', 'Pérez', 'García', '1990-05-15', 'M', 'Av. Arequipa 1234, Lima', 'juan.perez@email.com', 6),
('70123457', 'María Isabel', 'Rodríguez', 'López', '1985-08-22', 'F', 'Jr. Huancayo 567, Lima', 'maria.rodriguez@email.com', 7),
('70123458', 'Carlos Alberto', 'González', 'Martínez', '1978-12-10', 'M', 'Av. Brasil 890, Lima', 'carlos.gonzalez@email.com', 8),
('70123459', 'Ana Lucía', 'Silva', 'Fernández', '1995-03-25', 'F', 'Calle Los Olivos 234, Lima', 'ana.silva@email.com', 9),
('70123460', 'Luis Fernando', 'Torres', 'Ramírez', '1982-07-18', 'M', 'Av. Colonial 456, Lima', 'luis.torres@email.com', 10);

-- ===========================================
-- 6. INSERTAR TELÉFONOS DE PACIENTES
-- ===========================================

INSERT INTO paciente_telefono (id_paciente, numero, tipo, es_principal) VALUES
(1, '987654321', 'MOVIL', true),
(1, '014567890', 'FIJO', false),
(2, '987654322', 'MOVIL', true),
(3, '987654323', 'MOVIL', true),
(3, '014567891', 'TRABAJO', false),
(4, '987654324', 'MOVIL', true),
(5, '987654325', 'MOVIL', true);

-- ===========================================
-- 7. INSERTAR CITAS DE PRUEBA
-- ===========================================

-- Citas futuras (PENDIENTE/CONFIRMADA)
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta
) VALUES
('CITA-2025-0001', 1, 1, 1, 1, 2, CURRENT_DATE + INTERVAL '5 days', '08:00', '08:30', 'Control de presión arterial y revisión general del corazón'),
('CITA-2025-0002', 2, 2, 2, 2, 2, CURRENT_DATE + INTERVAL '7 days', '09:00', '09:25', 'Control de crecimiento y desarrollo del niño de 3 años'),
('CITA-2025-0003', 3, 3, 5, 4, 1, CURRENT_DATE + INTERVAL '10 days', '08:30', '09:00', 'Dolor en rodilla derecha después de practicar deporte'),
('CITA-2025-0004', 4, 4, 7, 6, 1, CURRENT_DATE + INTERVAL '12 days', '15:00', '15:40', 'Control ginecológico anual de rutina y papanicolau'),
('CITA-2025-0005', 5, 1, 3, 5, 2, CURRENT_DATE + INTERVAL '3 days', '14:00', '14:20', 'Consulta general por gripe y malestar general');

-- Citas pasadas (ATENDIDA)
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta, observaciones
) VALUES
('CITA-2025-0006', 1, 1, 1, 1, 3, CURRENT_DATE - INTERVAL '15 days', '08:00', '08:30', 
 'Dolor en el pecho y palpitaciones', 
 'Paciente diagnosticado con arritmia leve. Se recetó medicamento y se programa seguimiento.'),
('CITA-2025-0007', 2, 2, 2, 2, 3, CURRENT_DATE - INTERVAL '30 days', '10:00', '10:25', 
 'Vacunación y control de peso del niño', 
 'Niño con desarrollo normal. Se aplicaron vacunas correspondientes.'),
('CITA-2025-0008', 3, 3, 5, 4, 3, CURRENT_DATE - INTERVAL '45 days', '09:00', '09:30', 
 'Fractura de muñeca izquierda', 
 'Se colocó yeso. Control en 4 semanas para evaluar consolidación.');

-- Citas canceladas
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta, 
    motivo_cancelacion, cancelado_por
) VALUES
('CITA-2025-0009', 4, 4, 7, 6, 4, CURRENT_DATE + INTERVAL '2 days', '16:00', '16:40', 
 'Control prenatal del primer trimestre', 
 'Paciente tuvo compromiso laboral urgente', 'PACIENTE'),
('CITA-2025-0010', 5, 1, 1, 1, 4, CURRENT_DATE + INTERVAL '4 days', '09:00', '09:30', 
 'Evaluación cardiológica por antecedentes familiares', 
 'Médico tuvo emergencia familiar', 'MEDICO');

-- Citas con inasistencia
INSERT INTO cita (
    codigo_cita, id_paciente, id_medico, id_consultorio, id_especialidad, 
    id_estado, fecha_cita, hora_inicio, hora_fin, motivo_consulta
) VALUES
('CITA-2025-0011', 3, 2, 2, 2, 5, CURRENT_DATE - INTERVAL '7 days', '11:00', '11:25', 
 'Control pediátrico del bebé de 6 meses');

COMMIT;

-- ===========================================
-- 8. VERIFICAR DATOS INSERTADOS
-- ===========================================

SELECT 'Usuarios' AS tabla, COUNT(*) AS total FROM usuario
UNION ALL
SELECT 'Médicos' AS tabla, COUNT(*) AS total FROM medico
UNION ALL
SELECT 'Pacientes' AS tabla, COUNT(*) AS total FROM paciente
UNION ALL
SELECT 'Especialidades Médicas' AS tabla, COUNT(*) AS total FROM medico_especialidad
UNION ALL
SELECT 'Horarios de Atención' AS tabla, COUNT(*) AS total FROM horario_atencion
UNION ALL
SELECT 'Teléfonos' AS tabla, COUNT(*) AS total FROM paciente_telefono
UNION ALL
SELECT 'Citas' AS tabla, COUNT(*) AS total FROM cita
UNION ALL
SELECT 'Notificaciones' AS tabla, COUNT(*) AS total FROM notificacion;

-- Mostrar distribución de citas por estado
SELECT 
    ec.nombre AS estado,
    COUNT(*) AS cantidad,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cita), 2) AS porcentaje
FROM cita c
INNER JOIN estado_cita ec ON c.id_estado = ec.id_estado
GROUP BY ec.nombre, ec.id_estado
ORDER BY ec.id_estado;

PRINT 'Datos de prueba insertados exitosamente!';