# Troubleshooting de Skills

## Introdución

Esta guía contiene soluciones a problemas comunes que puedes encontrar al trabajar con el Skills Routing System de opencode-kit.

## Problema Común 1: Skill No Aparece

### Síntoma
El skill no aparece cuando el agente llama a `skill()` tool.

### Posibles Causas

1. **Archivo SKILL.md no está en mayúsculas**
   - El sistema OpenCode busca archivos `SKILL.md` en mayúsculas exactamente
   - `skill.md` no funcionará, debe ser `SKILL.md`

2. **Frontmatter no tiene `name` o `description`**
   - El frontmatter YAML debe contener al menos estos campos obligatorios
   - Sin `name` o `description`, el skill no se descubrirá

3. **Directorio del skill no coincide con `name` en frontmatter**
   - El nombre del directorio debe coincidir exactamente con el `name` en frontmatter
   - Ejemplo: `skill-name/` + `SKILL.md` si name es `skill-name`

4. **Permisos del agente no permiten `skill: allow`**
   - El agente debe tener permiso para cargar skills
   - Verifica `.opencode/agent/<agent>.md` para permisos

### Soluciones

**Solución 1: Verificar nombre del archivo**
```bash
# Listar skills existentes
ls -la .opencode/skill/

# Buscar en mayúsculas
find .opencode/skill -name "SKILL.md"

# Verificar que sea exactamente SKILL.md (no skill.md)
```

**Solución 2: Verificar frontmatter**
```yaml
# Frontmatter correcto (con nombre y descripción)
---
name: my-skill
description: Descripción específica del skill
---
```

**Solución 3: Verificar coincidencia de nombres**
```bash
# Si frontmatter dice name: my-skill
# Verificar que directorio sea .opencode/skill/my-skill/
ls -la .opencode/skill/my-skill/SKILL.md
```

**Solución 4: Verificar permisos del agente**
```yaml
# En .opencode/agent/<agent>.md
---
tools:
  skill: allow  # DEBE estar en allow
---
```

---

## Problema Común 2: Skill Se Carga Pero No Funciona

### Síntoma
El skill se carga pero no produce el output esperado o se comporta incorrectamente.

### Posibles Causas

1. **Workflow no está claro**
   - La sección "Workflow" no describe pasos específicos
   - Instrucciones ambiguas o genéricas

2. **Features no están bien descritas**
   - La lista de features no es completa
   - No está claro qué hace el skill exactamente

3. **Ejemplos no son representativos**
   - Los ejemplos no muestran casos reales
   - No incluyen outputs esperados

4. **Router interno mal configurado**
   - Para skills con RULES_ROUTER, WORKFLOW_ROUTER o DOMAINS ROUTER
   - Configuración incorrecta o faltante

### Soluciones

**Solución 1: Revisar sección Workflow**
```markdown
## Workflow

Debes tener pasos claros y específicos:

1. [Paso 1 con detalles exactos]
2. [Paso 2 con detalles exactos]
3. [Paso 3 con detalles exactos]

Cada paso debe decir:
- QUÉ hacer
- CÓMO hacerlo
- QUÉ output generar
```

**Solución 2: Revisar sección Features**
```markdown
## Features

Lista completa de capacidades:

- ✅ Feature 1: Descripción clara de qué hace
- ✅ Feature 2: Descripción clara de qué hace
- ✅ Feature 3: Descripción clara de qué hace

Cada feature debe ser:
- Específica (no genérica)
- Verificable (se puede saber si se aplicó)
- Independiente (no depende de otras)
```

**Solución 3: Mejorar ejemplos**
```markdown
## Ejemplos de Uso

### Ejemplo 1: Caso real del proyecto

**Contexto**: Agregando catálogos en signage_service

**Input**:
```typescript
// Código actual
const catalogos = await service.list();
```

**Process del skill**:
1. Detecta pattern: await sin Promise.all()
2. Identifica rule: async-parallel
3. Genera sugerencia: Usar Promise.all()

**Output esperado**:
```typescript
// Código sugerido
const [catalogos, filters] = await Promise.all([
  service.list(),
  getFilters()
]);
```

**Notas**:
- El ejemplo debe mostrar código ANTES (input) y DESPUÉS (output)
- Explicar QUÉ cambió y POR QUÉ
- Incluir ubicación específica (archivo:line)
```

