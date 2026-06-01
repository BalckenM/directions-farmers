export interface PaginationParams {
  page: number;
  limit: number;
  offset: number;
}

export function parsePagination(
  query: Record<string, unknown>,
): PaginationParams {
  const page = Math.max(1, Number(query["page"]) || 1);
  const rawLimit = Number(query["limit"]);
  const limit = Math.min(100, Math.max(1, Number.isNaN(rawLimit) ? 20 : rawLimit));
  return { page, limit, offset: (page - 1) * limit };
}
