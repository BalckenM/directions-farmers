import { payrollRepo } from "../../repositories/payroll/payroll.repo";

function mapContractType(v: string | null | undefined): string {
  if (!v) return "permanent";
  const map: Record<string, string> = {
    permanent: "permanent",
    fixed_term: "fixedTerm",
    fixedTerm: "fixedTerm",
    seasonal: "seasonal",
    casual: "casual",
  };
  return map[v] ?? v;
}

function mapContractStatus(v: string | null | undefined): string {
  if (!v) return "draft";
  const map: Record<string, string> = {
    active: "signed",
    signed: "signed",
    inactive: "expired",
    expired: "expired",
    terminated: "terminated",
    draft: "draft",
  };
  return map[v] ?? v;
}

function mapContractRow(row: Record<string, unknown>): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  return {
    id: row.id,
    employeeId: row.employeeId,
    type: mapContractType(row.contractType as string | null),
    startDate: toIso(row.startDate),
    endDate: toIso(row.endDate) ?? null,
    grossMonthlySalary: parseFloat(String(row.baseSalary ?? 0)),
    currency: row.currency ?? "ZAR",
    status: mapContractStatus(row.status as string | null),
    jobDescription: (row.jobDescription as string | null) ?? "",
    signedAt: toIso(row.signedAt) ?? null,
    signedByName: row.signedByName ?? null,
    signatureImageBase64: row.signatureImageBase64 ?? null,
    pdfPath: row.pdfPath ?? null,
    version: Number(row.version ?? 1),
    createdAt: toIso(row.createdAt),
  };
}

export const payrollContractsFlatService = {
  listAllContracts: (farmOwnerId: string) =>
    payrollRepo
      .listAllContracts(farmOwnerId)
      .then((rows) =>
        rows.map((r) => mapContractRow(r as Record<string, unknown>)),
      ),

  voidContract: async (farmOwnerId: string, id: string, reason: string) => {
    await payrollRepo.voidContract(farmOwnerId, id, {
      status: "voided",
      notes: reason,
    } as never);
  },
};
