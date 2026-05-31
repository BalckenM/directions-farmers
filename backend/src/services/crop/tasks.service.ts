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
};
