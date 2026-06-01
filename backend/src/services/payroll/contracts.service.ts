import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
    createContractSchema
} from "../../validators/payroll/payroll.validator";

export const payrollContractsService = {
  listContracts: (farmOwnerId: string, employeeId: string) =>
    payrollRepo.listContracts(farmOwnerId, employeeId),

  createContract: async (
    farmOwnerId: string,
    input: z.infer<typeof createContractSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createContract({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  getContract: async (farmOwnerId: string, id: string) => {
    const contract = await payrollRepo.findContractById(farmOwnerId, id);
    if (!contract)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return contract;
  },

  updateContract: async (
    farmOwnerId: string,
    id: string,
    input: Record<string, unknown>,
  ) => {
    await payrollRepo.findContractById(farmOwnerId, id).then((c) => {
      if (!c)
        throw Object.assign(new Error("Not found"), {
          status: 404,
          code: "NOT_FOUND",
        });
    });
    await payrollRepo.updateContract(farmOwnerId, id, input);
    return payrollRepo.findContractById(farmOwnerId, id);
  },
};

