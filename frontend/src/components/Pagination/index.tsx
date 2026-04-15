/**
 * Generic Pagination Component
 * Renders Ant Design Pagination with URL query parameter updates
 */

import { Pagination } from 'antd';

export interface PaginationMeta {
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
}

export interface ResourcePaginationProps {
  meta: PaginationMeta;
  onPageChange: (page: number, pageSize: number) => void;
}

export function ResourcePagination({ meta, onPageChange }: ResourcePaginationProps) {
  const { page, perPage, total } = meta;

  return (
    <Pagination
      className="resource-pagination"
      current={page}
      pageSize={perPage}
      total={total}
      onChange={onPageChange}
      showLessItems
      showSizeChanger
      showTotal={(total) => `Total ${total} items`}
      pageSizeOptions={['10', '20', '50']}
      style={{ marginTop: 16, textAlign: 'right' }}
    />
  );
}
