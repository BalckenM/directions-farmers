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

export const payrollPayRunsService = {
  listPayRuns: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return payrollRepo
      .listPayRuns(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getPayRun: async (farmOwnerId: string, id: string) => {
    const run = await payrollRepo.findPayRunById(farmOwnerId, id);
    if (!run)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return run;
  },

  createPayRun: async (
    farmOwnerId: string,
    input: z.infer<typeof createPayRunSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPayRun({
      id,
      farmOwnerId,
      ...input,
      status: "draft",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return payrollRepo.findPayRunById(farmOwnerId, id);
  },

  finalizePayRun: async (farmOwnerId: string, id: string) => {
    await payrollService.getPayRun(farmOwnerId, id);
    await payrollRepo.updatePayRun(farmOwnerId, id, { status: "finalized" });
    return payrollRepo.findPayRunById(farmOwnerId, id);
  },
};

