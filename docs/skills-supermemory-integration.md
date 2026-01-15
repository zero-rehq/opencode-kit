# Integración con Supermemory

## Introdución

Esta guía explica cómo integrar los Skills del opencode-kit con supermemory para aprendizaje automático y mejora continua del sistema.

## Qué es Supermemory?

Supermemory es una herramienta de almacenamiento y recuperación de conocimiento que permite:
- Guardar aprendizajes de tareas completadas
- Cargar contexto relevante para nuevas tareas
- Mantener un historial de decisiones y patrones

**Beneficios para Skills Routing**:
- El skills-router-agent puede aprender de tareas pasadas
- Los agentes pueden cargar contexto específico del proyecto
- Los patterns se pueden detectar y mejorar con el tiempo
- Los gaps de skills se pueden identificar basado en historial

## Cómo Integrar Skills con Supermemory

### 1. Guardar Aprendizajes (Después de Wrap)

El **Scribe** ya está configurado para guardar learnings automáticamente:

```bash
# Scribe guarda automáticamente
worklog/2026-01-15_jira_catalogos.md ← JIRA_COMMENT generado

# Learnings guardados en supermemory
supermemory save --type learned-pattern --content "..." --tags "..."
supermemory save --type architecture --content "..." --tags "..."
supermemory save --type error-solution --content "..." --tags "..."
```

**Qué guarda Scribe**:

| Tipo de Learning | Descripción | Ejemplo |
|------------------|-------------|----------|
| **learned-pattern** | Contratos, DTOs, patrones de código | "CatalogoDTO shape: {id, nombre, imagen, activo}" |
| **architecture** | Arquitectura, entrypoints, build commands | "Catálogos usan endpoint GET /api/catalogos en signage_service, consumido por cloud_front" |
| **error-solution** | Errores comunes y sus soluciones | "Missing Zod validation en POST endpoints causa runtime errors. Always add validation schemas." |

### 2. Cargar Contexto (Antes de Implementar)

El **Orchestrator** y **Builder** pueden cargar contexto desde supermemory:

```bash
# Orchestrator carga contexto antes de delegar
supermemory query "architecture of cloud_front"
supermemory query "patterns for catalogos in signage_service"
supermemory query "build commands for cloud_front"

# Builder carga contexto antes de implementar
supermemory query "how to add API in signage_service"
supermemory query "patterns for catalogos feature"
supermemory query "build commands for signage_service"
```

**Qué cargan los agentes**:

| Agente | Qué carga | Cuándo carga | Uso del contexto |
|----------|-------------|----------------|----------------|
| **Orchestrator** | Arquitectura, patterns, build commands | Antes de generar Task Brief | Inyecta contexto en Phase Brief |
| **Builder** | Patrones de features específicas | Antes de implementar | Usa patrones conocidos |
| **skills-router-agent** | Patrones de uso de skills | Al analizar tareas | Identifica skills apropiados basado en historial |

### 3. Skills Router Agent con Supermemory

El **skills-router-agent** puede usar supermemory para mejorar sus recomendaciones:

```bash
# skills-router-agent aprende de tareas pasadas
supermemory query "tasks with domain UI/UX and high confidence"

# Resultado esperado:
# {
#   "tasks": [
#     { "task": "Add catalogos feature", "skills_used": ["ui-ux-pro-max", "react-best-practices"], "success": true},
#     { "task": "Create dashboard", "skills_used": ["ui-ux-pro-max"], "success": true},
#     { "task": "Fix auth flow", "skills_used": ["web-design-guidelines", "react-best-practices"], "success": false, "gaps_found": true}
#   ],
#   "patterns": {
#     "UI/UX tasks": { "recommended_skills": ["ui-ux-pro-max"], "success_rate": 0.95},
#     "API/Backend tasks": { "recommended_skills": ["react-best-practices"], "success_rate": 0.87}
#   },
#   "gaps": [
#     {"domain": "Server-Side Performance", "confidence": 85, "occurrences": 5, "gap_exists": true},
#     {"domain": "Documentation", "confidence": 70, "occurrences": 12, "gap_exists": true}
#   ]
# }

# skills-router-agent usa esto para mejorar recomendaciones
# Si task tiene UI/UX: Recomienda ui-ux-pro-max (95% success rate)
# Si task tiene React: Siempre recomienda react-best-practices (87% success rate)
# Si detecta gap: Sugeir crear nuevo skill
```

### 4. Identificación Automática de Gaps

El **skills-router-agent** usa supermemory para identificar patrones y detectar gaps:

