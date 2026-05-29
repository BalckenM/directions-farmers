import { z } from "zod";

export const paginationSchema = z
  .object({
    page: z.coerce.number().int().positive().default(1),
    limit: z.coerce.number().int().positive().max(100).default(20),
  })
  .strict();

export const uuidParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export type PaginationQuery = z.infer<typeof paginationSchema>;
export type UuidParam = z.infer<typeof uuidParamSchema>;
