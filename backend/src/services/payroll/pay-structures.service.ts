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

export const payrollPayStructuresService = {
  listPayStructures: (farmOwnerId: string) =>
    payrollRepo.listPayStructures(farmOwnerId),

  createPayStructure: async (
    farmOwnerId: string,
    input: z.infer<typeof createPayStructureSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPayStructure({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  updatePayStructure: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updatePayStructureSchema>,
  ) => {
    await payrollRepo.updatePayStructure(farmOwnerId, id, input);
  },

  // Garnishee orders
  listGarnisheeOrders: (farmOwnerId: string) =>
    payrollRepo.listGarnisheeOrders(farmOwnerId),

  createGarnisheeOrder: async (
    farmOwnerId: string,
    input: z.infer<typeof createGarnisheeOrderSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createGarnisheeOrder({
      id,
      farmOwnerId,
      ...input,
      isActive: true,
      createdAt: new Date(),
    });
    return id;
  },

  updateGarnisheeOrder: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateGarnisheeOrderSchema>,
  ) => {
    await payrollRepo.updateGarnisheeOrder(farmOwnerId, id, input);
  },
};

