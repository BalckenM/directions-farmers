import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
  createIncidentSchema,
  updateIncidentSchema,
} from "../../validators/payroll/payroll.validator";

function mapIncidentRow(row: Record<string, unknown>): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  let documentPaths: string[] | null = null;
  if (row.documentPaths && typeof row.documentPaths === "string") {
    try {
      documentPaths = JSON.parse(row.documentPaths) as string[];
    } catch {
      documentPaths = null;
    }
  }
  return {
    id: row.id,
    employeeId: row.employeeId,
    type: row.type,
    title: (row.title as string | null) ?? "",
    description: (row.description as string | null) ?? "",
    incidentDate: toIso(row.incidentDate),
    status: row.status ?? "open",
    actionTaken: row.actionTaken ?? null,
    resolvedAt: toIso(row.resolvedAt) ?? null,
    resolvedByUserId: row.resolvedByUserId ?? null,
    documentPaths,
    reportedByUserId: (row.reportedByUserId as string | null) ?? "",
    createdAt: toIso(row.createdAt),
  };
}

export const payrollAuditService = {
  listAuditLog: (farmOwnerId: string) =>
    payrollRepo.listAuditLog(farmOwnerId).then((rows) =>
      (rows as Record<string, unknown>[]).map((row) => {
        const toIso = (v: unknown) =>
          v instanceof Date ? v.toISOString() : v ? String(v) : null;
        let beforeSnapshot: Record<string, unknown> | null = null;
        let afterSnapshot: Record<string, unknown> | null = null;
        if (row.oldValues && typeof row.oldValues === "string") {
          try {
            beforeSnapshot = JSON.parse(row.oldValues) as Record<
              string,
              unknown
            >;
          } catch {
            beforeSnapshot = null;
          }
        }
        if (row.newValues && typeof row.newValues === "string") {
          try {
            afterSnapshot = JSON.parse(row.newValues) as Record<
              string,
              unknown
            >;
          } catch {
            afterSnapshot = null;
          }
        }
        return {
          id: row.id,
          entityType: row.resourceType ?? "",
          entityId: (row.resourceId as string | null) ?? "",
          action: row.action ?? "",
          changedByUserId: (row.actorId as string | null) ?? "",
          changedByName: "",
          beforeSnapshot,
          afterSnapshot,
          description: null,
          occurredAt: toIso(row.createdAt),
        };
      }),
    ),

  // Incidents
  listIncidents: (farmOwnerId: string) =>
    payrollRepo
      .listIncidents(farmOwnerId)
      .then((rows) => (rows as Record<string, unknown>[]).map(mapIncidentRow)),

  createIncident: async (
    farmOwnerId: string,
    input: z.infer<typeof createIncidentSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createIncident({
      id,
      farmOwnerId,
      ...input,
      title: input.description.slice(0, 255),
      incidentDate: new Date(input.incidentDate),
      status: input.status ?? "open",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  updateIncident: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateIncidentSchema>,
  ) => {
    await payrollRepo.updateIncident(farmOwnerId, id, {
      ...input,
      incidentDate: input.incidentDate
        ? new Date(input.incidentDate)
        : undefined,
    });
  },
};
