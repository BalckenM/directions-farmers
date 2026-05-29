import { eq } from "drizzle-orm";
import { db } from "../config/database";
import {
  emailVerificationTokens,
  farmOwners,
  farmStaff,
  passwordResetTokens,
  refreshTokens,
  staffInviteTokens,
} from "../db/schema";

export const authRepo = {
  findOwnerByEmail: (email: string) =>
    db
      .select()
      .from(farmOwners)
      .where(eq(farmOwners.email, email))
      .then((r) => r[0] ?? null),

  findOwnerById: (id: string) =>
    db
      .select()
      .from(farmOwners)
      .where(eq(farmOwners.id, id))
      .then((r) => r[0] ?? null),

  createOwner: (data: typeof farmOwners.$inferInsert) =>
    db.insert(farmOwners).values(data),

  setEmailVerified: (id: string, verifiedAt: Date) =>
    db
      .update(farmOwners)
      .set({ emailVerifiedAt: verifiedAt })
      .where(eq(farmOwners.id, id)),

  updateOwnerPassword: (id: string, passwordHash: string) =>
    db
      .update(farmOwners)
      .set({ passwordHash, updatedAt: new Date() })
      .where(eq(farmOwners.id, id)),

  findStaffByEmail: (email: string) =>
    db
      .select()
      .from(farmStaff)
      .where(eq(farmStaff.email, email))
      .then((r) => r[0] ?? null),

  findStaffById: (id: string) =>
    db
      .select()
      .from(farmStaff)
      .where(eq(farmStaff.id, id))
      .then((r) => r[0] ?? null),

  createStaff: (data: typeof farmStaff.$inferInsert) =>
    db.insert(farmStaff).values(data),

  saveRefreshToken: (data: typeof refreshTokens.$inferInsert) =>
    db.insert(refreshTokens).values(data),

  findRefreshToken: (tokenHash: string) =>
    db
      .select()
      .from(refreshTokens)
      .where(eq(refreshTokens.tokenHash, tokenHash))
      .then((r) => r[0] ?? null),

  deleteRefreshToken: (id: string) =>
    db.delete(refreshTokens).where(eq(refreshTokens.id, id)),

  deleteAllUserRefreshTokens: (userId: string) =>
    db.delete(refreshTokens).where(eq(refreshTokens.userId, userId)),

  saveEmailVerificationToken: (
    data: typeof emailVerificationTokens.$inferInsert,
  ) => db.insert(emailVerificationTokens).values(data),

  findEmailVerificationToken: (token: string) =>
    db
      .select()
      .from(emailVerificationTokens)
      .where(eq(emailVerificationTokens.token, token))
      .then((r) => r[0] ?? null),

  markEmailTokenUsed: (id: string) =>
    db
      .update(emailVerificationTokens)
      .set({ usedAt: new Date() })
      .where(eq(emailVerificationTokens.id, id)),

  savePasswordResetToken: (data: typeof passwordResetTokens.$inferInsert) =>
    db.insert(passwordResetTokens).values(data),

  findPasswordResetToken: (token: string) =>
    db
      .select()
      .from(passwordResetTokens)
      .where(eq(passwordResetTokens.token, token))
      .then((r) => r[0] ?? null),

  markResetTokenUsed: (id: string) =>
    db
      .update(passwordResetTokens)
      .set({ usedAt: new Date() })
      .where(eq(passwordResetTokens.id, id)),

  saveInviteToken: (data: typeof staffInviteTokens.$inferInsert) =>
    db.insert(staffInviteTokens).values(data),

  findInviteToken: (token: string) =>
    db
      .select()
      .from(staffInviteTokens)
      .where(eq(staffInviteTokens.token, token))
      .then((r) => r[0] ?? null),

  markInviteTokenUsed: (id: string) =>
    db
      .update(staffInviteTokens)
      .set({ acceptedAt: new Date() })
      .where(eq(staffInviteTokens.id, id)),
};
