import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
    createContractSchema,
    createDeductionRuleSchema,
    createEmployeeSchema,
    createGarnisheeOrderSchema,
    createIncidentSchema,
    createLeaveRequestSchema,
    createPayGroupSchema,
    createPayRunSchema,
    createPayStructureSchema,
    createPieceworkLogSchema,
    sendCommunicationSchema,
    updateDeductionRuleSchema,
    updateEmployeeSchema,
    updateGarnisheeOrderSchema,
    updateIncidentSchema,
    updatePayGroupSchema,
    updatePayStructureSchema,
} from "../../validators/payroll.validator";

import { payrollService } from "./payroll.service";

export const payrollEmployeesService = {
  listEmployees: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return payrollRepo
      .listEmployees(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        rows,
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
    return emp;
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
    await payrollRepo.updateEmployee(farmOwnerId, id, input);
    return payrollRepo.findEmployeeById(farmOwnerId, id);
  },

  deleteEmployee: async (farmOwnerId: string, id: string) => {
    await payrollService.getEmployee(farmOwnerId, id);
    await payrollRepo.deleteEmployee(farmOwnerId, id);
  },
};

