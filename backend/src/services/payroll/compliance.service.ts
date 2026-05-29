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

export const payrollComplianceService = {
  listComplianceAlerts: (farmOwnerId: string) =>
    payrollRepo.listComplianceAlerts(farmOwnerId),

  resolveComplianceAlert: async (farmOwnerId: string, id: string) => {
    await payrollRepo.resolveComplianceAlert(farmOwnerId, id, {
      isResolved: true,
      resolvedAt: new Date(),
    });
  },
};

