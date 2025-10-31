-- ============================================
-- Script: 02_create_schemas.sql
-- Descripción: Crear esquemas de organización
-- ============================================

-- Esquema público (ya existe, pero lo documentamos)
COMMENT ON SCHEMA public 
    IS 'Esquema principal del sistema';

-- Crear esquema para auditoría (futuro)
CREATE SCHEMA IF NOT EXISTS auditoria;
COMMENT ON SCHEMA auditoria 
    IS 'Esquema para tablas de auditoría y logs';

-- Crear esquema para reportes (futuro)
CREATE SCHEMA IF NOT EXISTS reportes;
COMMENT ON SCHEMA reportes 
    IS 'Esquema para vistas y tablas de reportes';

-- Listar esquemas creados
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name NOT IN ('pg_catalog', 'information_schema');