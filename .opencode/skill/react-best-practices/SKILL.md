---
name: React Best Practices (Vercel Engineering)
description: 45+ reglas de performance para React/Next.js desde Vercel Engineering
compatibility: opencode
trigger_keywords: ["react", "next.js", "performance", "optimization", "bundle"]
source: Vercel Labs Agent Skills
---

# React Best Practices Skill

Performance optimization guidelines para React y Next.js desde Vercel Engineering. Contiene **45 reglas** priorizadas por impacto para guiar refactoring automático y code generation.

## Cuándo Usar

AUTO-TRIGGER cuando:
- Escribir nuevos componentes React o páginas Next.js
- Implementar data fetching (client o server-side)
- Revisar código para performance issues
- Refactorizar código React/Next.js existente
- Optimizar bundle size o load times

## Categorías por Prioridad

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Eliminating Waterfalls | **CRITICAL** | `async-` | 5 |
| 2 | Bundle Size Optimization | **CRITICAL** | `bundle-` | 5 |
| 3 | Server-Side Performance | **HIGH** | `server-` | 5 |
| 4 | Client-Side Data Fetching | **MEDIUM-HIGH** | `client-` | 2 |
| 5 | Re-render Optimization | **MEDIUM** | `rerender-` | 7 |
| 6 | Rendering Performance | **MEDIUM** | `rendering-` | 7 |
| 7 | JavaScript Performance | **LOW-MEDIUM** | `js-` | 12 |
| 8 | Advanced Patterns | **LOW** | `advanced-` | 2 |

**Total**: 45 reglas

---

## 1. Eliminating Waterfalls (CRITICAL)

**Impacto**: Waterfalls son el #1 performance killer. Cada `await` secuencial agrega full network latency.

### async-defer-await
**Move await into branches where actually used**

❌ **Incorrect**:
```typescript
async function handler() {
  const user = await getUser(); // Blocks immediately
  if (condition) {
    return user.name;
  }
  return null; // user fetch was unnecessary
}
```

✅ **Correct**:
```typescript
async function handler() {
  if (condition) {
    const user = await getUser(); // Only fetch when needed
    return user.name;
  }
  return null;
}
```

### async-parallel
**Use Promise.all() for independent operations**

❌ **Incorrect**:
```typescript
const user = await getUser();
const posts = await getPosts(); // Waits for user to finish
```

✅ **Correct**:
```typescript
const [user, posts] = await Promise.all([
  getUser(),
  getPosts()
]); // Parallel fetch, no waterfall
```

### async-dependencies
**Use better-all for partial dependencies**

❌ **Incorrect**:
```typescript
const user = await getUser();
const posts = await getPosts(user.id); // Sequential
const profile = await getProfile(user.id); // Sequential
```

✅ **Correct**:
```typescript
import { all } from 'better-all';
const { user, posts, profile } = await all({
  user: getUser(),
  posts: ({ user }) => getPosts(user.id), // Waits for user
  profile: ({ user }) => getProfile(user.id) // Waits for user
}); // posts and profile fetch in parallel after user resolves
```

### async-api-routes
**Start promises early, await late in API routes**

❌ **Incorrect**:
```typescript
export async function GET() {
  const data1 = await fetch('/api/1');
  const data2 = await fetch('/api/2');
  return Response.json({ data1, data2 });
}
```

✅ **Correct**:
```typescript
export async function GET() {
  const promise1 = fetch('/api/1'); // Start immediately
  const promise2 = fetch('/api/2'); // Start immediately
  const [data1, data2] = await Promise.all([promise1, promise2]);
  return Response.json({ data1, data2 });
}
```

### async-suspense-boundaries
**Use Suspense to stream content**

❌ **Incorrect**:
```typescript
async function Page() {
  const slowData = await fetchSlowData(); // Blocks entire page
  return <div>{slowData}</div>;
}
```

