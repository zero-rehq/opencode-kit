---
name: nextjs-ssr-optimization
description: Optimiza rendering performance para Next.js applications (SSR, SSG, ISR, streaming).
compatibility: opencode
---

# Skill: Next.js SSR Optimization

**Status**: Template para nuevo skill (detectado por skills-router-agent como gap)

## Para qué sirve
- Optimizar rendimiento de rendering en Next.js
- Implementar patrones: SSR, SSG, ISR, Server Components
- Reducir Time to First Byte (TTFB) y First Contentful Paint (FCP)
- Streaming para mejor perceived performance

## Casos de uso
- Páginas lentas en SSR (TTFB > 1s)
- Necesidad de caching incremental (ISR)
- Migración de CSR a SSR/SSG
- Implementación de Server Components
- Optimización de data fetching en server

## Recomendaciones principales
1. **Server Components** por defecto (no "use client" innecesario)
2. **Streaming** para slow data fetching (Suspense boundaries)
3. **ISR** para datos que cambian poco (revalidate every X segundos)
4. **SSG** para datos estáticos (generateStaticParams)
5. **Parallel data fetching** en server (Promise.all, no waterfalls)
6. **LRU cache** para DB queries cross-request
7. **React.cache()** para memoizar server fetches
8. **Preloading** de datos critical (preload(), prefetch())

## Checklist de optimización
- [ ] Usar Server Components donde aplica
- [ ] Implementar Suspense boundaries para streaming
- [ ] Configurar ISR para datos semi-estáticos
- [ ] Usar generateStaticParams para rutas dinámicas estáticas
- [ ] Parallel data fetching (Promise.all)
- [ ] React.cache() para server fetches duplicados
- [ ] LRU cache para cross-request caching
- [ ] preload() para critical resources

## Métricas a mejorar
- TTFB (Time to First Byte)
- FCP (First Contentful Paint)
- LCP (Largest Contentful Paint)
- TTI (Time to Interactive)
- CLS (Cumulative Layout Shift)

## Integración con react-best-practices
- React-best-practices reglas CRITICAL aplican
- Reglas SSR-specific:
  - no-serializable-props: Minimizar data serializada a Client Components
  - server-first-fetching: Fetch en server, no en Client Components
  - streaming-suspense: Suspense boundaries para slow data

## Ejemplo de uso

```typescript
// ❌ MAL: Client fetching en browser
'use client';
export default function Page() {
  const [data, setData] = useState(null);
  useEffect(() => {
    fetch('/api/data').then(r => r.json()).then(setData);
  }, []);
  return <div>{data?.name}</div>;
}

// ✅ BIEN: Server fetching con streaming
async function getData() {
  return fetch('https://api.example.com/data').then(r => r.json());
}

export default async function Page() {
  const data = await getData(); // Server-side
  return <div>{data.name}</div>;
}

// ✅ MEJOR: Streaming con Suspense
import { Suspense } from 'react';

async function SlowComponent() {
  const data = await fetch('https://api.example.com/slow').then(r => r.json());
  return <div>{data.name}</div>;
}

export default function Page() {
  return (
    <div>
      <h1>Fast content loads immediately</h1>
      <Suspense fallback={<div>Loading slow content...</div>}>
        <SlowComponent />
      </Suspense>
    </div>
  );
}
```

## Implementación pendiente
- Scripts de análisis SSR
- Reglas específicas para SSR
- Workflows para migración CSR→SSR
- Templates para ISR patterns

---
Generated as gap template from skills-router-agent
