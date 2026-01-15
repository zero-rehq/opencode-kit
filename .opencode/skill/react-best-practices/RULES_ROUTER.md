# React Best Practices - Rules Router

## Categorías de Rules

| Category | Priority | # Rules | Trigger Keywords | Files Triggered |
|----------|----------|---------|------------------|------------------|
| Eliminating Waterfalls | CRITICAL | 5 | async, await, fetch, Promise, waterfall | .tsx, .ts |
| Bundle Size Optimization | CRITICAL | 5 | bundle, import, dynamic, code splitting | .tsx, .ts |
| Server-Side Performance | HIGH | 5 | server, cache, SSR, after, serialization | .ts (server) |
| Client-Side Data Fetching | MEDIUM-HIGH | 2 | SWR, useSWR, client fetch, cache | .tsx (client) |
| Re-render Optimization | MEDIUM | 7 | render, memo, state, useEffect, useCallback | .tsx |
| Rendering Performance | MEDIUM | 7 | SVG, CSS, content-visibility, precision | .tsx, .css |
| JavaScript Performance | LOW-MEDIUM | 12 | JS, loop, Set, Map, cache | .ts, .tsx |
| Advanced Patterns | LOW | 2 | event handler, ref, useLatest | .tsx, .ts |

**Total**: 45 rules

## Routing Logic

### Paso 1: Detectar Categorías desde Contexto

**Context sources**:
- E2E_TRACE (para builder): Detecta qué componentes/endpoints toca
- Diff (para reviewer): Detecta qué archivos modificó
- Task brief (para ambos): Detecta qué tipo de trabajo

**Auto-detection rules**:
```python
# CRITICAL: Waterfalls
if context.contains("async") and context.contains("await"):
    → Activar categoría "Eliminating Waterfalls"

if context.contains("fetch") and not "Promise.all" in context:
    → Activar categoría "Eliminating Waterfalls"

# CRITICAL: Bundle Size
if context.contains("from '@/components") or context.contains("from '@/lib") and not "dynamic" in context:
    → Activar categoría "Bundle Size Optimization"

if context.contains("import HeavyComponent") and context.modifies_size > 50KB:
    → Activar categoría "Bundle Size Optimization"

# HIGH: Server-Side
if context.modifies_server_files() and context.contains("async"):
    → Activar categoría "Server-Side Performance"

# MEDIUM: Re-render
if context.modifies(".tsx") and context.contains("useEffect") or context.contains("useState"):
    → Activar categoría "Re-render Optimization"

# MEDIUM: Rendering
if context.contains("<svg") or context.contains("precision"):
    → Activar categoría "Rendering Performance"
```

### Paso 2: Filtrar Rules por Modo de Uso

**Code Review Mode**:
- Solo CRITICAL + HIGH rules
- 15-20 rules máximo
- Foco: Bloqueantes de performance

**Performance Audit Mode**:
- Todas las categorías
- Todos las 45 rules
- Foco: Optimización completa

**Quick Fix Mode**:
- Solo CRITICAL rules
- 10 rules máximo
- Foco: Issues críticos solamente

### Paso 3: Generar Checklist de Rules Activos

**Output esperado**:
```markdown
## React Best Practices - Rules Activos

### Modo: Code Review

#### CRITICAL Rules (10)

1. [ ] **async-parallel** (Eliminating Waterfalls)
   - Check: Await secuenciales sin dependencias
   - Pattern: `const a = await f1(); const b = await f2();`
   - Fix: `const [a, b] = await Promise.all([f1(), f2()]);`
   - Impact: Elimina waterfalls de network

2. [ ] **bundle-barrel-imports** (Bundle Size)
   - Check: Imports desde barrel files (@/components, @/lib)
   - Pattern: `import { Button } from '@/components'`
   - Fix: `import { Button } from '@/components/Button'`
   - Impact: Reducir bundle size

[... 8 más CRITICAL rules]

#### HIGH Rules (5)

1. [ ] **server-cache-react** (Server-Side Performance)
   - Check: Fetches duplicados en request
   - Pattern: `getUser(id)` llamado múltiples veces
   - Fix: `const getUser = cache(async (id) => {...})`
   - Impact: Deduplicación de DB queries

[... 4 más HIGH rules]

#### MEDIUM Rules (omitido en Code Review mode)

[No se incluyen rules MEDIUM en este modo]

---
Total rules a validar: 15
Expected time: 2-3 minutos
```