✅ **Correct**:
```typescript
function Page() {
  return (
    <Suspense fallback={<Loading />}>
      <SlowComponent /> {/* Streams when ready */}
    </Suspense>
  );
}

async function SlowComponent() {
  const slowData = await fetchSlowData();
  return <div>{slowData}</div>;
}
```

---

## 2. Bundle Size Optimization (CRITICAL)

**Impacto**: Reducir bundle size mejora Time to Interactive y Largest Contentful Paint.

### bundle-barrel-imports
**Import directly, avoid barrel files**

❌ **Incorrect**:
```typescript
import { Button } from '@/components'; // Imports entire barrel
```

✅ **Correct**:
```typescript
import { Button } from '@/components/Button'; // Direct import
```

### bundle-dynamic-imports
**Use next/dynamic for heavy components**

❌ **Incorrect**:
```typescript
import HeavyChart from '@/components/HeavyChart'; // 200KB added to bundle

export default function Dashboard() {
  return <HeavyChart />;
}
```

✅ **Correct**:
```typescript
import dynamic from 'next/dynamic';

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  ssr: false, // Client-only if not needed on server
  loading: () => <ChartSkeleton />
});

export default function Dashboard() {
  return <HeavyChart />;
}
```

### bundle-defer-third-party
**Load analytics/logging after hydration**

❌ **Incorrect**:
```typescript
import Analytics from 'analytics-lib'; // 50KB in critical path

export default function Layout({ children }) {
  return (
    <>
      <Analytics />
      {children}
    </>
  );
}
```

✅ **Correct**:
```typescript
'use client';
import { useEffect } from 'react';

export default function Layout({ children }) {
  useEffect(() => {
    import('analytics-lib').then(({ default: Analytics }) => {
      Analytics.init(); // Loads after hydration
    });
  }, []);

  return children;
}
```

### bundle-conditional
**Load modules only when feature is activated**

❌ **Incorrect**:
```typescript
import PremiumFeature from '@/features/PremiumFeature';

export default function Dashboard({ isPremium }) {
  return isPremium ? <PremiumFeature /> : null;
}
```

✅ **Correct**:
```typescript
import dynamic from 'next/dynamic';

const PremiumFeature = dynamic(() => import('@/features/PremiumFeature'));

export default function Dashboard({ isPremium }) {
  return isPremium ? <PremiumFeature /> : null;
}
```

### bundle-preload
**Preload on hover/focus for perceived speed**

✅ **Correct**:
```typescript
import dynamic from 'next/dynamic';
import { useState } from 'react';

const Modal = dynamic(() => import('@/components/Modal'));

export default function Button() {
  const [show, setShow] = useState(false);

  const preload = () => {
    Modal.preload(); // Start loading on hover
  };

  return (
    <>
      <button
        onMouseEnter={preload}
        onFocus={preload}
        onClick={() => setShow(true)}
      >
        Open
      </button>
      {show && <Modal />}
    </>
  );
}
```

---

## 3. Server-Side Performance (HIGH)

**Impacto**: Optimizar SSR y data fetching elimina server-side waterfalls.

### server-cache-react
**Use React.cache() for per-request deduplication**

❌ **Incorrect**:
```typescript
async function getUser(id: string) {
  return fetch(`/api/users/${id}`); // Called multiple times per request
}

// Component A calls getUser(1)
// Component B calls getUser(1) → duplicate fetch
```

✅ **Correct**:
```typescript
import { cache } from 'react';

const getUser = cache(async (id: string) => {
  return fetch(`/api/users/${id}`);
}); // Deduplicates within single request

// Component A calls getUser(1) → fetches
// Component B calls getUser(1) → returns cached
```

### server-cache-lru
**Use LRU cache for cross-request caching**

✅ **Correct**:
```typescript
import { LRUCache } from 'lru-cache';

const cache = new LRUCache({
  max: 500,
  ttl: 1000 * 60 * 5, // 5 minutes
});

export async function getPopularPosts() {
  const cached = cache.get('popular');
  if (cached) return cached;

  const posts = await db.posts.findMany({ where: { popular: true } });
  cache.set('popular', posts);
  return posts;
}
```

