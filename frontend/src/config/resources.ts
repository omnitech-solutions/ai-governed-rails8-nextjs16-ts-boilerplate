import type { ColumnsType } from 'antd/es/table';
import type { Company, User } from '@/api/generated';
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

export const companyResource: ResourceMeta<Company> = {
  key: 'companies',
  href: '/companies',
  title: 'Companies',
  kicker: 'Vendor Directory',
  subtitle: 'Maintain the production company list, edit records, and manage membership links.',
  createLabel: 'Create company',
  emptyState: 'No companies yet. Add the first company to populate the workspace.',
  formSchema: {
    type: 'object',
    required: ['name'],
    properties: {
      name: {
        type: 'string',
        title: 'Company name',
      },
    },
  },
  tableColumns: [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 84,
    },
    {
      title: 'Company',
      dataIndex: 'name',
      key: 'name',
    },
    createdColumn,
  ],
};

export const userResource: ResourceMeta<User> = {
  key: 'users',
  href: '/users',
  title: 'Users',
  kicker: 'Team Directory',
  subtitle: 'Review user records, contact details, and who can be assigned across companies.',
  createLabel: 'Create user',
  emptyState: 'No users yet. Create a user record to start assigning members.',
  formSchema: {
    type: 'object',
    required: ['name', 'email'],
    properties: {
      name: {
        type: 'string',
        title: 'Full name',
      },
      email: {
        type: 'string',
        title: 'Email address',
        format: 'email',
      },
    },
  },
  tableColumns: [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 84,
    },
    {
      title: 'Name',
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: 'Email',
      dataIndex: 'email',
      key: 'email',
    },
    createdColumn,
  ],
};