## Rules Index (Quick Reference)

### CRITICAL: Eliminating Waterfalls (5 rules)

#### async-1: async-defer-await
**ID**: `async-1`
**Trigger**: `await` en función pero no se usa inmediatamente
**Pattern**: `const user = await getUser(); if (condition) return user.name;`
**Fix**: `if (condition) { const user = await getUser(); return user.name; }`
**Impact**: Elimina network latency innecesaria
**File types**: `.tsx`, `.ts`

#### async-2: async-parallel
**ID**: `async-2`
**Trigger**: `await` secuenciales sin dependencias
**Pattern**: `const user = await getUser(); const posts = await getPosts();`
**Fix**: `const [user, posts] = await Promise.all([getUser(), getPosts()]);`
**Impact**: Ejecución paralela, no waterfall
**File types**: `.tsx`, `.ts`

#### async-3: async-dependencies
**ID**: `async-3`
**Trigger**: `await` secuenciales con dependencias parciales
**Pattern**: `const user = await getUser(); const posts = await getPosts(user.id);`
**Fix**: `import { all } from 'better-all'; const { user, posts } = await all({ user: getUser(), posts: ({ user }) => getPosts(user.id) });`
**Impact**: Ejecución paralela de dependencias
**File types**: `.tsx`, `.ts`

#### async-4: async-api-routes
**ID**: `async-4`
**Trigger**: API routes con await secuenciales al inicio
**Pattern**: `export async function GET() { const data1 = await fetch1(); const data2 = await fetch2(); }`
**Fix**: `export async function GET() { const p1 = fetch1(); const p2 = fetch2(); const [data1, data2] = await Promise.all([p1, p2]); }`
**Impact**: Ejecución paralela en API routes
**File types**: `.ts` (routes)

#### async-5: async-suspense-boundaries
**ID**: `async-5`
**Trigger**: Componentes async que bloquean render inicial sin Suspense
**Pattern**: `async function Page() { const data = await fetchData(); return <div>{data}</div>; }`
**Fix**: `function Page() { return <Suspense fallback={<Loading />}><Data /></Suspense>; } async function Data() { const data = await fetchData(); return <div>{data}</div>; }`
**Impact**: Streaming de contenido, mejora perceived performance
**File types**: `.tsx`

### CRITICAL: Bundle Size Optimization (5 rules)

#### bundle-1: barrel-imports
**ID**: `bundle-1`
**Trigger**: Imports desde barrel files
**Pattern**: `import { Button, Card, Table } from '@/components'`
**Fix**: `import { Button } from '@/components/Button'; import { Card } from '@/components/Card';`
**Impact**: Tree-shaking efectivo, reduce bundle size
**File types**: `.tsx`, `.ts`

#### bundle-2: dynamic-imports
**ID**: `bundle-2`
**Trigger**: Imports de componentes pesados sin dynamic
**Pattern**: `import HeavyChart from '@/components/HeavyChart';`
**Fix**: `import dynamic from 'next/dynamic'; const HeavyChart = dynamic(() => import('@/components/HeavyChart'));`
**Impact**: Code splitting, reduce initial bundle
**File types**: `.tsx`

#### bundle-3: defer-third-party
**ID**: `bundle-3`
**Trigger**: Analytics/logging importados en critical path
**Pattern**: `import Analytics from 'analytics-lib';`
**Fix**: `import { useEffect } from 'react'; useEffect(() => import('analytics-lib').then(({ default: Analytics }) => Analytics.init()), []);`
**Impact**: Defer carga non-critical
**File types**: `.tsx`

#### bundle-4: conditional
**ID**: `bundle-4`
**Trigger**: Componentes condicionales importados siempre
**Pattern**: `import Modal from '@/components/Modal'; export default function Dialog() { return isModal ? <Modal /> : null; }`
**Fix**: `const Modal = dynamic(() => import('@/components/Modal'));`
**Impact**: Code splitting de features condicionales
**File types**: `.tsx`

#### bundle-5: preload
**ID**: `bundle-5`
**Trigger**: Componentes con lazy load sin preload
**Pattern**: `const Modal = dynamic(() => import('@/components/Modal'));`
**Fix**: `<button onMouseEnter={() => Modal.preload()} onClick={open}>Open</button>`
**Impact**: Preload reduce perceived latency
**File types**: `.tsx`

### HIGH: Server-Side Performance (5 rules)