### server-serialization
**Minimize data passed to client components**

❌ **Incorrect**:
```typescript
export default async function Page() {
  const user = await getUser(); // { id, name, email, metadata, ...50 fields }
  return <ClientComponent user={user} />; // Serializes all 50 fields
}
```

✅ **Correct**:
```typescript
export default async function Page() {
  const user = await getUser();
  const userData = { id: user.id, name: user.name }; // Only needed fields
  return <ClientComponent user={userData} />;
}
```

### server-parallel-fetching
**Restructure components to parallelize fetches**

❌ **Incorrect**:
```typescript
async function Page() {
  return (
    <>
      <Header /> {/* Awaits user fetch */}
      <Posts />  {/* Awaits posts fetch - sequential */}
    </>
  );
}

async function Header() {
  const user = await getUser();
  return <div>{user.name}</div>;
}

async function Posts() {
  const posts = await getPosts(); // Waits for Header to finish
  return <div>{posts.length}</div>;
}
```

✅ **Correct**:
```typescript
async function Page() {
  const userPromise = getUser();
  const postsPromise = getPosts();

  return (
    <>
      <Header userPromise={userPromise} />
      <Posts postsPromise={postsPromise} />
    </>
  );
}

async function Header({ userPromise }) {
  const user = await userPromise;
  return <div>{user.name}</div>;
}

async function Posts({ postsPromise }) {
  const posts = await postsPromise;
  return <div>{posts.length}</div>;
}
```

### server-after-nonblocking
**Use after() for non-blocking operations**

✅ **Correct (Next.js 15+)**:
```typescript
import { after } from 'next/server';

export async function POST(request: Request) {
  const data = await request.json();
  const result = await saveToDb(data);

  after(() => {
    logAnalytics(data); // Runs after response sent
    sendEmail(data.email); // Non-blocking
  });

  return Response.json(result); // Response sent immediately
}
```

---

## 4. Client-Side Data Fetching (MEDIUM-HIGH)

### client-swr-dedup
**Use SWR for automatic request deduplication**

❌ **Incorrect**:
```typescript
function ComponentA() {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser);
  }, []);
  return <div>{user?.name}</div>;
}

function ComponentB() {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser); // Duplicate fetch
  }, []);
  return <div>{user?.email}</div>;
}
```

✅ **Correct**:
```typescript
import useSWR from 'swr';

const fetcher = (url) => fetch(url).then(r => r.json());

function ComponentA() {
  const { data: user } = useSWR('/api/user', fetcher);
  return <div>{user?.name}</div>;
}

function ComponentB() {
  const { data: user } = useSWR('/api/user', fetcher); // Deduped, same request
  return <div>{user?.email}</div>;
}
```

### client-event-listeners
**Deduplicate global event listeners**

❌ **Incorrect**:
```typescript
function ComponentA() {
  useEffect(() => {
    const handler = () => console.log('resize A');
    window.addEventListener('resize', handler);
    return () => window.removeEventListener('resize', handler);
  }, []);
}

function ComponentB() {
  useEffect(() => {
    const handler = () => console.log('resize B');
    window.addEventListener('resize', handler); // Duplicate listener
    return () => window.removeEventListener('resize', handler);
  }, []);
}
```

✅ **Correct**:
```typescript
// hooks/useWindowSize.ts
const listeners = new Set();

export function useWindowSize() {
  const [size, setSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    const handler = () => {
      setSize({ width: window.innerWidth, height: window.innerHeight });
    };

    listeners.add(handler);

    if (listeners.size === 1) {
      // Only add global listener once
      window.addEventListener('resize', globalHandler);
    }

    return () => {
      listeners.delete(handler);
      if (listeners.size === 0) {
        window.removeEventListener('resize', globalHandler);
      }
    };
  }, []);

  return size;
}

const globalHandler = () => {
  listeners.forEach(handler => handler());
};
```

