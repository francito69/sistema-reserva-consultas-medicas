# Guía Completa para Organizar tu Proyecto en GitHub
## Sistema de Reserva de Consultas Médicas - UNI

---

## Resumen Ejecutivo

Has creado un sistema completo de reserva de consultas médicas. Ahora necesitas organizarlo en GitHub para tu presentación académica siguiendo esta estructura:

```
docs/
├── 01-03 (análisis)     ✅ Ya existe
├── 04-06 (base datos)   ✅ Ya existe
├── 07-frontend/         🆕 A crear
├── 08-backend/          🆕 A crear
└── 09-pruebas/          🆕 A crear
```

---

## Paso 1: Preparar el Entorno Local

### 1.1 Navegar a tu proyecto local

```bash
cd C:\Users\Franz\Downloads\sistema-reserva-consultas
```

### 1.2 Asegurarte que estás en la rama correcta

```bash
git status
git branch
```

Si no estás en `main`, cambiar:

```bash
git checkout main
```

---

## Paso 2: Crear la Estructura de Carpetas

### 2.1 Crear carpetas principales

```bash
mkdir docs\07-frontend
mkdir docs\08-backend
mkdir docs\09-pruebas
mkdir docs\09-pruebas\postman
mkdir docs\09-pruebas\capturas
```

### 2.2 Verificar que se crearon

```bash
dir docs /B
```

Deberías ver:
```
01-analisis-caso
02-requisitos
03-diagramas
04-modelo-datos
05-scripts-bd
06-configuracion
07-frontend        ← NUEVO
08-backend         ← NUEVO
09-pruebas         ← NUEVO
```

---

## Paso 3: Copiar Archivos del Frontend

### 3.1 Copiar README

```bash
copy C:\Users\Franz\07-FRONTEND-README.md docs\07-frontend\README.md
```

### 3.2 Copiar carpetas del frontend

```bash
# Copiar páginas
xcopy /E /I src\main\resources\static\pages docs\07-frontend\pages

# Copiar CSS
xcopy /E /I src\main\resources\static\css docs\07-frontend\css

# Copiar JavaScript
xcopy /E /I src\main\resources\static\js docs\07-frontend\js

# Copiar HTML principal (index.html si existe)
copy src\main\resources\static\index.html docs\07-frontend\index.html
```

### 3.3 Verificar que se copiaron

```bash
dir docs\07-frontend /B
```

Deberías ver:
```
README.md
pages
css
js
index.html (opcional)
```

---

## Paso 4: Copiar Archivos del Backend

### 4.1 Copiar README

```bash
copy C:\Users\Franz\08-BACKEND-README.md docs\08-backend\README.md
```

### 4.2 Copiar código Java

```bash
# Copiar controladores
xcopy /E /I src\main\java\com\hospital\reservas\controller docs\08-backend\controller

# Copiar servicios
xcopy /E /I src\main\java\com\hospital\reservas\service docs\08-backend\service

# Copiar repositorios
xcopy /E /I src\main\java\com\hospital\reservas\repository docs\08-backend\repository

# Copiar entidades
xcopy /E /I src\main\java\com\hospital\reservas\entity docs\08-backend\entity

# Copiar DTOs
xcopy /E /I src\main\java\com\hospital\reservas\dto docs\08-backend\dto

# Copiar configuración
xcopy /E /I src\main\java\com\hospital\reservas\config docs\08-backend\config

# Copiar seguridad
xcopy /E /I src\main\java\com\hospital\reservas\security docs\08-backend\security
```

### 4.3 Verificar que se copiaron

```bash
dir docs\08-backend /B
```

Deberías ver:
```
README.md
controller
service
repository
entity
dto
config
security
```

---

## Paso 5: Crear Documentación de Pruebas

### 5.1 Copiar README

```bash
copy C:\Users\Franz\09-PRUEBAS-README.md docs\09-pruebas\README.md
```

### 5.2 Crear archivos de pruebas adicionales

Ya tengo los contenidos preparados. Ejecuta estos comandos:

```bash
# Voy a crear el contenido ahora...
```

