'use client';

import { useMemo, useState } from 'react';
import { Button, Space, Statistic, Typography } from 'antd';
import { PageContainer, ProCard } from '@ant-design/pro-components';
import { PlusOutlined } from '@ant-design/icons';
import { ResourceFormDialog } from '@/components/ResourceForm';
import { ResourcePagination } from '@/components/Pagination';
import { ResourceTable } from '@/components/ResourceTable';
import type { PaginationMeta } from '@/components/Pagination';
import type { ResourceMeta } from '@/config/resources';

const { Paragraph, Text, Title } = Typography;

interface CollectionResult<T> {
  data?: T[];
  meta?: Partial<PaginationMeta>;
}

interface ResourceWorkspaceProps<T extends Record<string, any>> {
  createPending?: boolean;
  data?: CollectionResult<T>;
  deletePending?: boolean;
  editTitle?: (record: T | null) => string;
  emptyDetail?: string;
  isLoading?: boolean;
  onCreate: (payload: T) => Promise<void>;
  onDelete: (record: T) => void;
  onEdit: (payload: { data: T; id: number | string }) => Promise<void>;
  onPageChange?: (page: number, pageSize: number) => void;
  page?: number;
  pageSize?: number;
  resource: ResourceMeta<T>;
}

function getTotal(data?: CollectionResult<unknown>) {
  if (typeof data?.meta?.total === 'number') {
    return data.meta.total;
  }

  return data?.data?.length || 0;
}

export function ResourceWorkspace<T extends Record<string, any>>({
  createPending,
  data,
  deletePending,
  editTitle,
  emptyDetail,
  isLoading,
  onCreate,
  onDelete,
  onEdit,
  onPageChange,
  page = 1,
  pageSize = 5,
  resource,
}: ResourceWorkspaceProps<T>) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingRecord, setEditingRecord] = useState<T | null>(null);

  const itemCount = getTotal(data);
  const tableRows = data?.data || [];
  const hasPagination = Boolean(data?.meta && onPageChange);
  const pageMeta = data?.meta;

  const stats = useMemo(
    () => [
      {
        label: 'Records',
        value: itemCount,
      },
      {
        label: 'Page',
        value: pageMeta?.page || page,
      },
      {
        label: 'Per Page',
        value: pageMeta?.perPage || pageSize,
      },
    ],
    [itemCount, pageMeta?.page, pageMeta?.perPage, page, pageSize]
  );

  const handleCreateClick = () => {
    setEditingRecord(null);
    setIsModalOpen(true);
  };

  const handleEditClick = (record: T) => {
    setEditingRecord(record);
    setIsModalOpen(true);
  };

  const handleSubmit = async (formData: T) => {
    if (editingRecord?.id) {
      await onEdit({ id: editingRecord.id, data: formData });
      return;
    }

    await onCreate(formData);
  };

  return (
    <PageContainer
      className="resource-workspace"
      ghost
      title={resource.title}
      subTitle={resource.kicker}
      extra={[
        <Button
          key="create"
          type="primary"
          size="large"
          icon={<PlusOutlined />}
          onClick={handleCreateClick}
          className="resource-workspace__primary-action"
        >
          {resource.createLabel}
        </Button>,
      ]}
      content={<Paragraph className="resource-workspace__subtitle">{resource.subtitle}</Paragraph>}
      footer={[]}
    >
      <ProCard ghost gutter={[16, 16]} className="resource-workspace__cards">
        {stats.map((stat) => (
          <ProCard key={stat.label} colSpan={{ xs: 24, md: 8 }} className="resource-workspace__stat-card" bordered>
            <Text className="resource-workspace__stat-label">{stat.label}</Text>
            <Statistic value={stat.value} styles={{ content: { fontSize: 28, fontWeight: 600 } }} />
          </ProCard>
        ))}
      </ProCard>

      <ProCard
        className="resource-workspace__table-panel"
        title={`${resource.title} records`}
        subTitle={
          tableRows.length > 0
            ? `Showing ${tableRows.length} visible records in the current result set.`
            : emptyDetail || resource.emptyState
        }
        extra={
          <Space size="middle" className="resource-workspace__table-summary">
            <Text>{itemCount} total</Text>
            {deletePending ? <Text type="secondary">Updating…</Text> : null}
          </Space>
        }
        bordered
      >
        <ResourceTable
          columns={resource.tableColumns}
          dataSource={tableRows}
          isLoading={isLoading}
          onEdit={handleEditClick}
          onDelete={onDelete}
          rowKey="id"
          locale={{
            emptyText: (
              <div className="resource-workspace__empty-state">
                <Title level={5}>Nothing here yet</Title>
                <Paragraph>{emptyDetail || resource.emptyState}</Paragraph>
              </div>
            ),
          }}
        />

        {hasPagination && pageMeta ? (
          <ResourcePagination
            meta={{
              page: pageMeta.page || 1,
              perPage: pageMeta.perPage || pageSize,
              total: pageMeta.total || tableRows.length,
              totalPages: pageMeta.totalPages || 1,
            }}
            onPageChange={onPageChange!}
          />
        ) : null}
      </ProCard>

      <ResourceFormDialog
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        schema={resource.formSchema}
        initialData={editingRecord || undefined}
        onSubmit={handleSubmit}
        title={editTitle ? editTitle(editingRecord) : editingRecord ? `Edit ${resource.title}` : resource.createLabel}
        resourceType={resource.key}
        isEdit={Boolean(editingRecord)}
        confirmLoading={createPending}
      />
    </PageContainer>
  );
}
