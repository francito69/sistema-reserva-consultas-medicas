# 📘 GUÍA DE INSTALACIÓN - BASE DE DATOS PostgreSQL
## Sistema de Reserva de Consultas Médicas Externas

---

## 🎯 OBJETIVO
Crear manualmente la base de datos `sistema_consultas_medicas` en PostgreSQL siguiendo la estructura del proyecto en GitHub.

---

## 📋 PRERREQUISITOS

✅ PostgreSQL 15 o superior instalado
✅ pgAdmin 4 o acceso por terminal (psql)
✅ Credenciales de administrador (usuario: postgres)

---

## 🚀 OPCIÓN 1: INSTALACIÓN USANDO pgAdmin 4 (RECOMENDADO)

### Paso 1: Abrir pgAdmin 4
1. Abre pgAdmin 4
2. Conecta al servidor PostgreSQL local
3. Ingresa la contraseña del usuario `postgres`

### Paso 2: Crear la Base de Datos
1. Click derecho en **Databases**
2. Selecciona **Create > Database**
3. Completa los campos:
   - **Database:** `sistema_consultas_medicas`
   - **Owner:** `postgres`
   - **Encoding:** `UTF8`
4. Click en **Save**

### Paso 3: Abrir Query Tool
1. Click derecho en `sistema_consultas_medicas`
2. Selecciona **Query Tool**

### Paso 4: Ejecutar el Script SQL
1. Abre el archivo: `01_create_database_complete.sql`
2. **Importante:** Elimina o comenta las líneas 9-16 (CREATE DATABASE)
3. Copia TODO el contenido restante
4. Pega en Query Tool
5. Click en el botón **Execute** (▶️) o presiona F5

### Paso 5: Verificar la Instalación
El script mostrará al final:
```
✅ Base de datos creada exitosamente!
✅ Total especialidades: 10
✅ Total consultorios: 7
✅ Total médicos: 3
✅ Total pacientes: 3
✅ Total citas: 3
```

---

## 🚀 OPCIÓN 2: INSTALACIÓN USANDO TERMINAL (psql)

### Paso 1: Abrir Terminal/CMD
```bash
# En Windows
psql -U postgres

# En Linux/Mac
sudo -u postgres psql
```

### Paso 2: Crear la Base de Datos
```sql
CREATE DATABASE sistema_consultas_medicas
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_PE.UTF-8'
    LC_CTYPE = 'es_PE.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
```

### Paso 3: Conectarse a la Base de Datos
```sql
\c sistema_consultas_medicas
```

### Paso 4: Ejecutar el Script
```bash
\i ruta/completa/al/archivo/01_create_database_complete.sql
```

**Ejemplo en Windows:**
```bash
\i C:/Users/TuUsuario/Desktop/01_create_database_complete.sql
```

**Ejemplo en Linux/Mac:**
```bash
\i /home/tuusuario/Desktop/01_create_database_complete.sql
```

### Paso 5: Verificar
```sql
-- Ver todas las tablas creadas
\dt

-- Contar registros
SELECT COUNT(*) FROM especialidad;
SELECT COUNT(*) FROM medico;
SELECT COUNT(*) FROM paciente;
SELECT COUNT(*) FROM cita;
```

---

## 📊 ESTRUCTURA DE TABLAS CREADAS

| # | Tabla | Descripción | Registros Iniciales |
|---|-------|-------------|---------------------|
| 1 | piso | Pisos del hospital | 3 |
| 2 | especialidad | Especialidades médicas | 10 |
| 3 | consultorio | Consultorios disponibles | 7 |
| 4 | paciente | Datos de pacientes | 3 (prueba) |
| 5 | medico | Datos de médicos | 3 (prueba) |
| 6 | horario_atencion | Horarios de médicos | 9 |
| 7 | estado_cita | Estados de citas (lookup) | 5 |
| 8 | cita | Reservas de citas | 3 (prueba) |
| 9 | notificacion | Notificaciones enviadas | 0 |
| 10 | usuario | Autenticación | 5 (prueba) |

---

## 🔐 USUARIOS DE PRUEBA CREADOS