```bash
# Búsqueda de patrones repetitivos
supermemory query "manual database migrations repeated pattern"

# Resultado esperado:
# {
#   "pattern": "Manual SQL migrations in multiple backends",
#   "occurrences": 8,
#   "frequency": "monthly",
#   "confidence": 90
# }

# skills-router-agent analiza este patrón
# Si frecuencia > 5 en último mes y confidence > 80%
# → Recolecta crear skill: database-migration
# → Genera plantilla en SKILLS_ROUTER.md
# → Actualiza lista de gaps pendientes
```

## Tipos de Learning en Supermemory

### 1. Learned Patterns (Patrones Aprendidos)

**Propósito**: Guardar patrones de código, arquitectura y diseño que se repiten.

**Cuándo guardar**: Después de completar una tarea que introduce un patrón nuevo.

**Formato**:
```bash
supermemory save \
  --type learned-pattern \
  --content "CatalogoDTO shape: {id, nombre, imagen, activo}" \
  --tags "signage_service, cloud_front, DTO"
```

**Ejemplos de learned patterns**:
```bash
# Contratos de API
supermemory save --type learned-pattern --content "GET /api/catalogos retorna CatalogoDTO[]" --tags "API, signage_service"

# Patrones de React
supermemory save --type learned-pattern --content "Server components para data fetching, client components para interactividad" --tags "React, cloud_front"

# Patrones de errores
supermemory save --type learned-pattern --content "Missing Zod validation causa runtime errors. Always add validation schemas." --tags "error, solution"
```

### 2. Architecture (Arquitectura del Sistema)

**Propósito**: Guardar arquitectura de repos, entrypoints, y configuraciones.

**Cuándo guardar**: Durante bootstrap o cuando se descubre arquitectura nueva.

**Formato**:
```bash
supermemory save \
  --type architecture \
  --content "cloud_front usa Next.js 14 App Router con React Server Components" \
  --tags "cloud_front, Next.js, architecture"
```

**Ejemplos de architecture**:
```bash
# Arquitectura de frontend
supermemory save --type architecture --content "cloud_front: Next.js 14, App Router, React Query, Tailwind CSS" --tags "cloud_front"

# Arquitectura de backend
supermemory save --type architecture --content "signage_service: Express + TypeScript + Zod validation + API routes" --tags "signage_service"

# Comandos de build
supermemory save --type architecture --content "pnpm build para cloud_front, pnpm lint, pnpm typecheck" --tags "build, commands"
```

### 3. Error Solutions (Soluciones a Errores)

**Propósito**: Guardar errores comunes y sus soluciones para evitar repetirlos.

**Cuándo guardar**: Cuando se encuentra un error recurrente que ya tiene solución conocida.

**Formato**:
```bash
supermemory save \
  --type error-solution \
  --content "Missing Zod validation en POST endpoints causa runtime errors. Always add validation schemas." \
  --tags "error, solution, validation"
```

**Ejemplos de error solutions**:
```bash
# Errores de validación
supermemory save --type error-solution --content "Zod validation errors: 'Unexpected value at path' → Define schema completo con z.object()" --tags "Zod, error"

# Errores de build
supermemory save --type error-solution --content "TypeScript errors: 'Cannot find module' → Verificar imports y paths relativos" --tags "TypeScript, error"

# Errores de gates
supermemory save --type error-solution --content "Lint errors: 'unused variable' → Eliminar variables no usadas o agregar _ prefix" --tags "lint, error"
```

### 4. Skills Usage (Uso de Skills)

**Propósito**: Guardar qué skills funcionan bien en qué contextos.

**Cuándo guardar**: Después de completar una tarea donde los skills aportaron valor significativo.

**Formato**:
```bash
supermemory save \
  --type learned-pattern \
  --content "ui-ux-pro-max funciona mejor con dominio 'product' para tareas de catálogo" \
  --tags "skills, ui-ux-pro-max, catalog"
```

**Ejemplos de skills usage**:
```bash
# Éxito de skill
supermemory save --type learned-pattern --content "react-best-practices elimina waterfalls correctamente, 95% success rate en tareas de catálogos" --tags "skills, react-best-practices, success"

# Fallo de skill
supermemory save --type error-solution --content "web-design-guidelines falló en validación de a11y cuando usa con componentes UI personalizados, considerando usar reglas estándar" --tags "skills, web-design-guidelines, error"
```

## Workflow Completo: Task con Supermemory

### 1. Orchestrator: Task Inicialization

