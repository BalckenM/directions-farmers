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

export const payrollLeaveService = {
  listLeaveRequests: (farmOwnerId: string) =>
    payrollRepo.listLeaveRequests(farmOwnerId),

  createLeaveRequest: async (
    farmOwnerId: string,
    input: z.infer<typeof createLeaveRequestSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createLeaveRequest({
      id,
      farmOwnerId,
      ...input,
      status: "pending",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  approveLeaveRequest: async (farmOwnerId: string, id: string) => {
    await payrollRepo.updateLeaveRequest(farmOwnerId, id, {
      status: "approved",
    });
  },

  rejectLeaveRequest: async (farmOwnerId: string, id: string) => {
    await payrollRepo.updateLeaveRequest(farmOwnerId, id, {
      status: "rejected",
    });
  },

  deleteLeaveRequest: async (farmOwnerId: string, id: string) => {
    await payrollRepo.deleteLeaveRequest(farmOwnerId, id);
  },

  listLeaveTypes: (farmOwnerId: string) =>
    payrollRepo.listLeaveTypes(farmOwnerId),

  // Piecework
  listPieceworkLogs: (farmOwnerId: string) =>
    payrollRepo.listPieceworkLogs(farmOwnerId),

  createPieceworkLog: async (
    farmOwnerId: string,
    input: z.infer<typeof createPieceworkLogSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPieceworkLog({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },

  deletePieceworkLog: async (farmOwnerId: string, id: string) => {
    await payrollRepo.deletePieceworkLog(farmOwnerId, id);
  },

  // Transactions
  listTransactions: (farmOwnerId: string) =>
    payrollRepo.listTransactions(farmOwnerId),
};

