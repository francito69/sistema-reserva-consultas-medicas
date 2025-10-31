-- ============================================
-- Script: 01_create_database.sql
-- Descripción: Crear base de datos principal
-- Autor: [francito69]
-- Fecha: 2025-10-27
-- ============================================

-- Eliminar base de datos si existe (CUIDADO en producción)
DROP DATABASE IF EXISTS sistema_consultas_medicas;

-- Crear base de datos
CREATE DATABASE sistema_consultas_medicas
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_PE.UTF-8'
    LC_CTYPE = 'es_PE.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE sistema_consultas_medicas 
    IS 'Base de datos para el Sistema de Reserva de Consultas Médicas Externas';

-- Conectarse a la base de datos
\c sistema_consultas_medicas

-- Verificar conexión
SELECT current_database(), version();