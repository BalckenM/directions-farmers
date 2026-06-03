import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
  createEmployeeSchema,
  updateEmployeeSchema,
} from "../../validators/payroll/payroll.validator";

import { payrollService } from "./payroll.service";

// Map DB engagement_type values to Flutter EngagementType enum names
function mapEngagementType(v: string | null | undefined): string {
  if (!v) return "casual";
  const map: Record<string, string> = {
    Permanent: "permanent",
    permanent: "permanent",
    Seasonal: "seasonal",
    seasonal: "seasonal",
    Casual: "casual",
    casual: "casual",
    Contract: "contractor",
    contract: "contractor",
    Contractor: "contractor",
    contractor: "contractor",
  };
  return map[v] ?? "casual";
}

// Map DB disbursement_method values to Flutter DisbursementMethod enum names
function mapDisbursementMethod(v: string | null | undefined): string {
  if (!v) return "cash";
  const map: Record<string, string> = {
    bank_transfer: "bank",
    bank: "bank",
    Bank: "bank",
    cash: "cash",
    Cash: "cash",
    mtn_ewallet: "mtnEwallet",
    mtnEwallet: "mtnEwallet",
    orange_money: "orangeMoney",
    orangeMoney: "orangeMoney",
  };
  return map[v] ?? "cash";
}

// Transform raw DB row to Flutter PayrollEmployee.fromJson-compatible shape
function mapEmployeeRow(row: Record<string, unknown>): Record<string, unknown> {
  return {
    id: row.id,
    firstName: row.firstName,
    lastName: row.lastName,
    idOrPassportNumber: (row.idNumber as string | null) ?? "",
    phone: row.phone ?? null,
    email: row.email ?? null,
    address: (row.address as string | null) ?? "",
    nextOfKinName: (row.nextOfKinName as string | null) ?? "",
    nextOfKinPhone: (row.nextOfKinPhone as string | null) ?? "",
    status: (row.isActive as boolean | null) === false ? "inactive" : "active",
    engagementType: mapEngagementType(row.engagementType as string | null),
    occupationTitle: (row.occupationTitle as string | null) ?? "",
    payGroupId: row.payGroupId ?? null,
    payStructureId: row.payStructureId ?? null,
    startDate: row.startDate,
    endDate: row.endDate ?? null,
    bankName: row.bankName ?? null,
    bankAccountNumber: row.bankAccountNumber ?? null,
    bankBranchCode: row.bankBranchCode ?? null,
    disbursementMethod: mapDisbursementMethod(
      row.disbursementMethod as string | null,
    ),
    preferredLanguage: (row.preferredLanguage as string | null) ?? "",
    hasHousingBenefit: row.hasHousingBenefit ?? false,
    housingValuePerMonth: row.housingValuePerMonth ?? null,
    hasFoodBenefit: row.hasFoodBenefit ?? false,
    foodValuePerMonth: row.foodValuePerMonth ?? null,
    dateOfBirth: row.dateOfBirth ?? null,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  };
}

export const payrollEmployeesService = {
  listEmployees: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return payrollRepo
      .listEmployees(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        rows: rows.map((r) => mapEmployeeRow(r as Record<string, unknown>)),
        meta: { page, limit, total: Number(total) },
      }));
  },

  getEmployee: async (farmOwnerId: string, id: string) => {
    const emp = await payrollRepo.findEmployeeById(farmOwnerId, id);
    if (!emp)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return mapEmployeeRow(emp as Record<string, unknown>);
  },

  createEmployee: async (
    farmOwnerId: string,
    input: z.infer<typeof createEmployeeSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createEmployee({
      id,
      farmOwnerId,
      ...input,
      startDate: new Date(input.startDate),
      endDate: input.endDate ? new Date(input.endDate) : undefined,
      dateOfBirth: input.dateOfBirth ? new Date(input.dateOfBirth) : undefined,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return payrollRepo.findEmployeeById(farmOwnerId, id);
  },

  updateEmployee: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateEmployeeSchema>,
  ) => {
    await payrollService.getEmployee(farmOwnerId, id);
    await payrollRepo.updateEmployee(farmOwnerId, id, {
      ...input,
      startDate: input.startDate ? new Date(input.startDate) : undefined,
      endDate: input.endDate ? new Date(input.endDate) : undefined,
      dateOfBirth: input.dateOfBirth ? new Date(input.dateOfBirth) : undefined,
    });
    return payrollRepo.findEmployeeById(farmOwnerId, id);
  },

  deleteEmployee: async (farmOwnerId: string, id: string) => {
    await payrollService.getEmployee(farmOwnerId, id);
    await payrollRepo.deleteEmployee(farmOwnerId, id);
  },
};
