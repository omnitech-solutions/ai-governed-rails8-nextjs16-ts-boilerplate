import type { Query, QueryClient } from '@tanstack/react-query';

function matchesOperation(query: Query, operationId: string) {
  const [first] = query.queryKey;

  return typeof first === 'object' && first !== null && '_id' in first && first._id === operationId;
}

export function invalidateOperation(queryClient: QueryClient, operationId: string) {
  return queryClient.invalidateQueries({
    predicate: (query) => matchesOperation(query, operationId),
  });
}