**Solución 4: Revisar router interno**
```markdown
## RULES_ROUTER

Configurar correctamente categorías y reglas:

| Category | Trigger Keywords | Rules |
|----------|------------------|--------|
| My Category | "keyword1", "keyword2" | Rule 1, Rule 2 |
```

## Problema Común 3: Skills No Se Activan Automáticamente

### Síntoma
Los skills definidos como "auto-trigger" en el Skills Router del agente no se activan automáticamente.

### Posibles Causas

1. **Skills Router mal configurado**
   - El agente no tiene la sección "Skills Router" con la tabla de skills
   - El trigger no está bien definido

2. **Trigger no cumple condiciones**
   - El trigger del skill es demasiado específico
   - Las condiciones para auto-trigger no son claras

3. **Skills Router Agent no se ejecutó**
   - En el Orchestrator, el skills-router-agent no se invocó
   - Por lo tanto, no hay recomendaciones de skills

4. **Agente no tiene los skills correctos**
   - El archivo `.opencode/agent/<agent>.md` no tiene los skills por defecto definidos

### Soluciones

**Solución 1: Verificar Skills Router del agente**
```markdown
## Skills Router for <Agent>

| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| my-skill | Category | HIGH | When X happens | ✅ |
```

**Revisar**:
- ¿Está la sección "Skills Router" presente?
- ¿La tabla está completa?
- ¿Los triggers son claros?
- ¿La columna Default tiene ✅ para skills por defecto?

**Solución 2: Verificar trigger del skill**
```yaml
# En el SKILL.md del skill
---
name: my-skill
description: Descripción del skill
---

## Cuándo Usar

### AUTO-TRIGGER
Este skill se activa automáticamente cuando:
- [Condición CLARA y ESPECÍFICA]
- [Condición CLARA y ESPECÍFICA]

# NO poner:
- Cuando sea necesario (demasiado genérico)
- Si aplica (demasiado genérico)
```

**Solución 3: Verificar ejecución de skills-router-agent**
```bash
# Ver logs del Orchestrator
grep "skills-router-agent" worklog/<task>.md

# Debe ver:
# [skills-router-agent ejecutado]
# Domain classification
# Skills recommendation
```

**Solución 4: Verificar definición de skills por defecto en el agente**
```bash
# Leer archivo del agente
cat .opencode/agent/builder.md

# Buscar sección "Skills Router"
grep -A 30 "## Skills Router" .opencode/agent/builder.md

# Verificar que tenga tabla de skills
```

---

## Problema Común 4: Skills Router Agent No Detecta Gaps

### Síntoma
El skills-router-agent no identifica skills faltantes cuando claramente existen gaps.

### Posibles Causas

1. **SKILLS_ROUTER.md no actualizado**
   - Skills nuevos creados no están en el índice central
   - Skills gaps se movieron pero no se documentaron en el router

2. **No hay patrones de uso para análisis**
   - El skills-router-agent necesita ejemplos de uso para aprender
   - Sin historial de tasks, no puede identificar patrones repetitivos

3. **Gaps no tienen plantillas**
   - El skills-router-agent detecta un gap pero no genera template
   - Falta documentación en `.opencode/skill/<gap-skill>/SKILL.md`

4. **Confidence scores bajos**
   - El domain-classifier devuelve scores < 50% para todos los dominios
   - El skills-router-agent no tiene suficiente confianza para recomendar

### Soluciones

**Solución 1: Actualizar SKILLS_ROUTER.md**
```markdown
## Skills Gaps Identification

### Gaps Detectados y Resueltos

| Skill | Status | Tipo de Gap | Template Disponible |
|--------|----------|----------------|-------------------|
| nextjs-ssr-optimization | ✅ Template creado | Performance gap | `.opencode/skill/nextjs-ssr-optimization/SKILL.md` |
```

