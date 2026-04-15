import { AppShellClient } from "@/components/AppShellClient";
import type { PropsWithChildren } from "react";

export default function DashboardLayout({ children }: PropsWithChildren) {
  return <AppShellClient>{children}</AppShellClient>;
}