---

## 5. Re-render Optimization (MEDIUM)

### rerender-memo
**Extract expensive work into memoized components**

❌ **Incorrect**:
```typescript
function Parent({ items }) {
  return items.map(item => (
    <ExpensiveComponent key={item.id} item={item} />
  )); // Re-renders all items when parent re-renders
}
```

✅ **Correct**:
```typescript
const ExpensiveComponentMemo = React.memo(ExpensiveComponent);

function Parent({ items }) {
  return items.map(item => (
    <ExpensiveComponentMemo key={item.id} item={item} />
  )); // Only re-renders items that changed
}
```

### rerender-lazy-state-init
**Pass function to useState for expensive values**

❌ **Incorrect**:
```typescript
function Component() {
  const [data, setData] = useState(expensiveComputation()); // Runs on every render
}
```

✅ **Correct**:
```typescript
function Component() {
  const [data, setData] = useState(() => expensiveComputation()); // Runs only once
}
```

### rerender-transitions
**Use startTransition for non-urgent updates**

❌ **Incorrect**:
```typescript
function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  const handleChange = (e) => {
    setQuery(e.target.value);
    setResults(expensiveFilter(e.target.value)); // Blocks input typing
  };

  return <input onChange={handleChange} />;
}
```

✅ **Correct**:
```typescript
import { useTransition } from 'react';

function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isPending, startTransition] = useTransition();

  const handleChange = (e) => {
    setQuery(e.target.value); // Urgent update
    startTransition(() => {
      setResults(expensiveFilter(e.target.value)); // Non-urgent
    });
  };

  return <input onChange={handleChange} />;
}
```

### rerender-derived-state
**Subscribe to derived booleans, not raw values**

❌ **Incorrect**:
```typescript
function Component() {
  const user = useUser(); // Re-renders on every user field change

  return user.isPremium ? <PremiumBadge /> : null;
}
```

✅ **Correct**:
```typescript
function Component() {
  const isPremium = useIsPremium(); // Only re-renders when isPremium changes

  return isPremium ? <PremiumBadge /> : null;
}

function useIsPremium() {
  const user = useUser();
  return useMemo(() => user.isPremium, [user.isPremium]);
}
```

### Otras reglas de re-render

- **rerender-defer-reads**: Don't subscribe to state only used in callbacks
- **rerender-dependencies**: Use primitive dependencies in effects
- **rerender-functional-setstate**: Use functional setState for stable callbacks

---

## 6. Rendering Performance (MEDIUM)

### rendering-svg-precision
**Reduce SVG coordinate precision**

❌ **Incorrect**:
```typescript
<svg>
  <path d="M 10.123456789 20.987654321 L 30.111111111 40.222222222" />
</svg>
```

✅ **Correct**:
```typescript
<svg>
  <path d="M 10.12 20.99 L 30.11 40.22" /> {/* precision={2} */}
</svg>
```

### rendering-content-visibility
**Use content-visibility for long lists**

✅ **Correct**:
```css
.list-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 200px; /* Estimated height */
}
```

### rendering-hoist-jsx
**Extract static JSX outside components**

❌ **Incorrect**:
```typescript
function Component({ data }) {
  return (
    <>
      <Header /> {/* Recreated on every render */}
      <Content data={data} />
    </>
  );
}
```

✅ **Correct**:
```typescript
const STATIC_HEADER = <Header />; // Created once

function Component({ data }) {
  return (
    <>
      {STATIC_HEADER}
      <Content data={data} />
    </>
  );
}
```

### Otras reglas de rendering

- **rendering-animate-svg-wrapper**: Animate div wrapper, not SVG element
- **rendering-hydration-no-flicker**: Use inline script for client-only data
- **rendering-activity**: Use Activity component for show/hide
- **rendering-conditional-render**: Use ternary, not && for conditionals

