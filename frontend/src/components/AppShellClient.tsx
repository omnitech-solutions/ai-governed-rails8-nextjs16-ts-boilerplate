"use client";

import type { PropsWithChildren } from "react";
import { AppShell } from "@/components/AppShell";

export function AppShellClient({ children }: PropsWithChildren) {
  return <AppShell>{children}</AppShell>;
}
