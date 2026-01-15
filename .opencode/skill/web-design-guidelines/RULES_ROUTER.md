# Web Design Guidelines - Rules Router

## Categorías de Rules

| Category | # Rules | Trigger Keywords | Files Triggered |
|----------|---------|------------------|------------------|
| Accessibility | 10 | aria-label, label, keyboard, a11y, screen reader | .tsx, .jsx |
| Focus States | 4 | focus, :focus-visible, keyboard, tab | .css, .tsx |
| Forms | 12 | input, form, validation, submit, error | .tsx, .jsx |
| Animation | 6 | animation, transition, transform, motion | .css, .tsx |
| Typography | 6 | font, text, heading, size, weight | .css, .tsx |
| Content Handling | 4 | copy, text, content, markdown | .tsx, .md |
| Images | 3 | img, alt, src, loading, lazy | .tsx, .jsx |
| Performance | 6 | loading, image, lazy, performance, speed | .tsx, .css |
| Navigation & State | 4 | router, link, navigation, state | .tsx |
| Touch & Interaction | 5 | click, tap, mobile, touch, hover | .tsx, .css |
| Safe Areas & Layout | 3 | padding, safe-area, layout, spacing | .css, .tsx |
| Dark Mode & Theming | 3 | dark, theme, color, light | .css, .tsx |
| Locale & i18n | 3 | i18n, locale, translate, language | .tsx |
| Hydration Safety | 3 | hydration, useEffect, use client | .tsx |
| Hover & Interactive States | 2 | hover, cursor, interactive, state | .css, .tsx |
| Content & Copy | 7 | copy, text, heading, description | .tsx, .md |
| Anti-patterns | 13 | anti-pattern, bad practice, error, issue | .tsx, .css |

**Total**: 100+ rules

## Routing Logic

### Paso 1: Detectar Categorías desde Contexto

**Context sources**:
- E2E_TRACE (para reviewer): Detecta qué componentes/endpoints toca
- Diff (para reviewer): Detecta qué archivos modificó
- Task brief (para ambos): Detecta qué tipo de trabajo

**Auto-detection rules**:
```
# CRITICAL: Accessibility
if diff.modifies("components/", "pages/") or task.is_review():
    → Activar categoría "Accessibility"

if diff.contains("<input") or diff.contains("<form>"):
    → Activar categoría "Accessibility" + "Forms"

if diff.contains("aria-label") or diff.contains("aria-hidden"):
    → Activar categoría "Accessibility"

# CRITICAL: Focus States
if diff.modifies("focus:", ":focus-visible") or diff.contains("keyboard"):
    → Activar categoría "Focus States"

# CRITICAL: Forms
if diff.contains("<input") or diff.contains("<form>") or diff.contains("validation"):
    → Activar categoría "Forms"

# MEDIUM: Animation
if diff.modifies("transition", "animation", "transform") or diff.contains("@keyframes"):
    → Activar categoría "Animation"

# MEDIUM: Typography
if diff.modifies("font", "text-", "h1", "h2", "h3"):
    → Activar categoría "Typography"

# MEDIUM: Images
if diff.contains("<img") or diff.contains("image"):
    → Activar categoría "Images"

# MEDIUM: Performance
if diff.contains("loading") or diff.contains("lazy"):
    → Activar categoría "Performance"

# LOW: Touch & Interaction
if diff.contains("onClick") or diff.contains("onTap"):
    → Activar categoría "Touch & Interaction"
    → Si diff.contains("hover:") también "Hover & Interactive States"

# LOW: Dark Mode & Theming
if diff.contains("darkMode") or diff.contains("theme") or diff.contains("dark"):
    → Activar categoría "Dark Mode & Theming"

# LOW: Content & Copy
if task.incluye_heading or task.incluye_copy or task.is_content_creation:
    → Activar categoría "Content & Copy"
```

### Paso 2: Filtrar Rules por Modo de Uso

**Code Review Mode**:
- Solo CRITICAL + HIGH rules
- 40-50 rules máximo
- Foco: Bloqueantes de accessibility + UX

