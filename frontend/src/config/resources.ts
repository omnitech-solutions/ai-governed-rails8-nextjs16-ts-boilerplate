import type { ColumnsType } from "antd/es/table";
import type { JsonSchema } from "@/types/schema";

export interface ResourceMeta<T extends Record<string, unknown>> {
  createLabel: string;
  emptyState: string;
  formSchema: JsonSchema;
  href: string;
  key: string;
  kicker: string;
  subtitle: string;
  tableColumns: ColumnsType<T>;
  title: string;
}