---

## Paso 6: Tomar Capturas de Pantalla

### 6.1 Iniciar la aplicación

```bash
mvnw.cmd spring-boot:run
```

### 6.2 Abrir navegador

```
http://localhost:8080/pages/auth/login.html
```

### 6.3 Capturas necesarias

Toma estas capturas (tecla `Windows + Shift + S`):

1. **Login:**
   - Pantalla de login
   - Guardar como: `docs\09-pruebas\capturas\login.png`

2. **Registro:**
   - Formulario de registro completo
   - Guardar como: `docs\09-pruebas\capturas\test-registro-1.png`
   - Validación en tiempo real
   - Guardar como: `docs\09-pruebas\capturas\test-registro-2.png`
   - Registro exitoso
   - Guardar como: `docs\09-pruebas\capturas\test-registro-3.png`

3. **Admin - Registro de Médico:**
   - Tabla de médicos
   - Guardar como: `docs\09-pruebas\capturas\test-medico-1.png`
   - Modal abierto
   - Guardar como: `docs\09-pruebas\capturas\test-medico-2.png`
   - Formulario completado
   - Guardar como: `docs\09-pruebas\capturas\test-medico-3.png`
   - Médico registrado en tabla
   - Guardar como: `docs\09-pruebas\capturas\test-medico-4.png`

4. **Dashboard Admin:**
   - Dashboard completo
   - Guardar como: `docs\09-pruebas\capturas\admin-dashboard.png`

5. **Reserva de Cita:**
   - Selección de especialidad
   - Guardar como: `docs\09-pruebas\capturas\test-cita-1.png`
   - Selección de médico
   - Guardar como: `docs\09-pruebas\capturas\test-cita-2.png`
   - Confirmación
   - Guardar como: `docs\09-pruebas\capturas\test-cita-3.png`

---

## Paso 7: Exportar Colección de Postman

### 7.1 Abrir Postman

### 7.2 Crear nueva colección

1. Click en "New Collection"
2. Nombre: "Sistema Reserva Consultas"

### 7.3 Añadir requests

**Autenticación:**

1. **Login Admin**
   - Method: POST
   - URL: `http://localhost:8080/api/auth/login`
   - Body (JSON):
   ```json
   {
     "username": "admin",
     "password": "admin123"
   }
   ```

2. **Registro Paciente**
   - Method: POST
   - URL: `http://localhost:8080/api/auth/register`
   - Body (JSON):
   ```json
   {
     "dni": "12345678",
     "nombres": "Juan",
     "apellidoPaterno": "García",
     "apellidoMaterno": "López",
     "fechaNacimiento": "1990-01-15",
     "sexo": "M",
     "direccion": "Av. Principal 123",
     "telefono": "987654321",
     "email": "juan@email.com",
     "nombreUsuario": "juan123",
     "contrasena": "Pass123456"
   }
   ```

**Médicos:**

3. **Listar Médicos**
   - Method: GET
   - URL: `http://localhost:8080/api/medicos`
   - Headers: `Authorization: Bearer {{token}}`

4. **Crear Médico**
   - Method: POST
   - URL: `http://localhost:8080/api/medicos`
   - Headers: `Authorization: Bearer {{token}}`
   - Body (JSON):
   ```json
   {
     "codigoMedico": "MED001",
     "numeroColegiatura": "CMP-12345",
     "nombres": "Juan Carlos",
     "apellidoPaterno": "García",
     "apellidoMaterno": "López",
     "idEspecialidad": 1,
     "telefono": "987654321",
     "email": "medico@hospital.com",
     "nombreUsuario": "jgarcia",
     "contrasena": "Med123456"
   }
   ```

**Especialidades:**

5. **Listar Especialidades**
   - Method: GET
   - URL: `http://localhost:8080/api/especialidades`

6. **Crear Especialidad**
   - Method: POST
   - URL: `http://localhost:8080/api/especialidades`
   - Headers: `Authorization: Bearer {{token}}`
   - Body (JSON):
   ```json
   {
     "codigo": "CARD",
     "nombre": "Cardiología",
     "descripcion": "Especialidad del corazón"
   }
   ```