**UI Audit Mode**:
- Accessibility (10) + Forms (12) + Focus States (4) = 26 rules CRITICAL
- Añadir: Touch & Interaction (5) + Dark Mode (3) + Hydration (3) = 37 rules
- Total: 26-40 rules
- Foco: Accessibility + UX profesional

**Full Audit Mode**:
- Todas las categorías
- Todos las 100+ rules
- Foco: Auditoría completa

**Quick Check Mode**:
- Solo CRITICAL rules de Accessibility
- 20-25 rules máximo
- Foco: Bloqueantes críticos

### Paso 3: Generar Checklist de Rules Activos

**Output esperado**:
```markdown
## Web Design Guidelines - Rules Activos

### Modo: Code Review

#### Accessibility (10 rules)

1. [ ] **Icon buttons require `aria-label`**
   - Check: Botones con iconos sin aria-label
   - Pattern: `<button><XIcon /></button>`
   - Fix: `<button onClick={handleClose} aria-label="Close dialog"><XIcon /></button>`
   - Impact: Screen readers pueden describir el botón

2. [ ] **Form controls need `<label>` or `aria-label`**
   - Check: Inputs sin label ni aria-label
   - Pattern: `<input type="email" />`
   - Fix: `<label>Email <input type="email" /></label>` o `<input type="email" aria-label="Email address" />`
   - Impact: Screen readers pueden identificar el campo

[... +8 más rules]

#### Forms (CRITICAL only - 6 rules)

1. [ ] **Form controls need `<label>` or `aria-label`**
2. [ ] **Error messages need association**
3. [ ] **Submit buttons need clear labels**
4. [ ] **Required fields need indicators**
5. [ ] **Validation feedback needs to be visible**
6. [ ] **Form needs submit on Enter**

---
Total rules a validar: 36
Expected time: 3-5 minutos
```

## Rules Index (Quick Reference)

### Accessibility (10 rules)

#### a11y-1: Icon buttons require `aria-label`
**ID**: `a11y-1`
**Trigger**: `<button onClick={...}><Icon /></button>` sin aria-label
**Pattern**: `<button onClick={handleClose}><XIcon /></button>`
**Fix**: `<button onClick={handleClose} aria-label="Close dialog"><XIcon /></button>`
**Impact**: Screen readers no pueden describir el botón
**File types**: `.tsx`, `.jsx`

#### a11y-2: Form controls need `<label>` or `aria-label`
**ID**: `a11y-2`
**Trigger**: `<input />` sin label ni aria-label
**Pattern**: `<input type="email" />`
**Fix**: `<label>Email <input type="email" /></label>` o `<input type="email" aria-label="Email address" />`
**Impact**: Screen readers pueden identificar el campo
**File types**: `.tsx`, `.jsx`

[... +8 más rules]

### Focus States (4 rules)

#### focus-1: Focus visible for keyboard navigation
**ID**: `focus-1`
**Trigger**: Elementos interactivos sin :focus-visible
**Pattern**: `<button className="bg-blue-500">Click</button>`
**Fix**: `<button className="bg-blue-500 focus-visible:ring-2">Click</button>`
**Impact**: Keyboard navigation visible
**File types**: `.css`

[... +3 más rules]

### Forms (12 rules)

#### forms-1: Form controls need `<label>` or `aria-label`
**ID**: `forms-1`
**Trigger**: `<input />` sin label ni aria-label
**Pattern**: `<input type="email" />`
**Fix**: `<label>Email <input type="email" /></label>` o `<input type="email" aria-label="Email address" />`
**Impact**: Screen readers pueden identificar el campo
**File types**: `.tsx`, `.jsx`

[... +11 más rules]

### Animation (6 rules)

#### anim-1: Avoid blocking animations
**ID**: `anim-1`
**Trigger**: Animaciones que bloquean UI
**Pattern**: `animation: spin 1s linear infinite`
**Fix**: `animation: spin 1s linear infinite; prefers-reduced-motion: none; @media (prefers-reduced-motion: reduce) { animation-duration: 0.01ms; }`
**Impact**: Respeta preferencias del usuario
**File types**: `.css`

