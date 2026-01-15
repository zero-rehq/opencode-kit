# Referencias - Subrepos

Este directorio contiene repos externos clonados como referencia para los skills del kit.

## Estructura

```
docs/references/
├── README.md (este archivo)
├── repos/           # Repos clonados (subrepos)
│   ├── ui-ux-pro-max-skill/
│   ├── agent-skills/
│   ├── opencode-skills-example/
│   └── skill-prompt-generator/
└── *.txt            # Archivos de texto legacy (deprecated, usar repos/)
```

## Subrepos Configurados

### 1. nextlevelbuilder/ui-ux-pro-max-skill

**URL**: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git

**Usado por**: `.opencode/skill/ui-ux-pro-max/`

**Symlinks**:
- `.opencode/skill/ui-ux-pro-max/data` → `docs/references/repos/ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max/data`

**Contenido**:
- 300+ recursos de diseño (CSV)
- 57 UI styles
- 95 color palettes
- 56 font pairings
- 24 chart types
- 98 UX guidelines
- Scripts BM25 de búsqueda (Python)

---

### 2. vercel-labs/agent-skills

**URL**: https://github.com/vercel-labs/agent-skills.git

**Usado por**:
- `.opencode/skill/react-best-practices/`
- `.opencode/skill/web-design-guidelines/`
- `.opencode/skill/vercel-deploy/`

**Symlinks**:
- `.opencode/skill/react-best-practices/rules` → `docs/references/repos/agent-skills/skills/react-best-practices/rules`
- `.opencode/skill/vercel-deploy/scripts/deploy.sh` → `docs/references/repos/agent-skills/skills/claude.ai/vercel-deploy-claimable/scripts/deploy.sh`

**Contenido**:
- 45+ reglas de performance React/Next.js (Vercel Engineering)
- 100+ reglas de UI audit (Web Design Guidelines)
- AGENTS.md con documentación completa
- Metadata.json con configuración
- Scripts de deploy para Vercel

---

### 3. darrenhinde/opencode-skills-example

**URL**: https://github.com/darrenhinde/opencode-skills-example.git

**Usado por**:
- `.opencode/skill/smart-router/`
- `.opencode/skill/workflow-orchestration/`

**Contenido**:
- Smart router patterns (config-driven workflows)
- Workflow orchestration examples
- Tier 1-4 skill patterns
- Hook system examples

---

### 4. huangserva/skill-prompt-generator

**URL**: https://github.com/huangserva/skill-prompt-generator.git

**Usado por**:
- `.opencode/skill/intelligent-prompt-generator/`
- `.opencode/skill/prompt-analyzer/`
- `.opencode/skill/domain-classifier/`
- `.opencode/skill/prompt-master/`

**Contenido**:
- Intelligent prompt generator (3 modos)
- Prompt analyzer (quality scoring)
- Domain classifier (auto-classification)
- Prompt master (meta-orchestration)

---

## Resumen de Symlinks

### Prompt Engineering Skills (TIER 3)

Todos estos skills comparten el mismo set de scripts desde `skill-prompt-generator`:

```
.opencode/skill/intelligent-prompt-generator/scripts/
.opencode/skill/prompt-analyzer/scripts/
.opencode/skill/domain-classifier/scripts/
.opencode/skill/prompt-master/scripts/
```

**Symlinks compartidos**:
- `generator.py` → `skill-prompt-generator/intelligent_generator.py`
- `framework_loader.py` → `skill-prompt-generator/framework_loader.py`
- `framework.yaml` → `skill-prompt-generator/prompt_framework.yaml`
- `knowledge_base/` → `skill-prompt-generator/knowledge_base`
- `core/` → `skill-prompt-generator/core`

### Otros Skills con Symlinks

```
.opencode/skill/ui-ux-pro-max/data/ → ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max/data/
.opencode/skill/react-best-practices/rules/ → agent-skills/skills/react-best-practices/rules/
.opencode/skill/vercel-deploy/scripts/deploy.sh → agent-skills/skills/claude.ai/vercel-deploy-claimable/scripts/deploy.sh
```

## Actualizar Subrepos

Para actualizar todos los repos de referencia con las últimas versiones:

```bash
cd docs/references/repos

# Actualizar todos
for repo in */; do
  echo "Updating $repo..."
  cd "$repo"
  git pull origin main || git pull origin master
  cd ..
done
```

Para actualizar un repo específico:

```bash
cd docs/references/repos/ui-ux-pro-max-skill
git pull
```

## Agregar Nuevo Subrepo

1. **Clonar el repo**:
```bash
cd docs/references/repos
git clone --depth 1 https://github.com/OWNER/REPO.git REPO_NAME
```

2. **Crear symlinks desde skills**:
```bash
ln -s /absolute/path/to/docs/references/repos/REPO_NAME/data \
      .opencode/skill/YOUR_SKILL/data
```

3. **Documentar en este README**:
   - Agregar sección con URL, propósito, symlinks

## Ventajas de Subrepos vs TXT

✅ **Always up-to-date**: `git pull` actualiza todo
✅ **Estructura completa**: Todos los archivos, scripts, docs
✅ **Menos espacio**: Clones shallow (--depth 1) son pequeños
✅ **Versionado**: Cada repo tiene su historial
✅ **Symlinks**: Datos referenciados, no duplicados
✅ **Mantenible**: Fácil agregar/quitar/actualizar

## Notas

- **Shallow clones**: Usamos `--depth 1` para ahorrar espacio
- **Symlinks**: Los datos NO se copian, se referencian
- **Git ignore**: Los repos clonados están en `.gitignore`
- **Legacy TXT**: Los archivos `.txt` son deprecated, usar `repos/`

## Troubleshooting

### Symlink roto

Si un symlink aparece roto:
```bash
# Verificar que el target existe
ls -la /path/to/symlink

# Recrear el symlink
rm /path/to/symlink
ln -s /absolute/path/to/target /path/to/symlink
```

### Repo desactualizado

```bash
cd docs/references/repos/REPO_NAME
git pull
```

### Falta un archivo esperado

```bash
# Verificar estructura del repo clonado
ls -la docs/references/repos/REPO_NAME

# Si falta algo, revisar en GitHub si la estructura cambió
```

---

**Última actualización**: 2026-01-15
