/**
 * Generic Resource Table Component
 * Renders a table for any resource using Ant Design Table
 */

import { Table, Button, Space, Popconfirm, Skeleton } from 'antd';
import type { ColumnsType, TableProps } from 'antd/es/table';
import { EditOutlined, DeleteOutlined } from '@ant-design/icons';

export interface ResourceTableProps<T> extends Omit<TableProps<T>, 'columns'> {
  columns: ColumnsType<T>;
  onEdit?: (record: T) => void;
  onDelete?: (record: T) => void;
  isLoading?: boolean;
}

export function ResourceTable<T extends Record<string, any>>({
  columns,
  onEdit,
  onDelete,
  isLoading,
  ...tableProps
}: ResourceTableProps<T>) {
  // Add action columns if edit/delete handlers are provided
  const actionColumns: ColumnsType<T> = [];

  if (onEdit || onDelete) {
    actionColumns.push({
      title: 'Actions',
      key: 'actions',
      width: 120,
      render: (_, record) => (
        <Space size="small">
          {onEdit && (
            <Button
              type="link"
              icon={<EditOutlined />}
              onClick={() => onEdit(record)}
              size="small"
            >
              Edit
            </Button>
          )}
          {onDelete && (
            <Popconfirm
              title="Are you sure you want to delete this item?"
              onConfirm={() => onDelete(record)}
              okText="Yes"
              cancelText="No"
            >
              <Button
                type="link"
                danger
                icon={<DeleteOutlined />}
                size="small"
              >
                Delete
              </Button>
            </Popconfirm>
          )}
        </Space>
      ),
    });
  }

  const allColumns = [...columns, ...actionColumns];

  if (isLoading) {
    return <Skeleton active />;
  }

  return <Table<T> columns={allColumns} className="resource-table" {...tableProps} />;
}
