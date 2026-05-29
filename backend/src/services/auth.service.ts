import crypto, { randomUUID } from "crypto";
import type { z } from "zod";
import { signAccessToken, signRefreshToken, verifyToken } from "../lib/jwt";
import { hashPassword, verifyPassword } from "../lib/password";
import { authRepo } from "../repositories/auth.repo";
import type {
  acceptInviteSchema,
  loginSchema,
  registerSchema,
} from "../validators/auth.validator";
import { emailService } from "./email.service";
import { subscriptionService } from "./subscription.service";

function generateToken(): string {
  return crypto.randomBytes(32).toString("hex");
}

function hashTokenValue(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

export const authService = {
  register: async (input: z.infer<typeof registerSchema>) => {
    const existing = await authRepo.findOwnerByEmail(input.email);
    if (existing)
      throw Object.assign(new Error("Email already registered"), {
        status: 409,
        code: "EMAIL_IN_USE",
      });

    const passwordHash = await hashPassword(input.password);
    const id = randomUUID();
    await authRepo.createOwner({
      id,
      email: input.email,
      passwordHash,
      firstName: input.firstName,
      lastName: input.lastName,
      phone: input.phone,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const verifyToken_ = generateToken();
    await authRepo.saveEmailVerificationToken({
      id: randomUUID(),
      userId: id,
      token: verifyToken_,
      expiresAt: new Date(Date.now() + 86400_000),
      createdAt: new Date(),
    });
    emailService
      .sendVerificationEmail(input.email, verifyToken_)
      .catch(() => undefined);

    // New owners have no modules yet — modules[] populated after subscription setup
    const accessToken = await signAccessToken({
      sub: id,
      subType: "owner",
      farmId: id,
      role: "owner",
      modules: [],
    });
    const refreshToken = await signRefreshToken({
      sub: id,
      subType: "owner",
    });
    const rtHash = hashTokenValue(refreshToken);
    await authRepo.saveRefreshToken({
      id: randomUUID(),
      userId: id,
      userType: "owner",
      tokenHash: rtHash,
      expiresAt: new Date(Date.now() + 30 * 86400_000),
      createdAt: new Date(),
    });

    return { accessToken, refreshToken };
  },

  login: async (input: z.infer<typeof loginSchema>) => {
    const owner = await authRepo.findOwnerByEmail(input.email);
    if (!owner)
      throw Object.assign(new Error("Invalid credentials"), {
        status: 401,
        code: "INVALID_CREDENTIALS",
      });

    const valid = await verifyPassword(input.password, owner.passwordHash);
    if (!valid)
      throw Object.assign(new Error("Invalid credentials"), {
        status: 401,
        code: "INVALID_CREDENTIALS",
      });

    // Embed activated modules so requireModule() middleware works without a DB hit per request
    const modules = await subscriptionService.getModulesForFarm(owner.id);

    const accessToken = await signAccessToken({
      sub: owner.id,
      subType: "owner",
      farmId: owner.id,
      role: "owner",
      modules,
    });
    const refreshToken = await signRefreshToken({
      sub: owner.id,
      subType: "owner",
    });
    const rtHash = hashTokenValue(refreshToken);
    await authRepo.saveRefreshToken({
      id: randomUUID(),
      userId: owner.id,
      userType: "owner",
      tokenHash: rtHash,
      expiresAt: new Date(Date.now() + 30 * 86400_000),
      createdAt: new Date(),
    });

    return { accessToken, refreshToken };
  },

  refresh: async (incomingRefreshToken: string) => {
    const payload = await verifyToken(incomingRefreshToken).catch(() => null);
    if (!payload)
      throw Object.assign(new Error("Invalid token"), {
        status: 401,
        code: "INVALID_TOKEN",
      });

    const tokenHash = hashTokenValue(incomingRefreshToken);
    const stored = await authRepo.findRefreshToken(tokenHash);
    if (!stored)
      throw Object.assign(new Error("Token not found"), {
        status: 401,
        code: "INVALID_TOKEN",
      });

    await authRepo.deleteRefreshToken(stored.id);

    // Re-hydrate modules from DB so any plan changes take effect on next refresh
    const modules = await subscriptionService.getModulesForFarm(payload.sub);

    const accessToken = await signAccessToken({
      sub: payload.sub,
      subType: payload.subType,
      farmId: payload.farmId,
      role: payload.role,
      modules,
    });
    const newRefreshToken = await signRefreshToken({
      sub: payload.sub,
      subType: payload.subType,
    });
    const rtHash = hashTokenValue(newRefreshToken);
    await authRepo.saveRefreshToken({
      id: randomUUID(),
      userId: stored.userId,
      userType: stored.userType,
      tokenHash: rtHash,
      expiresAt: new Date(Date.now() + 30 * 86400_000),
      createdAt: new Date(),
    });

    return { accessToken, refreshToken: newRefreshToken };
  },

  logout: async (refreshToken: string) => {
    const tokenHash = hashTokenValue(refreshToken);
    const stored = await authRepo.findRefreshToken(tokenHash);
    if (stored) await authRepo.deleteRefreshToken(stored.id);
  },

  forgotPassword: async (email: string) => {
    const owner = await authRepo.findOwnerByEmail(email);
    if (!owner) return; // silent no-op prevents email enumeration
    const token = generateToken();
    await authRepo.savePasswordResetToken({
      id: randomUUID(),
      userId: owner.id,
      userType: "owner",
      token,
      expiresAt: new Date(Date.now() + 3600_000),
      createdAt: new Date(),
    });
    emailService.sendPasswordResetEmail(email, token).catch(() => undefined);
  },

  resetPassword: async (token: string, newPassword: string) => {
    const record = await authRepo.findPasswordResetToken(token);
    if (!record || record.usedAt || record.expiresAt < new Date()) {
      throw Object.assign(new Error("Invalid or expired token"), {
        status: 400,
        code: "INVALID_TOKEN",
      });
    }
    const passwordHash = await hashPassword(newPassword);
    await Promise.all([
      authRepo.updateOwnerPassword(record.userId, passwordHash),
      authRepo.markResetTokenUsed(record.id),
    ]);
  },

  verifyEmail: async (token: string) => {
    const record = await authRepo.findEmailVerificationToken(token);
    if (!record || record.usedAt || record.expiresAt < new Date()) {
      throw Object.assign(new Error("Invalid or expired token"), {
        status: 400,
        code: "INVALID_TOKEN",
      });
    }
    await Promise.all([
      authRepo.setEmailVerified(record.userId, new Date()),
      authRepo.markEmailTokenUsed(record.id),
    ]);
  },

  acceptInvite: async (input: z.infer<typeof acceptInviteSchema>) => {
    const record = await authRepo.findInviteToken(input.token);
    if (!record || record.acceptedAt || record.expiresAt < new Date()) {
      throw Object.assign(new Error("Invalid or expired invite"), {
        status: 400,
        code: "INVALID_TOKEN",
      });
    }

    const existing = await authRepo.findStaffByEmail(record.email);
    if (existing)
      throw Object.assign(new Error("Email already registered"), {
        status: 409,
        code: "EMAIL_IN_USE",
      });

    const passwordHash = await hashPassword(input.password);
    const staffId = randomUUID();
    await authRepo.createStaff({
      id: staffId,
      farmOwnerId: record.farmOwnerId,
      email: record.email,
      passwordHash,
      firstName: input.firstName,
      lastName: input.lastName,
      role: record.role,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await authRepo.markInviteTokenUsed(record.id);

    // Staff inherit the farm owner's activated modules
    const modules = await subscriptionService.getModulesForFarm(record.farmOwnerId);

    const accessToken = await signAccessToken({
      sub: staffId,
      subType: "staff",
      farmId: record.farmOwnerId,
      role: record.role,
      modules,
    });
    const refreshToken = await signRefreshToken({
      sub: staffId,
      subType: "staff",
    });
    const rtHash = hashTokenValue(refreshToken);
    await authRepo.saveRefreshToken({
      id: randomUUID(),
      userId: staffId,
      userType: "staff",
      tokenHash: rtHash,
      expiresAt: new Date(Date.now() + 30 * 86400_000),
      createdAt: new Date(),
    });

    return { accessToken, refreshToken };
  },
};
