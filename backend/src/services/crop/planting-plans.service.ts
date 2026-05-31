import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { cropPlantingPlansRepo } from "../../repositories/crop/planting-plans.repo";
import type {
  createPlantingPlanSchema,
  updatePlantingPlanSchema,
} from "../../validators/crop/crop.validator";

export const cropPlantingPlansService = {
  listPlantingPlans: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropPlantingPlansRepo
      .listPlantingPlans(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getPlantingPlan: async (farmOwnerId: string, id: string) => {
    const plan = await cropPlantingPlansRepo.findPlantingPlanById(farmOwnerId, id);
    if (!plan)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return plan;
  },

  createPlantingPlan: async (
    farmOwnerId: string,
    input: z.infer<typeof createPlantingPlanSchema>,
  ) => {
    const id = randomUUID();
    await cropPlantingPlansRepo.createPlantingPlan({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return cropPlantingPlansRepo.findPlantingPlanById(farmOwnerId, id);
  },

  updatePlantingPlan: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updatePlantingPlanSchema>,
  ) => {
    await cropPlantingPlansService.getPlantingPlan(farmOwnerId, id);
    await cropPlantingPlansRepo.updatePlantingPlan(farmOwnerId, id, input);
    return cropPlantingPlansRepo.findPlantingPlanById(farmOwnerId, id);
  },
};
