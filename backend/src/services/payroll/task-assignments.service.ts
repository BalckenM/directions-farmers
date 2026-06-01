import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { payrollTaskAssignmentsRepo } from "../../repositories/payroll/task-assignments.repo";

export const payrollTaskAssignmentsService = {
  list: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return payrollTaskAssignmentsRepo
      .list(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  get: async (farmOwnerId: string, id: string) => {
    const row = await payrollTaskAssignmentsRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  create: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await payrollTaskAssignmentsRepo.create({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return payrollTaskAssignmentsRepo.findById(farmOwnerId, id);
  },

  update: async (farmOwnerId: string, id: string, input: any) => {
    await payrollTaskAssignmentsService.get(farmOwnerId, id);
    await payrollTaskAssignmentsRepo.update(farmOwnerId, id, input);
    return payrollTaskAssignmentsRepo.findById(farmOwnerId, id);
  },

  delete: async (farmOwnerId: string, id: string) => {
    await payrollTaskAssignmentsService.get(farmOwnerId, id);
    await payrollTaskAssignmentsRepo.delete(farmOwnerId, id);
  },
};
