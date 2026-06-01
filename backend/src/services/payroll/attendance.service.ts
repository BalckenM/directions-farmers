import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { payrollAttendanceRepo } from "../../repositories/payroll/attendance.repo";

export const payrollAttendanceService = {
  list: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return payrollAttendanceRepo
      .list(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  get: async (farmOwnerId: string, id: string) => {
    const row = await payrollAttendanceRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  create: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await payrollAttendanceRepo.create({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return payrollAttendanceRepo.findById(farmOwnerId, id);
  },

  update: async (farmOwnerId: string, id: string, input: any) => {
    await payrollAttendanceService.get(farmOwnerId, id);
    await payrollAttendanceRepo.update(farmOwnerId, id, input);
    return payrollAttendanceRepo.findById(farmOwnerId, id);
  },
};