#### server-1: cache-react
**ID**: `server-1`
**Trigger**: Fetches duplicados en server components
**Pattern**: `async function User({ id }) { return await getUser(id); }` llamado múltiples veces
**Fix**: `import { cache } from 'react'; const getUser = cache(async (id) => fetchUser(id));`
**Impact**: Deduplicación de DB queries en request
**File types**: `.ts` (server)

#### server-2: cache-lru
**ID**: `server-2`
**Trigger**: Same data fetch en múltiples requests sin cache
**Pattern**: `getData()` llamado en cada request sin cache cross-request
**Fix**: `import { LRUCache } from 'lru-cache'; const cache = new LRUCache({ max: 500, ttl: 60000 });`
**Impact**: Cache cross-request reduce DB load
**File types**: `.ts` (server)

#### server-3: serialization
**ID**: `server-3`
**Trigger**: Serializar objetos grandes completos a client components
**Pattern**: `const user = await getUser(); return <Client user={user} />;`
**Fix**: `const { id, name } = user; return <Client user={{ id, name }} />;`
**Impact**: Reduce payload, mejora hydration
**File types**: `.tsx`, `.ts` (server)

#### server-4: parallel-fetching
**ID**: `server-4`
**Trigger**: Fetches secuenciales en Server Components que podrían ser paralelos
**Pattern**: `const user = await getUser(); const posts = await getPosts();`
**Fix**: `const [user, posts] = await Promise.all([getUser(), getPosts()]);`
**Impact**: Paralelización reduce server-side waterfalls
**File types**: `.ts` (server)

#### server-5: after
**ID**: `server-5`
**Trigger**: Operaciones bloqueantes en API routes (logging, emails)
**Pattern**: `export async function POST(req) { const data = await saveToDb(req.json()); logAnalytics(req.json); return Response.json(data); }`
**Fix**: `import { after } from 'next/server'; export async function POST(req) { const data = await saveToDb(req.json()); after(() => { logAnalytics(req.json); }); return Response.json(data); }`
**Impact: Non-blocking, mejora time-to-first-byte
**File types**: `.ts` (routes)

### MEDIUM-HIGH: Client-Side Data Fetching (2 rules)

#### client-1: swr-dedup
**ID**: `client-1`
**Trigger**: Múltiples componentes con fetch sin deduplicación
**Pattern**: `const [data1, setData1] = useSWR('/api/data'); const [data2, setData2] = useSWR('/api/data');`
**Fix**: `const { data } = useSWR('/api/data');` (swr dedupa automáticamente)
**Impact**: Reduce requests, cache automático
**File types**: `.tsx` (client)

#### client-2: event-listeners
**ID**: `client-2`
**Trigger**: Global event listeners duplicados
**Pattern**: `useEffect(() => { window.addEventListener('resize', handler); }, []);` en múltiples componentes
**Fix**: `const listeners = new Set(); listeners.add(handler); if (listeners.size === 1) window.addEventListener(...);`
**Impact**: Evita memory leaks y listeners duplicados
**File types**: `.tsx` (client)

### MEDIUM: Re-render Optimization (7 rules)

#### rerender-1: memo
**ID**: `rerender-1`
**Trigger**: Componentes costosos renderizados sin necesidad
**Pattern**: `function Parent() { return items.map(item => <Expensive item={item} />); }`
**Fix**: `const ExpensiveMemo = React.memo(Expensive); function Parent() { return items.map(item => <ExpensiveMemo item={item} />); }`
**Impact**: Re-renders solo cuando props cambian
**File types**: `.tsx`

#### rerender-2: lazy-state-init
**ID**: `rerender-2`
**Trigger**: State inicializado con función costosa
**Pattern**: `function Component() { const [data, setData] = useState(expensiveComputation()); }`
**Fix**: `const [data, setData] = useState(() => expensiveComputation());`
**Impact**: Solo ejecuta una vez
**File types**: `.tsx`

#### rerender-3: transitions
**ID**: `rerender-3`
**Trigger**: State updates en event handlers bloquean UI
**Pattern**: `const handleChange = (e) => setSearch(e.target.value); filterResults(search); }`
**Fix**: `const [isPending, startTransition] = useTransition(); const handleChange = (e) => { setSearch(e.target.value); startTransition(() => filterResults(search)); };`
**Impact**: UI responsiva, updates no urgentes en background
**File types**: `.tsx`