| Username | Password | Rol | Descripción |
|----------|----------|-----|-------------|
| admin | password123 | ADMIN | Administrador del sistema |
| juan.perez | password123 | PACIENTE | Paciente de prueba 1 |
| maria.lopez | password123 | PACIENTE | Paciente de prueba 2 |
| roberto.sanchez | password123 | MEDICO | Médico cardiólogo |
| ana.flores | password123 | MEDICO | Médico pediatra |

⚠️ **IMPORTANTE:** Estas contraseñas son para pruebas. En producción, cambiarlas inmediatamente.

---

## 🔍 CONSULTAS ÚTILES PARA VERIFICAR

```sql
-- Ver todas las especialidades
SELECT * FROM especialidad;

-- Ver médicos con sus especialidades
SELECT 
    m.codigo_medico,
    m.nombres || ' ' || m.apellido_paterno AS medico,
    e.nombre AS especialidad
FROM medico m
INNER JOIN especialidad e ON m.id_especialidad = e.id_especialidad;

-- Ver horarios de atención
SELECT 
    m.nombres || ' ' || m.apellido_paterno AS medico,
    c.numero AS consultorio,
    CASE ha.dia_semana
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS dia,
    ha.hora_inicio,
    ha.hora_fin
FROM horario_atencion ha
INNER JOIN medico m ON ha.id_medico = m.id_medico
INNER JOIN consultorio c ON ha.id_consultorio = c.id_consultorio
ORDER BY m.id_medico, ha.dia_semana;

-- Ver citas programadas
SELECT 
    p.nombres || ' ' || p.apellido_paterno AS paciente,
    m.nombres || ' ' || m.apellido_paterno AS medico,
    c.fecha_cita,
    c.hora_cita,
    e.nombre AS estado,
    c.motivo_consulta
FROM cita c
INNER JOIN paciente p ON c.id_paciente = p.id_paciente
INNER JOIN medico m ON c.id_medico = m.id_medico
INNER JOIN estado_cita e ON c.id_estado = e.id_estado
ORDER BY c.fecha_cita, c.hora_cita;
```

---

## ⚠️ SOLUCIÓN DE PROBLEMAS COMUNES

### Error: "database already exists"
**Solución:** Eliminar la base existente primero
```sql
DROP DATABASE IF EXISTS sistema_consultas_medicas;
```

### Error: "permission denied"
**Solución:** Asegúrate de estar conectado como superusuario (postgres)

### Error: "encoding not supported"
**Solución:** Verificar que PostgreSQL soporte el encoding UTF8
```sql
SHOW server_encoding;
```

### Error al ejecutar el script completo
**Solución:** Ejecutar sección por sección:
1. Primero: DROP TABLES
2. Segundo: CREATE TABLES
3. Tercero: CREATE INDEXES
4. Cuarto: INSERTS

---

## 📁 UBICACIÓN EN EL REPOSITORIO GITHUB

Este script debe estar ubicado en:
```
sistema-reserva-consultas-medicas/
└── database/
    └── ddl/
        └── 01_create_database_complete.sql
```

---

## 🔄 PRÓXIMOS PASOS

1. ✅ **Base de Datos Creada**
2. ⏭️ **Configurar Spring Boot** para conectarse a esta BD
3. ⏭️ **Probar endpoints** del backend
4. ⏭️ **Integrar con Frontend** HTML/CSS/JS

---

## 📞 SOPORTE

Si tienes problemas durante la instalación:
- 📧 Email: franz.inga.c@uni.edu.pe
- 💬 GitHub Issues: [Crear issue](https://github.com/francito69/sistema-reserva-consultas-medicas/issues)

---

## ✅ CHECKLIST DE VERIFICACIÓN

- [ ] PostgreSQL instalado y funcionando
- [ ] Base de datos `sistema_consultas_medicas` creada
- [ ] 10 tablas creadas correctamente
- [ ] Datos iniciales insertados (especialidades, pisos, etc.)
- [ ] Datos de prueba insertados (3 pacientes, 3 médicos, 3 citas)
- [ ] Índices creados para optimización
- [ ] Consultas de verificación ejecutadas exitosamente

---

**🎓 Universidad Nacional de Ingeniería - 2025**
**📚 Proyecto: Sistema de Reserva de Consultas Médicas Externas**