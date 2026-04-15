import type { ColumnsType } from 'antd/es/table';
import type { JsonSchema } from '@/types/schema';

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

const createdColumn = {
  title: 'Created',
  dataIndex: 'created_at',
  key: 'created_at',
  width: 180,
  render: (value: string) => (value ? new Date(value).toLocaleDateString() : '—'),
};