#### rerender-4: derived-state
**ID**: `rerender-4`
**Trigger**: Suscribir a objetos grandes cuando solo se usa propiedad específica
**Pattern**: `const user = useUser(); return user.isPremium ? <Badge /> : null; }`
**Fix**: `const isPremium = useIsPremium(); return isPremium ? <Badge /> : null; function useIsPremium() { const user = useUser(); return useMemo(() => user.isPremium, [user.isPremium]); }`
**Impact**: Re-renders solo cuando propiedad cambia
**File types**: `.tsx`

#### rerender-5: dependencies
**ID**: `rerender-5`
**Trigger**: Effects dependen de objetos/array que cambian cada render
**Pattern**: `useEffect(() => { fetch(user.id); }, [user]);`
**Fix**: `useEffect(() => { fetch(user.id); }, [user.id]);`
**Impact**: Evita ejecuciones innecesarias
**File types**: `.tsx`

#### rerender-6: functional-setstate
**ID**: `rerender-6`
**Trigger**: setState basado en estado previo capturado incorrectamente
**Pattern**: `const [count, setCount] = useState(0); const increment = () => setCount(count + 1);`
**Fix**: `const increment = () => setCount(c => c + 1);`
**Impact**: Evita stale closures
**File types**: `.tsx`

#### rerender-7: defer-reads
**ID**: `rerender-7`
**Trigger**: Suscribir a estado solo usado en callbacks/eventos
**Pattern**: `function Component() { const [user, setUser] = useState(); const handleClick = async () => { const data = await fetchUser(); setUser(data); }; return <button onClick={handleClick}>Get User</button>; }`
**Fix**: `function Component() { const [user, setUser] = useState(); const handleClick = async () => { const data = await fetchUser(); handleClick2(data); }; return <button onClick={handleClick}>Get User</button>; function handleClick2(data) { setUser(data); } }`
**Impact**: Evita re-renders no necesarios
**File types**: `.tsx`

### MEDIUM: Rendering Performance (7 rules)

#### rendering-1: svg-precision
**ID**: `rendering-1`
**Trigger**: SVG paths con alta precisión innecesaria
**Pattern**: `<path d="M 10.123456789 20.987654321" />`
**Fix**: `<path d="M 10.12 20.99" precision={2} />`
**Impact**: Reduce SVG size, mejora render
**File types**: `.tsx`

#### rendering-2: content-visibility
**ID**: `rendering-2`
**Trigger**: Listas largas sin virtualización
**Pattern**: `function List() { return items.map(item => <HeavyItem item={item} />); }`
**Fix**: `.list-item { content-visibility: auto; contain-intrinsic-size: 0 200px; }`
**Impact**: Virtualización nativa, reduce initial render
**File types**: `.css`

#### rendering-3: hoist-jsx
**ID**: `rendering-3`
**Trigger**: JSX estático recreado en cada render
**Pattern**: `function Component({ data }) { return <><Header /><Content data={data} /></>; }`
**Fix**: `const STATIC_HEADER = <Header />; function Component({ data }) { return <>{STATIC_HEADER}<Content data={data} /></>; }`
**Impact**: JSX recreado solo una vez
**File types**: `.tsx`

#### rendering-4: animate-svg-wrapper
**ID**: `rendering-4`
**Trigger**: Animaciones directas en elementos SVG
**Pattern**: `<path className="animate-spin" />`
**Fix**: `<div className="animate-spin"><path /></div>`
**Impact**: Mejora performance de animaciones
**File types**: `.tsx`

#### rendering-5: hydration-no-flicker
**ID**: `rendering-5`
**Trigger**: Client components con data dinámico causan hydration mismatch
**Pattern**: `'use client'; function Counter({ initialCount }) { return <div>Count: {initialCount}</div>; }`
**Fix**: `import { suppressHydrationWarning } from 'next/navigation'; return <div suppressHydrationWarning>Count: {initialCount}</div>;`
**Impact**: Evita hydration warnings
**File types**: `.tsx`

#### rendering-6: conditional-render
**ID**: `rendering-6`
**Trigger**: Operadores lógicos para render condicional
**Pattern**: `{showModal && <Modal />}`
**Fix**: `{showModal ? <Modal /> : null}`
**Impact**: Evita renderizar falsy, mejora estabilidad
**File types**: `.tsx`

