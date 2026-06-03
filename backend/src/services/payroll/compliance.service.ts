import { payrollRepo } from "../../repositories/payroll/payroll.repo";

function mapComplianceRow(
  row: Record<string, unknown>,
): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  return {
    id: row.id,
    code: row.code,
    title: row.title,
    description: row.description ?? "",
    severity: row.severity,
    employeeId: row.employeeId ?? null,
    payRunId: row.payRunId ?? null,
    isResolved: Boolean(row.isResolved ?? false),
    resolvedByUserId: row.resolvedByUserId ?? null,
    resolvedAt: toIso(row.resolvedAt) ?? null,
    resolution: row.resolution ?? null,
    raisedAt: toIso(row.raisedAt) ?? toIso(row.createdAt),
  };
}

export const payrollComplianceService = {
  listComplianceAlerts: (farmOwnerId: string) =>
    payrollRepo
      .listComplianceAlerts(farmOwnerId)
      .then((rows) =>
        (rows as Record<string, unknown>[]).map(mapComplianceRow),
      ),

  resolveComplianceAlert: async (farmOwnerId: string, id: string) => {
    await payrollRepo.resolveComplianceAlert(farmOwnerId, id, {
      isResolved: true,
      resolvedAt: new Date(),
    });
  },
};
