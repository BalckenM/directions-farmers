import crypto, { randomUUID } from "crypto";
import { count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import { auditLogs } from "../db/schema";
import { parsePagination } from "../lib/pagination";
import { authRepo } from "../repositories/auth.repo";
import { farmRepo } from "../repositories/farm.repo";
import type {
    CreatePaddockInput,
    InviteStaffInput,
    UpdatePaddockInput,
    UpdateStaffInput,
} from "../validators/farm.validator";
import { emailService } from "./email.service";

export const farmService = {
  // ── Team ───────────────────────────────────────────────────────────────────

  getTeam: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await farmRepo.listStaff(farmOwnerId, offset, limit);
    const data = rows.map(({ passwordHash: _pw, ...rest }) => rest);
    return { data, meta: { page, limit, total: Number(total) } };
  },

  inviteStaff: async (farmOwnerId: string, input: InviteStaffInput) => {
    const existing = await authRepo.findStaffByEmail(input.email);
    if (existing)
      throw Object.assign(new Error("Email already in use"), {
        status: 409,
        code: "EMAIL_IN_USE",
      });

    const token = crypto.randomBytes(32).toString("hex");
    await authRepo.saveInviteToken({
      id: randomUUID(),
      farmOwnerId,
      email: input.email,
      role: input.role,
      token,
      expiresAt: new Date(Date.now() + 7 * 86400_000),
      createdAt: new Date(),
    });

    emailService
      .sendStaffInviteEmail(input.email, token, farmOwnerId)
      .catch(() => undefined);

    return { email: input.email, role: input.role };
  },

  updateStaff: async (
    farmOwnerId: string,
    staffId: string,
    input: UpdateStaffInput,
  ) => {
    const member = await farmRepo.findStaffById(farmOwnerId, staffId);
    if (!member)
      throw Object.assign(new Error("Staff member not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    await farmRepo.updateStaff(farmOwnerId, staffId, input as Record<string, unknown>);
    const updated = await farmRepo.findStaffById(farmOwnerId, staffId);
    const { passwordHash: _pw, ...safe } = updated!;
    return safe;
  },

  deactivateStaff: async (farmOwnerId: string, staffId: string) => {
    const member = await farmRepo.findStaffById(farmOwnerId, staffId);
    if (!member)
      throw Object.assign(new Error("Staff member not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    await farmRepo.deactivateStaff(farmOwnerId, staffId);
  },

  // ── Paddocks ───────────────────────────────────────────────────────────────

  getPaddocks: (farmOwnerId: string) => farmRepo.listPaddocks(farmOwnerId),

  createPaddock: async (farmOwnerId: string, input: CreatePaddockInput) => {
    const id = randomUUID();
    await farmRepo.createPaddock({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return farmRepo.findPaddockById(farmOwnerId, id);
  },

  updatePaddock: async (
    farmOwnerId: string,
    paddockId: string,
    input: UpdatePaddockInput,
  ) => {
    const paddock = await farmRepo.findPaddockById(farmOwnerId, paddockId);
    if (!paddock)
      throw Object.assign(new Error("Paddock not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    await farmRepo.updatePaddock(farmOwnerId, paddockId, input as Record<string, unknown>);
    return farmRepo.findPaddockById(farmOwnerId, paddockId);
  },

  deletePaddock: async (farmOwnerId: string, paddockId: string) => {
    const paddock = await farmRepo.findPaddockById(farmOwnerId, paddockId);
    if (!paddock)
      throw Object.assign(new Error("Paddock not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    await farmRepo.deletePaddock(farmOwnerId, paddockId);
  },

  getActivityLog: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const [totalRow] = await db
      .select({ value: count() })
      .from(auditLogs)
      .where(eq(auditLogs.farmOwnerId, farmOwnerId));
    const total = totalRow?.value ?? 0;
    const rows = await db
      .select()
      .from(auditLogs)
      .where(eq(auditLogs.farmOwnerId, farmOwnerId))
      .orderBy(desc(auditLogs.createdAt))
      .limit(limit)
      .offset(offset);
    return { data: rows, meta: { page, limit, total } };
  },
};
