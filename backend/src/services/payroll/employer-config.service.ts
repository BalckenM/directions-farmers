import { randomUUID } from "crypto";
import { payrollEmployerConfigRepo } from "../../repositories/payroll/employer-config.repo";

export const payrollEmployerConfigService = {
  get: async (farmOwnerId: string) => {
    const config = await payrollEmployerConfigRepo.findByFarmOwner(farmOwnerId);
    return config ?? { farmOwnerId, payDay: 25, currency: "ZAR" };
  },

  update: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await payrollEmployerConfigRepo.upsert(farmOwnerId, id, input);
    return payrollEmployerConfigRepo.findByFarmOwner(farmOwnerId);
  },
};