#### rendering-7: activity
**ID**: `rendering-7`
**Trigger**: Componentes con show/hide sin manejo de estado
**Pattern**: `{isModal && <Modal />}`
**Fix**: `return <Modal open={isModal} />`
**Impact**: Mejora manejo de estado y focus
**File types**: `.tsx`

### LOW-MEDIUM: JavaScript Performance (12 rules)

#### js-1: set-map-lookups
**ID**: `js-1`
**Trigger**: Arrays para lookups frecuentes
**Pattern**: `const ids = [1, 2, 3]; const exists = ids.includes(searchId);`
**Fix**: `const ids = new Set([1, 2, 3]); const exists = ids.has(searchId);`
**Impact**: O(1) lookups vs O(n)
**File types**: `.ts`

#### js-2: cache-property-access
**ID**: `js-2`
**Trigger**: Access a propiedades de objetos en loops
**Pattern**: `for (let i = 0; i < array.length; i++) { array[i].property; }`
**Fix**: `const prop = 'property'; for (let i = 0; i < array.length; i++) { array[i][prop]; }`
**Impact**: Reduce property lookups
**File types**: `.ts`, `.tsx`

#### js-3: batch-dom-css
**ID**: `js-3`
**Trigger**: Múltiples cambios al DOM en loop
**Pattern**: `for (let i = 0; i < 100; i++) { element.style.color = colors[i]; element.style.border = borders[i]; }`
**Fix: `element.style.cssText = \`color: \${colors[i]}; border: \${borders[i]}\`;`
**Impact**: Reduce reflows/repaints
**File types**: `.tsx`

#### js-4: index-maps
**ID**: `js-4`
**Trigger**: Lookups repetidos en arrays grandes
**Pattern**: `items.find(item => item.id === searchId); items.find(item => item.id === otherId);`
**Fix**: `const itemMap = new Map(items.map(item => [item.id, item])); itemMap.get(searchId); itemMap.get(otherId);`
**Impact**: O(1) vs O(n) lookups
**File types**: `.ts`

#### js-5: cache-function-results
**ID**: `js-5`
**Trigger**: Funciones puras costosas llamadas múltiples veces
**Pattern**: `function Component() { const result = expensiveComputation(data); }`
**Fix**: `const cachedComputation = new Map(); function Component() { const cached = cachedComputation.get(data); if (cached) return cached; const result = expensiveComputation(data); cachedComputation.set(data, result); return result; }`
**Impact**: Memoización de resultados costosos
**File types**: `.ts`

#### js-6: cache-storage
**ID**: `js-6`
**Trigger**: Lecturas repetidas de localStorage/sessionStorage
**Pattern**: `const value = localStorage.getItem('key'); process(value);`
**Fix**: `const cached = localStorage.getItem('key') ?? {}; if (!cached.timestamp || Date.now() - cached.timestamp > 60000) { cached = { value: fetchFromApi(), timestamp: Date.now() }; localStorage.setItem('key', JSON.stringify(cached)); } process(cached.value);`
**Impact**: Reduce I/O blocking
**File types**: `.tsx`

#### js-7: combine-iterations
**ID**: `js-7`
**Trigger**: Múltiples passes sobre el mismo array (filter, map, etc.)
**Pattern**: `const filtered = items.filter(item => item.active); const mapped = filtered.map(item => item.value * 2); const sorted = mapped.sort();`
**Fix**: `const result = items.filter(item => item.active).map(item => item.value * 2).sort();`
**Impact**: Una sola iteración
**File types**: `.ts`

#### js-8: length-check-first
**ID**: `js-8`
**Trigger**: Comparaciones costosas antes de validar longitud
**Pattern**: `if (array1.some(item => item.id === searchId) && array2.some(item => item.id === searchId))`
**Fix**: `if (!array1.length || !array2.length) return; if (array1.some(...) && array2.some(...))`
**Impact**: Early exit en arrays vacíos
**File types**: `.ts`

#### js-9: early-exit
**ID**: `js-9`
**Trigger**: Continuación sin verificar condiciones de salida
**Pattern**: `function process(items) { for (const item of items) { if (item.id === target) return; } }`
**Fix**: `function process(items) { for (const item of items) { if (item.id === target) return item; } }` (ya hay early exit)
**Impact**: Buena práctica, valida lógica
**File types**: `.ts`

