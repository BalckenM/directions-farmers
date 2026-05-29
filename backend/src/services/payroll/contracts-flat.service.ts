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

export const payrollContractsFlatService = {
  listAllContracts: (farmOwnerId: string) =>
    payrollRepo.listAllContracts(farmOwnerId),

  voidContract: async (farmOwnerId: string, id: string, reason: string) => {
    await payrollRepo.voidContract(farmOwnerId, id, {
      status: "voided",
      notes: reason,
    } as never);
  },
};