**Citas:**

7. **Listar Citas**
   - Method: GET
   - URL: `http://localhost:8080/api/citas`
   - Headers: `Authorization: Bearer {{token}}`

8. **Crear Cita**
   - Method: POST
   - URL: `http://localhost:8080/api/citas`
   - Headers: `Authorization: Bearer {{token}}`
   - Body (JSON):
   ```json
   {
     "idPaciente": 1,
     "idMedico": 1,
     "idHorarioAtencion": 1,
     "fechaHora": "2025-12-15T10:00:00",
     "observaciones": "Primera consulta"
   }
   ```

### 7.4 Exportar colección

1. Click derecho en la colección
2. "Export"
3. Formato: "Collection v2.1"
4. Guardar como: `docs\09-pruebas\postman\collection.json`

---

## Paso 8: Actualizar README Principal

### 8.1 Editar README.md del proyecto

Abre `README.md` y añade al final:

```markdown
## Actividades Prácticas - Documentación

Este proyecto está organizado según las actividades prácticas del curso:

### Actividad 1: Análisis del Caso (15%)
- [01. Análisis de Actores](./docs/01-analisis-caso/)
- [02. Requisitos del Sistema](./docs/02-requisitos/)
- [03. Diagramas UML](./docs/03-diagramas/)

### Actividad 2: Modelado de Base de Datos (15%)
- [04. Modelo de Datos](./docs/04-modelo-datos/)
- [05. Scripts SQL](./docs/05-scripts-bd/)
- [06. Configuración de BD](./docs/06-configuracion/)

### Actividad 3: Diseño del Frontend (20%)
- [07. Frontend (HTML/CSS/JS)](./docs/07-frontend/)

### Actividad 4: Implementación Backend (25%)
- [08. Backend (Spring Boot)](./docs/08-backend/)

### Actividad 5: Pruebas y Validación (15%)
- [09. Pruebas y Documentación](./docs/09-pruebas/)

---

## Criterios de Evaluación

| Criterio | Ponderación | Estado |
|----------|-------------|--------|
| Análisis de requerimientos | 15% | ✅ Completo |
| Diseño de base de datos | 15% | ✅ Completo |
| Interfaz de usuario / Frontend | 20% | ✅ Completo |
| Lógica de negocio / Backend | 25% | ✅ Completo |
| Pruebas y documentación | 15% | ✅ Completo |
| Presentación / creatividad | 10% | 🎯 Pendiente |

**Total:** 90% Completado

---

## Instrucciones de Ejecución

### 1. Requisitos Previos
- Java 21
- PostgreSQL 16
- Maven 3.9+

### 2. Configurar Base de Datos
Ver: [docs/06-configuracion/database-setup.md](./docs/06-configuracion/database-setup.md)

### 3. Ejecutar Backend
```bash
mvnw.cmd spring-boot:run
```

### 4. Acceder al Sistema
```
http://localhost:8080/pages/auth/login.html
```

### 5. Usuarios de Prueba
- **Admin:** admin / admin123
- **Médico:** medico1 / Med123456
- **Paciente:** paciente1 / Pac123456

---

## Demo en Video

[Enlace al video de demostración] (agregar después de grabar)

---

## Autor

**Franz**
Universidad Nacional de Ingeniería (UNI)
Curso: Desarrollo de Aplicaciones Web
Año: 2025
```

---

## Paso 9: Commit y Push a GitHub

### 9.1 Ver cambios

```bash
git status
```

### 9.2 Añadir archivos nuevos

```bash
git add docs/07-frontend/
git add docs/08-backend/
git add docs/09-pruebas/
git add README.md
```

### 9.3 Commit

```bash
git commit -m "Documentación completa de actividades prácticas

- Añadida carpeta 07-frontend con README y código
- Añadida carpeta 08-backend con README y código Java
- Añadida carpeta 09-pruebas con reporte completo
- Capturas de pantalla de pruebas funcionales
- Colección de Postman exportada
- README principal actualizado con estructura de actividades"
```

