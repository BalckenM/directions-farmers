import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type { sendCommunicationSchema } from "../../validators/payroll/payroll.validator";

function mapCommunicationRow(
  row: Record<string, unknown>,
): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  let recipientEmployeeIds: string[] | null = null;
  if (
    row.recipientEmployeeIds &&
    typeof row.recipientEmployeeIds === "string"
  ) {
    try {
      recipientEmployeeIds = JSON.parse(row.recipientEmployeeIds) as string[];
    } catch {
      recipientEmployeeIds = null;
    }
  }
  const channelMap: Record<string, string> = {
    sms: "sms",
    whatsapp: "whatsapp",
    email: "email",
    inApp: "inApp",
    in_app: "inApp",
    push: "push",
    system: "inApp",
  };
  return {
    id: row.id,
    channel: channelMap[row.channel as string] ?? "inApp",
    templateCode: (row.templateCode as string | null) ?? "",
    subject: (row.subject as string | null) ?? "",
    body: (row.body as string | null) ?? "",
    recipientEmployeeIds: recipientEmployeeIds ?? [],
    sentByUserId: (row.sentByUserId as string | null) ?? "",
    deliveredCount: Number(row.deliveredCount ?? 0),
    failedCount: Number(row.failedCount ?? 0),
    sentAt:
      toIso(row.sentAt) ?? toIso(row.createdAt) ?? new Date().toISOString(),
    createdAt: toIso(row.createdAt),
  };
}

export const payrollCommunicationsService = {
  listCommunications: (farmOwnerId: string) =>
    payrollRepo
      .listCommunications(farmOwnerId)
      .then((rows) =>
        (rows as Record<string, unknown>[]).map(mapCommunicationRow),
      ),

  sendCommunication: async (
    farmOwnerId: string,
    input: z.infer<typeof sendCommunicationSchema>,
  ) => {
    const id = randomUUID();
    const now = new Date();
    await payrollRepo.createCommunication({
      id,
      farmOwnerId,
      channel: "system",
      body: input.message,
      subject: input.subject ?? null,
      sentAt: now,
      createdAt: now,
    });
    return id;
  },
};