#### js-10: hoist-regexp
**ID**: `js-10`
**Trigger**: RegExp creados dentro de loops
**Pattern**: `for (let i = 0; i < items.length; i++) { const regex = new RegExp(items[i].pattern, 'i'); }`
**Fix**: `const regexMap = new Map(); items.forEach(item => { regexMap.set(item.pattern, new RegExp(item.pattern, 'i')); });`
**Impact**: Reduce creaciones de RegExp
**File types**: `.ts`

#### js-11: min-max-loop
**ID**: `js-11`
**Trigger**: Buscar min/max con sort
**Pattern**: `const min = Math.min(...array); const max = Math.max(...array);`
**Fix**: `let min = array[0], max = array[0]; for (const val of array) { if (val < min) min = val; if (val > max) max = val; }`
**Impact**: O(n) vs O(n log n)
**File types**: `.ts`

#### js-12: tosorted-immutable
**ID**: `js-12`
**Trigger**: Sort con mutación para copia
**Pattern**: `const sorted = [...array].sort(); const result = sorted.map(item => ({ ...item, sorted: true }));`
**Fix**: `const result = [...array].toSorted((a, b) => compare(a, b));`
**Impact**: Inmutable y más rápido
**File types**: `.ts`

### LOW: Advanced Patterns (2 rules)

#### advanced-1: event-handler-refs
**ID**: `advanced-1`
**Trigger**: Event handlers recreados en cada render
**Pattern**: `function Component() { const [count, setCount] = useState(0); return <button onClick={() => setCount(c => c + 1)}>Increment</button>; }`
**Fix**: `function Component() { const [count, setCount] = useState(0); const incrementRef = useRef(() => setCount(c => c + 1)); return <button onClick={incrementRef.current}>Increment</button>; }`
**Impact**: Handlers estables sin recreación
**File types**: `.tsx`

#### advanced-2: use-latest
**ID**: `advanced-2`
**Trigger**: Hooks acceden a valores actualizados en callbacks
**Pattern**: `function Component() { const [state, setState] = useState(); const handleClick = async () => { const result = await apiCall(state); setState(result); }; }`
**Fix**: `import { useLatest } from 'react'; function Component() { const [state, setState] = useState(); const latestState = useLatest(state); const handleClick = async () => { const result = await apiCall(latestState.current); setState(result); }; }`
**Impact**: Siempre valores más recientes en callbacks
**File types**: `.tsx`

## Usage Examples

### Ejemplo 1: Code Review de React Component

**Context**:
```
E2E_TRACE:
  Front: CatalogosPage.tsx (React component)
  Backend: GET /api/catalogos (API endpoint)
```

**Routing**:
1. Detecta: ".tsx" → Re-render Optimization + Rendering Performance
2. Detecta: "GET /api/catalogos" → Eliminating Waterfalls
3. Modo: Code Review → Solo CRITICAL + HIGH
4. Rules activos: 15 (10 CRITICAL + 5 HIGH)

**Checklist**:
- [ ] async-parallel: Check Promise.all usage
- [ ] async-api-routes: Check API routes parallel fetching
- [ ] bundle-barrel-imports: Check barrel imports
- [ ] bundle-dynamic-imports: Check dynamic imports
- [ ] server-cache-react: Check React.cache usage
- [ ] server-serialization: Check serialization
- [ ] rerender-memo: Check React.memo usage
- [ ] rerender-lazy-state-init: Check lazy state init
- [ ] rerender-transitions: Check useTransition for blocking updates
- [ ] rendering-svg-precision: Check SVG precision
- [ ] rendering-content-visibility: Check content-visibility for lists
[... +3 más]

### Ejemplo 2: Performance Audit de Dashboard

**Context**:
```
Task: "Optimize dashboard performance"
Files: Dashboard.tsx, useDashboard.ts, apiClient.ts
```

**Routing**:
1. Detecta: "Optimize performance" → Todas las categorías
2. Modo: Performance Audit → Todas las 45 rules
3. Rules activos: 45

**Checklist**:
[All 45 rules listed with IDs]
```

## Fallback: When No Match

**Escenario**: Context no trigger ninguna categoría

**Opciones**:
1. Preguntar: "No se detectó categoría de rules. ¿Qué revisar?"
2. Usar todas las categorías (modo audit completo)
3. Continuar sin rules router (usar todas las 45 rules)

**Output esperado**:
```markdown
## Rules Routing Decision

**Auto-detection**: No category triggered
**Fallback**: Usar todas las categorías (Performance Audit Mode)
**Rules activos**: 45 (todas)
```