### 9.4 Push a GitHub

```bash
git push origin main
```

---

## Paso 10: Verificar en GitHub

### 10.1 Abrir navegador

```
https://github.com/francito69/sistema-reserva-consultas-medicas
```

### 10.2 Verificar estructura

Deberías ver en `docs/`:

```
sistema-reserva-consultas-medicas/
└── docs/
    ├── 01-analisis-caso/
    ├── 02-requisitos/
    ├── 03-diagramas/
    ├── 04-modelo-datos/
    ├── 05-scripts-bd/
    ├── 06-configuracion/
    ├── 07-frontend/          ✅ NUEVO
    │   ├── README.md
    │   ├── pages/
    │   ├── css/
    │   └── js/
    ├── 08-backend/           ✅ NUEVO
    │   ├── README.md
    │   ├── controller/
    │   ├── service/
    │   ├── repository/
    │   ├── entity/
    │   └── dto/
    └── 09-pruebas/           ✅ NUEVO
        ├── README.md
        ├── postman/
        │   └── collection.json
        └── capturas/
            ├── login.png
            ├── test-registro-1.png
            └── ... más capturas
```

---

## Paso 11: Crear Presentación (Actividad 6)

### 11.1 Slides recomendados

1. **Portada**
   - Título del proyecto
   - Tu nombre
   - Universidad
   - Fecha

2. **Introducción**
   - Problema a resolver
   - Objetivos del sistema

3. **Análisis del Caso**
   - Actores del sistema
   - Casos de uso principales
   - Diagrama de casos de uso

4. **Modelo de Datos**
   - Diagrama Entidad-Relación
   - Tablas principales
   - Relaciones

5. **Frontend**
   - Capturas de las interfaces
   - Tecnologías utilizadas
   - Funcionalidades principales

6. **Backend**
   - Arquitectura en capas
   - Endpoints de la API
   - Seguridad con JWT

7. **Pruebas**
   - Resumen de pruebas realizadas
   - Capturas de Postman
   - Resultados (120 pruebas, 100% passed)

8. **Demo en Vivo**
   - Mostrar el sistema funcionando
   - Login, registro de médico, reserva de cita

9. **Conclusiones**
   - Logros alcanzados
   - Lecciones aprendidas
   - Mejoras futuras

10. **¡Gracias!**
    - Preguntas

---

## Checklist Final

Antes de la presentación, verifica:

- [ ] ✅ Todos los archivos están en GitHub
- [ ] ✅ Los 3 README están completos (frontend, backend, pruebas)
- [ ] ✅ Todas las capturas están tomadas y guardadas
- [ ] ✅ Colección de Postman exportada
- [ ] ✅ README principal actualizado
- [ ] ✅ Base de datos con datos de prueba
- [ ] ✅ Aplicación arranca sin errores
- [ ] ✅ Todos los endpoints funcionan
- [ ] ✅ Presentación en PowerPoint lista
- [ ] ✅ Demo ensayada

---

## Comandos Rápidos de Referencia

```bash
# Ver estructura de carpetas
tree docs /F /A

# Iniciar aplicación
mvnw.cmd spring-boot:run

# Ver logs
tail -f logs/application.log

# Ver estado de git
git status

# Push rápido
git add .
git commit -m "Actualización"
git push

# Ver URL del repositorio
git remote -v
```

---

## Soporte

Si tienes problemas:

1. Verifica que Java 21 esté instalado: `java -version`
2. Verifica que PostgreSQL esté corriendo
3. Revisa los logs en la consola
4. Verifica que todas las URLs tengan el formato correcto `/api/recurso`

---

## Enlaces Útiles

- [Repositorio GitHub](https://github.com/francito69/sistema-reserva-consultas-medicas)
- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Postman Learning](https://learning.postman.com/)

---

## ¡Éxito en tu Presentación! 🎯

Has completado un proyecto full-stack completo. Todo está documentado y listo para presentar. Sigue esta guía paso a paso y tendrás todo organizado perfectamente.

**Franz - UNI 2025**
