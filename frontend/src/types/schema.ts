export interface JsonSchema {
  format?: string;
  properties?: Record<string, JsonSchema>;
  required?: string[];
  title?: string;
  type?: string;
  [key: string]: unknown;
}
