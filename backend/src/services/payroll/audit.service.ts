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

export const payrollAuditService = {
  listAuditLog: (farmOwnerId: string) => payrollRepo.listAuditLog(farmOwnerId),

  // Incidents
  listIncidents: (farmOwnerId: string) =>
    payrollRepo.listIncidents(farmOwnerId),

  createIncident: async (
    farmOwnerId: string,
    input: z.infer<typeof createIncidentSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createIncident({
      id,
      farmOwnerId,
      ...input,
      status: input.status ?? "open",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  updateIncident: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateIncidentSchema>,
  ) => {
    await payrollRepo.updateIncident(farmOwnerId, id, input);
  },
};

