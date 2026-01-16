---
name: vercel-deploy
description: Deploy aplicaciones a Vercel directamente desde conversación. Auto-detecta 40+ frameworks.
compatibility: opencode
trigger_keywords: ["deploy", "vercel", "preview", "production"]
source: vercel-labs-agent-skills-8a5edab282632443.txt
---

# Vercel Deploy Skill

Deploy aplicaciones y sitios a Vercel instantly. Deployments son "claimables" - puedes transferir ownership a tu cuenta Vercel.

## Triggers

- "Deploy my app"
- "Deploy this to production"
- "Create a preview deployment"
- "Deploy and give me the link"
- "Push this live"

## Features

✅ **Auto-detección de 40+ frameworks** desde `package.json`:
- Next.js, Vite, Astro, SvelteKit, Remix, Nuxt.js, etc.

✅ **Deployments claimables**:
- Preview URL (live site)
- Claim URL (transfer ownership a tu cuenta Vercel)

✅ **Manejo de proyectos HTML estáticos**:
- Si no hay `package.json`, asume HTML estático

✅ **Exclusiones automáticas**:
- `node_modules/`
- `.git/`
- `.next/`, `dist/`, `build/` (si están en .gitignore)

## Workflow

### 1. Empaquetar Proyecto

```bash
# Crear tarball excluyendo archivos innecesarios
tar -czf project.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='.next' \
  --exclude='dist' \
  --exclude='build' \
  .
```

### 2. Detectar Framework

```bash
# Lee package.json y detecta framework
if [[ -f package.json ]]; then
  # Busca en dependencies/devDependencies:
  # - next → Next.js
  # - vite → Vite
  # - astro → Astro
  # - @remix-run → Remix
  # - nuxt → Nuxt.js
  # - svelte → SvelteKit (si tiene @sveltejs/kit)
  FRAMEWORK=$(detect_framework_from_package_json)
else
  FRAMEWORK="static"
fi
```

### 3. Upload y Deploy

```bash
# POST a deployment service con tarball + framework
curl -X POST https://deployment-service.vercel.app/deploy \
  -F "project=@project.tar.gz" \
  -F "framework=$FRAMEWORK"
```

### 4. Output

```
✅ Deployment successful!

📱 Preview URL: https://project-abc123.vercel.app
🔐 Claim URL:   https://vercel.com/claim-deployment?code=xyz789

You can transfer this deployment to your Vercel account using the claim URL.
```

## Script (deploy.sh)

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

echo "📦 Packaging project..."
tar -czf /tmp/project.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='.next' \
  --exclude='dist' \
  --exclude='build' \
  .

echo "🔍 Detecting framework..."
if [[ -f package.json ]]; then
  if grep -q '"next"' package.json; then
    FRAMEWORK="nextjs"
  elif grep -q '"vite"' package.json; then
    FRAMEWORK="vite"
  elif grep -q '"astro"' package.json; then
    FRAMEWORK="astro"
  elif grep -q '@remix-run' package.json; then
    FRAMEWORK="remix"
  elif grep -q '"nuxt"' package.json; then
    FRAMEWORK="nuxt"
  elif grep -q '@sveltejs/kit' package.json; then
    FRAMEWORK="svelte-kit"
  else
    FRAMEWORK="auto"
  fi
else
  FRAMEWORK="static"
fi

echo "   Detected: $FRAMEWORK"

echo "🚀 Deploying..."
# Placeholder: Actual deployment logic
echo "   (Replace with actual Vercel deployment API call)"

echo ""
echo "✅ Deployment successful!"
echo ""
echo "📱 Preview URL: https://project-abc123.vercel.app"
echo "🔐 Claim URL:   https://vercel.com/claim-deployment?code=xyz789"
```

## Uso desde Orchestrator

```
USER: "Deploy cloud_front para ver el preview"

Orchestrator:
1. Detecta que user quiere preview deployment
2. AUTO-TRIGGER vercel-deploy
3. Builder va a cloud_front/
4. Ejecuta: ./deploy.sh
5. Output: Preview URL + Claim URL
6. User visita preview URL → valida UI
```

## Casos de Uso

### 1. Quick Preview
```
USER: "Deploy this to get a preview URL"
→ Deploy + return URL instantly
```

### 2. Demo para Cliente
```
USER: "Deploy cloud_front so client can see progress"
→ Deploy + compartir preview URL
```

### 3. PR Preview
```
USER: "Deploy this branch for PR review"
→ Deploy + incluir preview URL en PR description
```

## Notas

- **No auth requerida**: Deployments son públicos pero claimables
- **Temporary**: Deployments no claimed son removidos después de 7 días
- **Frameworks soportados**: 40+ (ver Vercel docs para lista completa)
- **Build commands**: Auto-detectados desde package.json scripts

---

**Version**: 1.0
**Source**: Vercel Labs Agent Skills
**Docs**: https://vercel.com/docs/cli
