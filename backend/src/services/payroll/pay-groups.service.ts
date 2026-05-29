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

export const payrollPayGroupsService = {
  listPayGroups: (farmOwnerId: string) =>
    payrollRepo.listPayGroups(farmOwnerId),

  createPayGroup: async (
    farmOwnerId: string,
    input: z.infer<typeof createPayGroupSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPayGroup({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },

  updatePayGroup: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updatePayGroupSchema>,
  ) => {
    await payrollRepo.updatePayGroup(farmOwnerId, id, input);
  },
};

