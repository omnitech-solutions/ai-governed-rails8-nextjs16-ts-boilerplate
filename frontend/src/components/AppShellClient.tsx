'use client';

import type { PropsWithChildren } from 'react';
import { useEffect, useState } from 'react';
import { AppShell } from '@/components/AppShell';

export function AppShellClient({ children }: PropsWithChildren) {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return <div className="app-shell" suppressHydrationWarning />;
  }

  return <AppShell>{children}</AppShell>;
}