**Solución 2: Documentar patrones de uso**
```markdown
## Patterns for Gap Detection

### Patrones Identificados

1. **Database migrations manuales**:
   - Multiple repos tienen esquemas DB similares sin migración automatizada
   - Scripts SQL manuales con errores frecuentes
   - No hay rollback seguro
   - **Gap**: `database-migration`
   - **Confidence**: 65% (visto en 3/5 backends)
   - **Occurrences**: 8 tasks afectadas en último mes

2. **APIs sin documentación automatizada**:
   - Nuevos endpoints creados sin OpenAPI/Swagger
   - DTOs cambian pero documentación desactualizada
   - No hay docs automáticos de OpenAPI
   - **Gap**: `api-documentation-generator`
   - **Confidence**: 75% (visto en signage_service, api_gateway)
   - **Occurrences**: 12 endpoints sin docs
```

**Solución 3: Generar plantillas para gaps**
```yaml
---
name: my-gap-skill
description: Plantilla para skill de gap detectado
---

# [Nombre del Gap] Skill

## Descripción
Este es una plantilla para un skill que debe crearse.

## Gap Detectado

**Confidence**: 70%
**Occurrences**: Visto en X tasks
**Context**: Cuando se repite el patrón

## Implementación Sugerida

[Descripción de cómo implementar este skill]

## Recursos Necesarios

- [Recurso 1]
- [Recurso 2]
```

**Solución 4: Mejorar domain-classifier confidence**
```markdown
## Domain Classification Improvement

Para mejorar confidence scores:

1. **Agregar más keywords** a dominios
2. **Usar modelos más potentes** (opcional)
3. **Ajustar thresholds** por dominio
4. **Entrenar con examples** del proyecto
```

---

## Problema Común 5: Skills Se Superponen

### Síntoma
Múltiples skills se activan para el mismo tipo de trabajo, causando confusión o conflictos.

### Posibles Causas

1. **Triggers superpuestos**
   - Dos skills tienen triggers similares
   - Ambos se activan para la misma condición
   - Ejemplo: `ui-ux-pro-max` y otro skill de UI ambos se activan

2. **Skills Router incorrecto**
   - El agente tiene múltiples skills del mismo tipo marcados como Default
   - No hay lógica de priorización entre ellos

3. **Skills con funcionalidad duplicada**
   - Dos skills hacen cosas similares
   - Uno de ellos es redundante

### Soluciones

**Solución 1: Aclarar triggers y prioridades**
```markdown
## Skills Router for Orchestrator

| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| ui-ux-pro-max | UI/UX Design | HIGH | UI tasks con Next.js | ✅ |
| my-custom-ui-skill | UI/UX Design | MEDIUM | UI tasks específicos | ❌ |
```

**Notas**:
- Solo UI-UX Design (HIGH) tiene ✅ Default
- Otros skills de UI son ❌ Default (opcionales)
- Si ambos se activan, Orchestrator debe decidir cuál usar

**Solución 2: Agregar lógica de priorización**
```markdown
## Priority Logic

Si múltiples skills se activan para la misma tarea:

1. **CRITICAL > HIGH > MEDIUM > LOW**
   - Usar el skill con prioridad más alta
   - Si tienen la misma prioridad, elegir el más específico

2. **Default > Optional**
   - Priorizar skills marcados como Default
   - Solo activar opcionales si necesarios específicos

3. **Specificity check**
   - Si el trigger es específico, usar ese skill
   - Si el trigger es general, usar el más específico
```

**Solución 3: Eliminar duplicados**
```bash
# Revisar skills para funcionalidad duplicada
grep -r "feature similar" .opencode/skill/*/SKILL.md

# Considerar merge o eliminar redundantes
# Documentar cuál skill usar y cuándo
```

---

## Problema Común 6: Permisos de Agentes Incorrectos

### Síntoma
El agente no puede ejecutar una herramienta necesaria para realizar su trabajo.

