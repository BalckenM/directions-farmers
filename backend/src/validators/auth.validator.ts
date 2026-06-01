import { z } from "zod";

export const registerSchema = z
  .object({
    firstName: z.string().min(1).max(100),
    lastName: z.string().min(1).max(100),
    email: z.string().email().max(255),
    password: z.string().min(8).max(128),
    phone: z.string().max(20).optional(),
    farmName: z.string().min(1).max(200).optional(),
    country: z.string().min(1).max(100).optional(),
    province: z.string().min(1).max(100).optional(),
    subscriptionPlan: z.string().min(1).max(50).optional(),
    activatedModules: z.array(z.string().max(50)).optional(),
  })
  .strict();

export const loginSchema = z
  .object({
    email: z.string().email(),
    password: z.string().min(1),
  })
  .strict();

export const refreshSchema = z
  .object({
    refreshToken: z.string().min(1),
  })
  .strict();

export const forgotPasswordSchema = z
  .object({
    email: z.string().email(),
  })
  .strict();

export const resetPasswordSchema = z
  .object({
    token: z.string().min(1),
    password: z.string().min(8).max(128),
  })
  .strict();

export const acceptInviteSchema = z
  .object({
    token: z.string().min(1),
    firstName: z.string().min(1).max(100),
    lastName: z.string().min(1).max(100),
    password: z.string().min(8).max(128),
  })
  .strict();

export const changePasswordSchema = z
  .object({
    currentPassword: z.string().min(1),
    newPassword: z.string().min(8).max(128),
  })
  .strict();

export const updateProfileSchema = z
  .object({
    firstName: z.string().min(1).max(100).optional(),
    lastName: z.string().min(1).max(100).optional(),
    farmName: z.string().min(1).max(200).optional(),
    country: z.string().min(1).max(100).optional(),
    province: z.string().min(1).max(100).optional(),
    phone: z.string().max(20).optional(),
  })
  .strict();

export const socialAuthSchema = z
  .object({
    provider: z.enum(["google", "apple", "facebook"]),
    idToken: z.string().min(1),
  })
  .strict();

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshInput = z.infer<typeof refreshSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type AcceptInviteInput = z.infer<typeof acceptInviteSchema>;
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type SocialAuthInput = z.infer<typeof socialAuthSchema>;
