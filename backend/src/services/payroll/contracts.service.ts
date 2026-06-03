import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type { createContractSchema } from "../../validators/payroll/payroll.validator";

/** Map DB contract_type values to Flutter ContractType enum names. */
function mapContractType(v: unknown): string {
  switch (String(v ?? "").toLowerCase()) {
    case "permanent":
      return "permanent";
    case "seasonal":
      return "seasonal";
    case "casual":
      return "casual";
    case "fixed_term":
    case "fixedterm":
    case "contract":
    default:
      return "fixedTerm";
  }
}

/** Map DB status values to Flutter ContractStatus enum names. */
function mapContractStatus(v: unknown): string {
  switch (String(v ?? "").toLowerCase()) {
    case "signed":
    case "active":
      return "signed";
    case "draft":
      return "draft";
    case "expired":
    case "inactive":
      return "expired";
    case "terminated":
      return "terminated";
    default:
      return "signed";
  }
}

function mapContractRow(row: Record<string, unknown>): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  return {
    id: row.id,
    employeeId: row.employeeId,
    type: mapContractType(row.contractType),
    startDate: toIso(row.startDate),
    endDate: toIso(row.endDate) ?? null,
    jobDescription: (row.jobDescription as string | null) ?? "",
    grossMonthlySalary: parseFloat(String(row.baseSalary ?? 0)),
    currency: (row.currency as string | null) ?? "ZAR",
    status: mapContractStatus(row.status),
    signedAt: toIso(row.signedAt) ?? null,
    signedByName: (row.signedByName as string | null) ?? null,
    signatureImageBase64: (row.signatureImageBase64 as string | null) ?? null,
    pdfPath: (row.pdfPath as string | null) ?? null,
    version: (row.version as number | null) ?? 1,
    createdAt: toIso(row.createdAt),
  };
}

export const payrollContractsService = {
  listContracts: (farmOwnerId: string, employeeId: string) =>
    payrollRepo
      .listContracts(farmOwnerId, employeeId)
      .then((rows) => (rows as Record<string, unknown>[]).map(mapContractRow)),

  createContract: async (
    farmOwnerId: string,
    input: z.infer<typeof createContractSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createContract({
      id,
      farmOwnerId,
      ...input,
      startDate: new Date(input.startDate),
      endDate: input.endDate ? new Date(input.endDate) : undefined,
      baseSalary: String(input.baseSalary),
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  getContract: async (farmOwnerId: string, id: string) => {
    const contract = await payrollRepo.findContractById(farmOwnerId, id);
    if (!contract)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return contract;
  },

  updateContract: async (
    farmOwnerId: string,
    id: string,
    input: Record<string, unknown>,
  ) => {
    await payrollRepo.findContractById(farmOwnerId, id).then((c) => {
      if (!c)
        throw Object.assign(new Error("Not found"), {
          status: 404,
          code: "NOT_FOUND",
        });
    });
    await payrollRepo.updateContract(farmOwnerId, id, input);
    return payrollRepo.findContractById(farmOwnerId, id);
  },
};