### Posibles Causas

1. **Permisos demasiado restrictivos**
   - `edit: deny` cuando el agente necesita editar archivos
   - `bash: "*": deny` cuando necesita ejecutar comandos
   - `skill: deny` cuando necesita cargar skills

2. **Permisos en lugar incorrecto**
   - Permisos configurados en opencode.json en lugar del archivo del agente
   - El frontmatter del agente no se respeta

3. **Permisos `ask` que bloquean workflow**
   - Todos los comandos con `ask` requieren aprobación manual
   - Esto interrumpe workflows automáticos

### Soluciones

**Solución 1: Verificar permisos del agente**
```yaml
# En .opencode/agent/<agent>.md
---
permission:
  edit: allow      # Para poder editar
  bash:
    "*": allow    # Para poder ejecutar comandos
  skill: allow      # Para poder cargar skills
---
```

**Solución 2: Verificar opencode.json global**
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "allow",      // Global: allow (no sobreescrito por agente)
    "bash": "ask"       // Global: ask (puede ser overridido por agente)
  }
}
```

**Nota**: Los permisos del agente (frontmatter) tienen prioridad sobre la configuración global.

**Solución 3: Usar permisos selectivos**
```yaml
# En .opencode/agent/<agent>.md
---
permission:
  edit: deny
  bash:
    "git *": allow      # Solo comandos git permitidos
    "pnpm build": allow  # Solo build permitido
    "*": ask          # Todo lo demás requiere aprobación
---
```

---

## Problema Común 7: Router Interno No Funciona

### Síntoma
Skills con router interno (RULES_ROUTER, WORKFLOW_ROUTER, DOMAINS_ROUTER) no funcionan correctamente.

### Posibles Causas

1. **Router file no existe**
   - El archivo `RULES_ROUTER.md`, `WORKFLOW_ROUTER.md` o `DOMAINS_ROUTER.md` no está
   - El skill lo referencia pero el archivo no existe

2. **Router file mal formateado**
   - El router no sigue el formato esperado
   - Tablas con columnas incorrectas
   - Sintaxis markdown incorrecta

3. **Router file incompleto**
   - Faltan categorías o reglas
   - No hay configuración del router

### Soluciones

**Solución 1: Verificar que el router existe**
```bash
# Buscar router files
find .opencode/skill -name "RULES_ROUTER.md"
find .opencode/skill -name "WORKFLOW_ROUTER.md"
find .opencode/skill -name "DOMAINS_ROUTER.md"

# Verificar que el skill lo referencia
grep "RULES_ROUTER" .opencode/skill/my-skill/SKILL.md
```

**Solución 2: Verificar formato del router**
```markdown
## RULES_ROUTER

El router debe tener esta estructura:

| Category | Priority | # Rules | Trigger Keywords | Files Triggered |
|----------|----------|----------|------------------|------------------|
| Category Name | HIGH/MEDIUM/LOW | Number | keyword1, keyword2 | *.ts, *.tsx |

**Notas**:
- Columnas deben estar separadas por |
- Tabla debe tener encabezado
- Cada fila debe tener pipe |
```

**Solución 3: Completar router incompleto**
```markdown
## RULES_ROUTER

Agregar categorías faltantes:

### Category: My Category
- Priority: HIGH
- Trigger Keywords: keyword1, keyword2
- Files Triggered: *.ts, *.tsx
- Rules:
  1. Rule Name
     - Description
     - Check: cómo validar
     - Suggested Fix
  2. Rule Name
     - Description
     - Check: cómo validar
     - Suggested Fix
```

---

## Referencias

Para más información sobre el Skills Routing System:

- [Guía de Uso de Skills](skills-usage.md) - Cómo usar skills (auto, manual, routers internos)
- [Referencia de Agentes](agents.md) - Descripción detallada de cada agente
- [Guía de Creación de Skills](skills-creation-guide.md) - Tutorial paso a paso
- [Integración con Supermemory](skills-supermemory-integration.md) - Aprendizaje automático
