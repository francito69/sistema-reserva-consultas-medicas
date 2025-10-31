-- ============================================
-- Script: 09_insert_lookup_data.sql
-- Descripción: Insertar datos de catálogo
-- ============================================

-- Insertar estados de cita
INSERT INTO estado_cita (id_estado, codigo, nombre, descripcion, color) VALUES
(1, 'PENDIENTE', 'Pendiente', 'Cita recién creada, pendiente de confirmación', '#FFA500'),
(2, 'CONFIRMADA', 'Confirmada', 'Cita confirmada por el sistema', '#00FF00'),
(3, 'ATENDIDA', 'Atendida', 'Paciente fue atendido exitosamente', '#0000FF'),
(4, 'CANCELADA', 'Cancelada', 'Cita fue cancelada por el paciente o médico', '#FF0000'),
(5, 'NO_PRESENTADO', 'No Presentado', 'Paciente no asistió a la cita', '#808080');

-- Reiniciar secuencia
SELECT setval('estado_cita_id_estado_seq', 5, true);

-- Insertar especialidades médicas
INSERT INTO especialidad (codigo, nombre, descripcion, estado) VALUES
('CARD-01', 'Cardiología', 'Especialidad médica que se encarga del estudio, diagnóstico y tratamiento de las enfermedades del corazón', 'ACTIVO'),
('PEDI-01', 'Pediatría', 'Especialidad médica que estudia al niño y sus enfermedades', 'ACTIVO'),
('DERM-01', 'Dermatología', 'Especialidad médica que se encarga del diagnóstico y tratamiento de las enfermedades de la piel', 'ACTIVO'),
('TRAU-01', 'Traumatología', 'Especialidad que estudia las lesiones del aparato locomotor', 'ACTIVO'),
('MGEN-01', 'Medicina General', 'Atención médica general y preventiva', 'ACTIVO'),
('GINE-01', 'Ginecología', 'Especialidad médica que trata las enfermedades del sistema reproductor femenino', 'ACTIVO'),
('OFTA-01', 'Oftalmología', 'Especialidad médica que estudia las enfermedades de ojo y su tratamiento', 'ACTIVO'),
('NEUR-01', 'Neurología', 'Especialidad médica que trata los trastornos del sistema nervioso', 'ACTIVO'),
('PSIQ-01', 'Psiquiatría', 'Especialidad dedicada al estudio y tratamiento de las enfermedades mentales', 'ACTIVO'),
('NUTR-01', 'Nutrición', 'Especialidad que estudia la relación entre los alimentos y la salud', 'ACTIVO');

-- Insertar consultorios
INSERT INTO consultorio (codigo, nombre, piso, capacidad, equipamiento, estado) VALUES
('CONS-101', 'Consultorio de Cardiología 1', 1, 1, 'Electrocardiógrafo, Camilla, Tensiómetro', 'ACTIVO'),
('CONS-102', 'Consultorio de Pediatría 1', 1, 1, 'Balanza pediátrica, Camilla pediátrica, Esterilizador', 'ACTIVO'),
('CONS-201', 'Consultorio de Medicina General 1', 2, 1, 'Camilla, Tensiómetro, Estetoscopio', 'ACTIVO'),
('CONS-202', 'Consultorio de Medicina General 2', 2, 1, 'Camilla, Tensiómetro, Estetoscopio', 'ACTIVO'),
('CONS-301', 'Consultorio de Traumatología 1', 3, 1, 'Camilla ortopédica, Rayos X portátil', 'ACTIVO'),
('CONS-302', 'Consultorio de Dermatología 1', 3, 1, 'Lámpara de Wood, Dermatoscopio, Camilla', 'ACTIVO'),
('CONS-401', 'Consultorio de Ginecología 1', 4, 1, 'Camilla ginecológica, Ecógrafo, Colposcopio', 'ACTIVO'),
('CONS-402', 'Consultorio de Oftalmología 1', 4, 1, 'Lámpara de hendidura, Refractómetro, Tonómetro', 'ACTIVO');

-- Verificar datos insertados
SELECT 'Estado Cita' AS tabla, COUNT(*) AS registros FROM estado_cita
UNION ALL
SELECT 'Especialidad' AS tabla, COUNT(*) AS registros FROM especialidad
UNION ALL
SELECT 'Consultorio' AS tabla, COUNT(*) AS registros FROM consultorio;