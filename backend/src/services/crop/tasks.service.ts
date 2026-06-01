import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { cropTasksRepo } from "../../repositories/crop/tasks.repo";
import type { createTaskSchema } from "../../validators/crop/crop.validator";

export const cropTasksService = {
  listTasks: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { limit, offset } = parsePagination(query);
    return cropTasksRepo.listTasks(farmOwnerId, offset, limit);
  },

  getTask: async (farmOwnerId: string, id: string) => {
    const row = await cropTasksRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  createTask: async (
    farmOwnerId: string,
    input: z.infer<typeof createTaskSchema>,
  ) => {
    const id = randomUUID();
    await cropTasksRepo.createTask({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  updateTask: async (farmOwnerId: string, id: string, input: any) => {
    await cropTasksService.getTask(farmOwnerId, id);
    await cropTasksRepo.updateTask(farmOwnerId, id, input);
    return cropTasksRepo.findById(farmOwnerId, id);
  },

  deleteTask: async (farmOwnerId: string, id: string) => {
    await cropTasksService.getTask(farmOwnerId, id);
    await cropTasksRepo.deleteTask(farmOwnerId, id);
  },
};