```bash
# 1. Cargar contexto desde supermemory
supermemory query "architecture of cloud_front"
supermemory query "patterns for catalogos feature"
supermemory query "build commands for signage_service"

# 2. Generar Task Brief con contexto cargado
# intelligent-prompt-generator usa contexto de supermemory

# 3. Skills Router Agent analiza y recomienda skills
# skills-router-agent puede consultar supermemory para patrones previos

# 4. Delegar a Builder con skills activados
```

### 2. Builder: Implementación

```bash
# 1. Cargar contexto específico
supermemory query "how to add API in signage_service"
supermemory query "patterns for React data fetching"

# 2. Usar skills activados con guía de supermemory
# ui-ux-pro-max: Usa patrones de diseño aprendidos
# react-best-practices: Sigue reglas de performance probadas

# 3. Generar E2E_TRACE con patrones conocidos
```

### 3. Reviewer: Validación

```bash
# 1. Cargar contexto de validación
supermemory query "review patterns for React components"

# 2. Validar con skills activos
# web-design-guidelines: Aplica reglas de a11y aprendidas
# react-best-practices: Sigue reglas de performance probadas
```

### 4. Scribe: Wrap y Learning

```bash
# 1. Generar CHANGELOG con contexto del proyecto
supermemory query "changelog format for this project"

# 2. Guardar learnings en supermemory
# Contratos (learned-pattern)
# Arquitectura (architecture)
# Errores (error-solution)
# Skills exitosos (learned-pattern)

# 3. Generar JIRA_COMMENT listo
```

## Mejora Continua del Skills Router System

### 1. Aprendizaje Automático de Skills

El **skills-router-agent** aprende continuamente:

| Métrica | Cómo se aprende | Ejemplo de uso |
|-----------|-------------------|------------------|
| **Success rate por skill** | Analiza qué skills funcionan mejor en qué dominios | "ui-ux-pro-max tiene 95% success en UI tasks, react-best-practices tiene 87% success en React tasks" |
| **Patterns de tareas exitosas** | Identifica qué características hacen que una tarea tenga éxito | "Tasks con E2E_TRACE detallado tienen 92% éxito" |
| **Skills combinados efectivos** | Aprende qué skill pairs funcionan bien juntos | "ui-ux-pro-max + react-best-practices: 98% éxito en tasks de catálogos" |

### 2. Detección Automática de Gaps

El sistema identifica gaps automáticamente:

```bash
# Búsqueda de patrones que indican gaps
supermemory query "repetitive tasks without skill"

# Análisis de frecuencia y éxito
# Si mismo tipo de tarea se repite > 3 veces en último mes
# Sin skill específico
# Con éxito bajo (< 70%)

# skills-router-agent identifica gap
# → Busca si ya existe skill para ese dominio
# → Genera plantilla si no existe
# → Actualiza SKILLS_ROUTER.md con nuevo gap
```

### 3. Mejora de Recomendaciones

El **skills-router-agent** mejora sus recomendaciones basado en historial:

| Aspecto | Mejora | Resultado |
|-----------|----------|-------------|
| **Precisión de dominios** | domain-classifier se ajusta con más ejemplos | Confidence scores aumentan 5% cada 10 tasks |
| **Selección de skills** | Aprende qué skills funcionan mejor en qué contextos | Rate de skills correctos aumenta 8% cada mes |
| **Gaps detection** | Identifica gaps más temprano | Gaps se detectan 2 días después de primer task relevante |

## Configuración de Supermemory

### Habilitar Supermemory

Asegúrate de que supermemory esté disponible en tu entorno:

```bash
# Verificar si supermemory está instalado
which supermemory

# Si no está instalado, instalar
# Ver documentación de supermemory
```

### Configurar Comandos en Skills

Los agentes y skills ya están configurados para usar supermemory. No necesitas configuración adicional.

## Referencias

- [Guía de Uso de Skills](skills-usage.md) - Cómo usar skills (auto, manual, routers internos)
- [Referencia de Agentes](agents.md) - Descripción detallada de cada agente
- [Guía de Creación de Skills](skills-creation-guide.md) - Tutorial paso a paso
- [Troubleshooting de Skills](skills-troubleshooting.md) - Solución de problemas comunes

---

## Conclusión

La integración con supermemory permite que el Skills Routing System de opencode-kit:

1. **Aprenda continuamente** de tareas completadas
2. **Mejore recomendaciones** basado en historial
3. **Identifique gaps** automáticamente basado en patrones
4. **Proporcione contexto relevante** para nuevas tareas
5. **Evolucione como un empleado calificado** que mejora con el tiempo

Esto crea un sistema de Skills Routing inteligente y adaptativo que crece y mejora con el uso.
