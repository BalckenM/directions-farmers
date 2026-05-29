import { z } from "zod";

export const inviteStaffSchema = z
  .object({
    email: z.string().email().max(255),
    role: z.enum(["staff", "manager"]).default("staff"),
  })
  .strict();

export const updateStaffSchema = z
  .object({
    firstName: z.string().min(1).max(100).optional(),
    lastName: z.string().min(1).max(100).optional(),
    role: z.enum(["staff", "manager"]).optional(),
  })
  .strict();

export const createPaddockSchema = z
  .object({
    name: z.string().min(1).max(100),
    description: z.string().max(500).optional(),
    coordinates: z.record(z.unknown()).optional(),
  })
  .strict();

export const updatePaddockSchema = createPaddockSchema.partial();

export type InviteStaffInput = z.infer<typeof inviteStaffSchema>;
export type UpdateStaffInput = z.infer<typeof updateStaffSchema>;
export type CreatePaddockInput = z.infer<typeof createPaddockSchema>;
export type UpdatePaddockInput = z.infer<typeof updatePaddockSchema>;
