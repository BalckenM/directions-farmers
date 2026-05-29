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

export const payrollDeductionsService = {
  listDeductionRules: (farmOwnerId: string) =>
    payrollRepo.listDeductionRules(farmOwnerId),

  createDeductionRule: async (
    farmOwnerId: string,
    input: z.infer<typeof createDeductionRuleSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createDeductionRule({
      id,
      farmOwnerId,
      ...input,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  updateDeductionRule: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateDeductionRuleSchema>,
  ) => {
    await payrollRepo.updateDeductionRule(farmOwnerId, id, input);
  },

  deactivateDeductionRule: async (farmOwnerId: string, id: string) => {
    await payrollRepo.deactivateDeductionRule(farmOwnerId, id);
  },
};

