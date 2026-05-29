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

export const payrollCommunicationsService = {
  listCommunications: (farmOwnerId: string) =>
    payrollRepo.listCommunications(farmOwnerId),

  sendCommunication: async (
    farmOwnerId: string,
    input: z.infer<typeof sendCommunicationSchema>,
  ) => {
    const id = randomUUID();
    const now = new Date();
    await payrollRepo.createCommunication({
      id,
      farmOwnerId,
      ...input,
      sentAt: now,
      createdAt: now,
    });
    return id;
  },
};