[... +5 más rules]

### Typography (6 rules)

#### typo-1: Use accessible font sizes
**ID**: `typo-1`
**Trigger**: Tamaños de texto < 16px
**Pattern**: `font-size: 14px;`
**Fix**: `font-size: 16px; min(16px, 1rem);`
**Impact: Cumple WCAG AA
**File types**: `.css`

[... +5 más rules]

### Content Handling (4 rules)

#### content-1: Use semantic HTML headings
**ID**: `content-1`
**Trigger**: Headings sin jerarquía semántica
**Pattern**: `<div className="text-xl">Title</div>`
**Fix**: `<h1>Title</h1>`
**Impact: Screen readers pueden navegar por headings
**File types**: `.tsx`, `.html`

[... +3 más rules]

### Images (3 rules)

#### images-1: Images need `alt` text
**ID**: `images-1`
**Trigger**: `<img />` sin alt
**Pattern**: `<img src="/logo.png" />`
**Fix**: `<img src="/logo.png" alt="Company Logo" />`
**Impact**: Screen readers pueden describir la imagen
**File types**: `.tsx`, `.jsx`

[... +2 más rules]

### Performance (6 rules)

#### perf-1: Lazy load images
**ID**: `perf-1`
**Trigger**: Imágenes fuera de viewport sin lazy loading
**Pattern**: `<img src="/large-image.jpg" />`
**Fix**: `<img src="/large-image.jpg" loading="lazy" />`
**Impact**: Reduce initial page load
**File types**: `.tsx`, `.jsx`

[... +5 más rules]

### Navigation & State (4 rules)

#### nav-1: Use `<a>`/`<Link>` for navigation
**ID**: `nav-1`
**Trigger**: `div onClick={...}>` para navegación
**Pattern**: `<div onClick={() => router.push('/settings')}>Settings</div>`
**Fix**: `<Link href="/settings">Settings</Link>`
**Impact: Semántica HTML, accesible
**File types**: `.tsx`

[... +3 más rules]

### Touch & Interaction (5 rules)

#### touch-1: Clickable elements need `cursor-pointer`
**ID**: `touch-1`
**Trigger**: Elementos clickeables sin cursor pointer
**Pattern**: `<div onClick={handleClick}>Click me</div>`
**Fix**: `<div onClick={handleClick} className="cursor-pointer">Click me</div>`
**Impact: Indica interactividad visualmente
**File types**: `.css`, `.tsx`

[... +4 más rules]

### Safe Areas & Layout (3 rules)

#### layout-1: Content padding for fixed elements
**ID**: `layout-1`
**Trigger**: Contenido detrás de navbar fijo
**Pattern**: `<div className="h-full">Content</div>` con `<nav className="fixed top-0">`
**Fix**: `<div className="h-full pt-16">Content</div>` o `<nav className="fixed top-4">`
**Impact: Contenido visible
**File types**: `.css`, `.tsx`

[... +2 más rules]

### Dark Mode & Theming (3 rules)

#### dark-1: Sufficient contrast in light mode
**ID**: `dark-1`
**Trigger**: Text claro en fondo claro sin suficiente contraste
**Pattern**: `<p className="text-gray-400">Body text</p>` en fondo blanco
**Fix**: `<p className="text-gray-600">Body text</p>`
**Impact: Cumple WCAG 4.5:1 mínimo
**File types**: `.css`

[... +2 más rules]

### Locale & i18n (3 rules)

#### i18n-1: Use `lang` attribute
**ID**: `i18n-1`
**Trigger**: `<html>` sin `lang` attribute
**Pattern**: `<html>`
**Fix**: `<html lang="en">`
**Impact: Screen readers pueden detectar idioma
**File types**: `.tsx`, `.html`

[... +2 más rules]

### Hydration Safety (3 rules)

