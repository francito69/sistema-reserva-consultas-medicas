# 📚 Documentación del Proyecto

## Sistema de Reserva de Consultas Médicas Externas

Esta carpeta contiene toda la documentación técnica y académica del proyecto, organizada de acuerdo a las fases de desarrollo.

---

## 📋 Índice de Documentos

### Fase 1: Fundamentos
- **[01 - Introducción y Marco Teórico](01-introduccion.md)**
  - Descripción del proyecto
  - Objetivos generales y específicos
  - Marco teórico
  - Justificación

### Fase 2: Análisis
- **[02 - Requerimientos del Sistema](02-requerimientos.md)**
  - Requerimientos funcionales
  - Requerimientos no funcionales
  - Atributos de calidad
  - Restricciones técnicas

### Fase 3: Especificación
- **[03 - Especificación de Requisitos y Prototipos](03-especificacion-requisitos.md)**
  - Casos de Uso detallados (CU01 - CU07)
  - Diagramas de Casos de Uso
  - Prototipos de interfaces

### Fase 4: Diseño Conceptual
- **[04 - Diseño Conceptual](04-diseño-conceptual.md)**
  - Diagrama Entidad-Relación
  - Diccionario de datos conceptual
  - Tipos de entidad
  - Tipos de relación
  - Diagrama de Clases UML

### Fase 5: Diseño Lógico
- **[05 - Diseño Lógico](05-diseño-logico.md)**
  - Diagrama Relacional
  - Diccionario de datos de tablas
  - Normalización (1FN, 2FN, 3FN)
  - Índices y restricciones

### Fase 6: Implementación BD
- **[06 - Implementación de Base de Datos](06-implementacion-bd.md)**
  - Scripts DDL (CREATE)
  - Scripts DML (INSERT)
  - Scripts DQL (SELECT)
  - Funciones y procedimientos almacenados
  - Triggers

### Fase 7: Manuales
- **[07 - Manual Técnico](07-manual-tecnico.md)**
  - Arquitectura del sistema
  - Tecnologías utilizadas
  - Guía de instalación
  - Configuración del entorno
  - API REST Endpoints

- **[08 - Manual de Usuario](08-manual-usuario.md)**
  - Guía para pacientes
  - Guía para médicos
  - Guía para administradores
  - Preguntas frecuentes (FAQ)

---

## 🎨 Diagramas UML

Todos los diagramas del proyecto están en la carpeta **[`diagramas/`](diagramas/)**:

### Diagramas de Casos de Uso
- `casos-uso-general.png` - Vista general del sistema
- `casos-uso-paciente.png` - Casos de uso para pacientes
- `casos-uso-medico.png` - Casos de uso para médicos
- `casos-uso-admin.png` - Casos de uso para administradores

### Diagramas de Comportamiento
- `secuencia-registrar-paciente.png` - Flujo de registro
- `secuencia-reservar-cita.png` - Flujo de reserva
- `secuencia-cancelar-cita.png` - Flujo de cancelación
- `actividades-proceso-reserva.png` - Proceso completo de reserva
- `estados-cita.png` - Estados de una cita

### Diagramas Estructurales
- `diagrama-clases.png` - Estructura de clases del sistema
- `diagrama-objetos.png` - Instancias de ejemplo
- `diagrama-er-conceptual.png` - Modelo Entidad-Relación
- `diagrama-relacional.png` - Modelo Relacional

> Ver el [README de diagramas](diagramas/README.md) para más detalles.

---

## 🖼️ Prototipos de Interfaces

Todos los mockups están en la carpeta **[`prototipos/`](prototipos/)**:

- `P01-registro-paciente.png` - Formulario de registro de paciente
- `P02-registro-medico.png` - Formulario de registro de médico
- `P03-agenda-horarios.png` - Gestión de agenda médica
- `P04-reserva-cita.png` - Formulario de reserva de cita
- `P05-mis-citas-paciente.png` - Vista de citas del paciente
- `P06-panel-admin.png` - Dashboard del administrador
- `P07-notificaciones.png` - Sistema de notificaciones

> Ver el [README de prototipos](prototipos/README.md) para más detalles.

---

## 📖 Cómo usar esta documentación

### Para Desarrolladores
1. Lee primero [01-introduccion.md](01-introduccion.md) para entender el contexto
2. Revisa [02-requerimientos.md](02-requerimientos.md) para conocer las funcionalidades
3. Estudia [03-especificacion-requisitos.md](03-especificacion-requisitos.md) para los casos de uso
4. Consulta [04-diseño-conceptual.md](04-diseño-conceptual.md) y [05-diseño-logico.md](05-diseño-logico.md) para entender la arquitectura
5. Sigue [07-manual-tecnico.md](07-manual-tecnico.md) para implementar

### Para Usuarios Finales
1. Lee [08-manual-usuario.md](08-manual-usuario.md) para aprender a usar el sistema

### Para Evaluadores Académicos
1. Revisa toda la documentación en orden secuencial (01 → 08)
2. Consulta los diagramas en [`diagramas/`](diagramas/)
3. Revisa los prototipos en [`prototipos/`](prototipos/)
4. Verifica los scripts SQL en [`../database/`](../database/)
5. Examina el código fuente en [`../backend/`](../backend/) y [`../frontend/`](../frontend/)

---

## 🔄 Historial de Versiones

| Versión | Fecha | Descripción |
|---------|-------|-------------|
| 1.0 | 2025-10-24 | Versión inicial - Análisis y diseño completo |
| 1.1 | TBD | Implementación del backend |
| 1.2 | TBD | Implementación del frontend |
| 1.3 | TBD | Testing y ajustes finales |
| 2.0 | TBD | Versión final para entrega |

---

## ✅ Estado de Documentación

| Documento | Estado | Última Actualización |
|-----------|--------|---------------------|
| 01-introduccion.md | ✅ Completo | 2025-10-24 |
| 02-requerimientos.md | ✅ Completo | 2025-10-24 |
| 03-especificacion-requisitos.md | ✅ Completo | 2025-10-24 |
| 04-diseño-conceptual.md | ✅ Completo | 2025-10-24 |
| 05-diseño-logico.md | ✅ Completo | 2025-10-24 |
| 06-implementacion-bd.md | ✅ Completo | 2025-10-24 |
| 07-manual-tecnico.md | 🚧 En Progreso | - |
| 08-manual-usuario.md | 🚧 En Progreso | - |

---

## 📝 Notas Importantes

- Todos los documentos están en formato **Markdown (.md)** para facilitar el versionamiento con Git
- Los diagramas están en formato **PNG** para máxima compatibilidad
- Cada documento incluye enlaces de navegación para moverse fácilmente entre secciones
- La documentación sigue la metodología del proyecto logístico existente del equipo

---

## 🤝 Contribuciones

Esta documentación es parte de un proyecto académico. Si encuentras errores o tienes sugerencias:

1. Crea un **Issue** en el repositorio
2. O contacta directamente al autor

---

## 📧 Contacto

**Autor:** [francito69]  
**Email:** franz.inga.c@uni.edu.pe  
**Universidad:** Universidad Nacional de Ingeniería (UNI)  
**Curso:** Construcción de Software I

---

<div align="center">
  <strong>Documentación del Sistema de Consultas Médicas</strong>
  <br>
  Universidad Nacional de Ingeniería - 2025
</div>