import { z } from "zod";

export const createTransactionSchema = z
  .object({
    type: z.enum(["income", "expense"]),
    category: z.string().min(1).max(50),
    description: z.string().max(255).optional(),
    amount: z.number().positive(),
    transactionDate: z.string().date(),
    reference: z.string().max(100).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateTransactionSchema = createTransactionSchema.partial();

export type CreateTransactionInput = z.infer<typeof createTransactionSchema>;
export type UpdateTransactionInput = z.infer<typeof updateTransactionSchema>;