#### hydr-1: Client components only run client code
**ID**: `hydr-1`
**Trigger**: Client components con lógica server
**Pattern**: `'use client'; async function Component({ data }) { await fetch(data); }`
**Fix: `async function Component({ data }) { 'use server'; await fetch(data); }` y pasar datos como props a Client Component
**Impact**: Evita hydration mismatch
**File types**: `.tsx`

[... +2 más rules]

### Hover & Interactive States (2 rules)

#### hover-1: Hover feedback on interactive elements
**ID**: `hover-1`
**Trigger**: Elementos clickeables sin hover state
**Pattern**: `<button onClick={handleClick}>Click</button>`
**Fix**: `<button onClick={handleClick} className="hover:bg-blue-600">Click</button>`
**Impact: Feedback visual de interactividad
**File types**: `.css`, `.tsx`

[... +1 más rules]

### Content & Copy (7 rules)

#### copy-1: Use clear, descriptive headings
**ID**: `copy-1`
**Trigger**: Headings vagos o confusos
**Pattern**: `<h1>Info</h1>` o `<h2>Information</h2>`
**Fix**: `<h1>User Registration</h1>`
**Impact: Mejora comprensión y SEO
**File types**: `.tsx`, `.html`

[... +6 más rules]

### Anti-patterns (13 rules)

#### anti-1: Don't use emoji as icons
**ID**: `anti-1`
**Trigger**: Emojis como íconos UI
**Pattern**: `<span>🎨</span>` o `<button>✅</button>`
**Fix**: `<StarIcon />` o `<button className="text-green-500"><CheckIcon /></button>`
**Impact**: Profesional, accesible para screen readers
**File types**: `.tsx`, `.jsx`

#### anti-2: Don't use `div` for actions
**ID**: `anti-2`
**Trigger**: `div` con onClick para acciones
**Pattern**: `<div onClick={handleClick}>Delete</div>`
**Fix**: `<button onClick={handleDelete}>Delete</button>` o usar `role="button"` si es necesario un div
**Impact**: Semántica HTML, accesible
**File types**: `.tsx`, `.jsx`

[... +11 más rules]

## Fallback: When No Match

**Escenario**: Context no trigger ninguna categoría

**Opciones**:
1. Preguntar: "No se detectó categoría de rules. ¿Qué revisar?"
2. Usar todas las categorías (modo audit completo)
3. Continuar sin rules router (usar todas las 100+ rules)

**Output esperado**:
```markdown
## Rules Routing Decision

**Auto-detection**: No category triggered
**Fallback**: Usar todas las categorías (Full Audit Mode)
**Rules activos**: 100+ (todas)
```

## Usage Examples

### Ejemplo 1: Code Review de Form Component

**Context**:
```
E2E_TRACE:
  Front: ContactForm.tsx (React form component)
```

**Routing**:
1. Detecta: `<input>`, `<form>` → Accessibility + Forms
2. Modo: Code Review → Accessibility + Forms (CRITICAL only)
3. Rules activos: 16 (10 Accessibility + 6 Forms)

**Checklist**:
- [ ] Icon buttons require `aria-label`
- [ ] Form controls need `<label>` or `aria-label`
- [ ] Interactive elements require keyboard handlers
- [ ] Use `<button>` for actions
- [ ] Images need `alt` text
- [ ] Error messages need association
- [ ] Submit buttons need clear labels
- [ ] Required fields need indicators
- [ ] Validation feedback needs to be visible
- [ ] Form needs submit on Enter
- [ ] Don't use emoji icons
- [ ] Don't use `div` for actions
[... +3 más]

### Ejemplo 2: UI Audit de Dashboard

**Context**:
```
Task: "Audit dashboard for accessibility and UX"
Files: Dashboard.tsx, Header.tsx, Sidebar.tsx
```

**Routing**:
1. Detecta: Task menciona "audit", modificación de componentes UI
2. Modo: UI Audit → Accessibility (26-40 rules)
3. Rules activos: 26-40 (Accessibility CRITICAL + Forms + Focus States + Touch & Interaction + Dark Mode + Hydration)

**Checklist**:
[All 26-40 rules with IDs]
```
