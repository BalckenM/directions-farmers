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

export const payrollPayslipsService = {
  listPayslips: (farmOwnerId: string) => payrollRepo.listPayslips(farmOwnerId),

  getPayslip: async (farmOwnerId: string, id: string) => {
    const ps = await payrollRepo.findPayslipById(farmOwnerId, id);
    if (!ps)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return ps;
  },
};

