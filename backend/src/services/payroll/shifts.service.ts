import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { payrollShiftsRepo } from "../../repositories/payroll/shifts.repo";

export const payrollShiftsService = {
  list: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return payrollShiftsRepo
      .list(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  get: async (farmOwnerId: string, id: string) => {
    const row = await payrollShiftsRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  create: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await payrollShiftsRepo.create({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return payrollShiftsRepo.findById(farmOwnerId, id);
  },

  update: async (farmOwnerId: string, id: string, input: any) => {
    await payrollShiftsService.get(farmOwnerId, id);
    await payrollShiftsRepo.update(farmOwnerId, id, input);
    return payrollShiftsRepo.findById(farmOwnerId, id);
  },

  delete: async (farmOwnerId: string, id: string) => {
    await payrollShiftsService.get(farmOwnerId, id);
    await payrollShiftsRepo.delete(farmOwnerId, id);
  },
};
