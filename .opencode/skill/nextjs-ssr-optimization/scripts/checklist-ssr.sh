#!/bin/bash

# checklist-ssr.sh - Display SSR optimization checklist
# Usage: ./checklist-ssr.sh

cat << 'EOF'
==========================================
Next.js SSR Optimization Checklist
==========================================

Critical (Do First):
[ ] Use Server Components by default (no "use client" unless needed)
[ ] Implement Suspense boundaries for slow data fetching
[ ] Configure ISR for data that changes infrequently
[ ] Use generateStaticParams for dynamic static routes
[ ] Parallel data fetching (Promise.all, no waterfalls)

High Priority:
[ ] React.cache() for duplicate server fetches
[ ] LRU cache for cross-request caching
[ ] preload() for critical resources
[ ] Minimize serializable props to Client Components
[ ] Fetch data on server, not in Client Components

Medium Priority:
[ ] Streaming with Suspense for slow components
[ ] Optimize images (next/image, WebP)
[ ] Implement loading skeletons
[ ] Configure caching headers for static assets
[ ] Use dynamic imports for large components

Metrics to Improve:
[ ] TTFB (Time to First Byte) - Target: < 500ms
[ ] FCP (First Contentful Paint) - Target: < 1.5s
[ ] LCP (Largest Contentful Paint) - Target: < 2.5s
[ ] TTI (Time to Interactive) - Target: < 3.5s
[ ] CLS (Cumulative Layout Shift) - Target: < 0.1

Common Anti-Patterns to Avoid:
[ ] ❌ Client-side data fetching (useEffect + fetch)
[ ] ❌ Sequential awaits (waterfalls)
[ ] ❌ Missing Suspense boundaries
[ ] ❌ Over-serializing data to Client Components
[ ] ❌ Fetching same data multiple times

==========================================
Integration with react-best-practices
==========================================

All CRITICAL rules from react-best-practices apply:

async-defer-await: Move await into branches where actually used
async-parallel: Use Promise.all() for independent operations
bundle-dynamic-imports: Use next/dynamic for large components
server-first-fetching: Fetch on server, not in Client Components
streaming-suspense: Suspense boundaries for slow data

==========================================
Usage
==========================================

1. Run './analyze-ssr.sh' to analyze current state
2. Review this checklist
3. Implement optimizations (Critical first)
4. Re-run './analyze-ssr.sh' to measure improvements
5. Check metrics in production (Lighthouse, Vercel Analytics)

EOF