---

## 7. JavaScript Performance (LOW-MEDIUM)

### js-set-map-lookups
**Use Set/Map for O(1) lookups**

❌ **Incorrect**:
```typescript
const ids = [1, 2, 3, 4, 5];
const exists = ids.includes(searchId); // O(n)
```

✅ **Correct**:
```typescript
const ids = new Set([1, 2, 3, 4, 5]);
const exists = ids.has(searchId); // O(1)
```

### js-cache-property-access
**Cache object properties in loops**

❌ **Incorrect**:
```typescript
for (let i = 0; i < array.length; i++) { // Accesses .length every iteration
  console.log(array[i]);
}
```

✅ **Correct**:
```typescript
const len = array.length; // Cache once
for (let i = 0; i < len; i++) {
  console.log(array[i]);
}
```

### Otras reglas de JS

- **js-batch-dom-css**: Group CSS changes via classes or cssText
- **js-index-maps**: Build Map for repeated lookups
- **js-cache-function-results**: Cache function results in module-level Map
- **js-cache-storage**: Cache localStorage/sessionStorage reads
- **js-combine-iterations**: Combine multiple filter/map into one loop
- **js-length-check-first**: Check array length before expensive comparison
- **js-early-exit**: Return early from functions
- **js-hoist-regexp**: Hoist RegExp creation outside loops
- **js-min-max-loop**: Use loop for min/max instead of sort
- **js-tosorted-immutable**: Use toSorted() for immutability

---

## 8. Advanced Patterns (LOW)

### advanced-event-handler-refs
**Store event handlers in refs**

Para event handlers que cambian frecuentemente pero no necesitan trigger re-render.

### advanced-use-latest
**useLatest for stable callback refs**

Para mantener callbacks estables mientras acceden a valores latest.

---

## Workflow de Uso

### 1. Durante Code Writing

Builder debe considerar estas reglas al escribir código nuevo:
1. **Waterfalls**: Evitar awaits secuenciales, usar Promise.all()
2. **Bundle Size**: Dynamic imports para componentes pesados
3. **Server Cache**: React.cache() para deduplicación

### 2. Durante Code Review

Reviewer valida contra checklist:
- [ ] No waterfalls (awaits en paralelo cuando posible)
- [ ] Imports dinámicos para componentes >50KB
- [ ] React.cache() para server fetches
- [ ] SWR para client fetches
- [ ] React.memo para componentes costosos
- [ ] SVG precision={2} para gráficos

### 3. Performance Audit

Para auditoría completa:
1. **CRITICAL**: Eliminar waterfalls + optimizar bundle
2. **HIGH**: Server-side caching
3. **MEDIUM**: Re-render + rendering optimizations
4. **LOW**: JS micro-optimizations si es hot path

---

## Integración con Orchestrator

**AUTO-TRIGGER** cuando:
- Task menciona: "React component", "Next.js page", "performance", "optimize"
- Files touched: `*.tsx`, `*.jsx`, pages/, app/
- Review phase: siempre validar contra CRITICAL rules

**Output esperado**:
```
✅ Performance review complete

CRITICAL issues (2):
- async-parallel: line 45 - Sequential awaits detected
- bundle-barrel-imports: line 12 - Barrel import from @/components

HIGH issues (1):
- server-cache-react: line 78 - Missing React.cache() for getUser

Suggested fixes:
[Fixes con code snippets]
```

---

## Referencias

- **Source**: Vercel Labs Agent Skills
- **Docs**: https://nextjs.org/docs/app/building-your-application/optimizing
- **Rules**: 45 reglas detalladas en `rules/` directory (conceptual)
- **Template**: `rules/_template.md`
- **Sections**: `rules/_sections.md`

---

**Version**: 1.0
**Maintainer**: Vercel Engineering
**Last Updated**: 2026-01-15
