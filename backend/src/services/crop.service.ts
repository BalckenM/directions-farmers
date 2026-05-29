import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../lib/pagination";
import { cropRepo } from "../repositories/crop.repo";
import type {
    createFieldSchema,
    createHarvestRecordSchema,
    createPlantingPlanSchema,
    createSprayRecordSchema,
    createTaskSchema,
    updateFieldSchema,
    updatePlantingPlanSchema,
} from "../validators/crop.validator";

export const cropService = {
  listFields: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropRepo
      .listFields(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getField: async (farmOwnerId: string, id: string) => {
    const field = await cropRepo.findFieldById(farmOwnerId, id);
    if (!field)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return field;
  },

  createField: async (
    farmOwnerId: string,
    input: z.infer<typeof createFieldSchema>,
  ) => {
    const id = randomUUID();
    await cropRepo.createField({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return cropRepo.findFieldById(farmOwnerId, id);
  },

  updateField: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateFieldSchema>,
  ) => {
    await cropService.getField(farmOwnerId, id);
    await cropRepo.updateField(farmOwnerId, id, input);
    return cropRepo.findFieldById(farmOwnerId, id);
  },

  deleteField: async (farmOwnerId: string, id: string) => {
    await cropService.getField(farmOwnerId, id);
    await cropRepo.deleteField(farmOwnerId, id);
  },

  listPlantingPlans: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropRepo
      .listPlantingPlans(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getPlantingPlan: async (farmOwnerId: string, id: string) => {
    const plan = await cropRepo.findPlantingPlanById(farmOwnerId, id);
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
    await cropRepo.createPlantingPlan({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return cropRepo.findPlantingPlanById(farmOwnerId, id);
  },

  updatePlantingPlan: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updatePlantingPlanSchema>,
  ) => {
    await cropService.getPlantingPlan(farmOwnerId, id);
    await cropRepo.updatePlantingPlan(farmOwnerId, id, input);
    return cropRepo.findPlantingPlanById(farmOwnerId, id);
  },

  listHarvestRecords: (farmOwnerId: string, planId: string) =>
    cropRepo.listHarvestRecords(farmOwnerId, planId),
  addHarvestRecord: async (
    farmOwnerId: string,
    planId: string,
    input: z.infer<typeof createHarvestRecordSchema>,
  ) => {
    await cropService.getPlantingPlan(farmOwnerId, planId);
    const id = randomUUID();
    await cropRepo.createHarvestRecord({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },

  listTasks: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { limit, offset } = parsePagination(query);
    return cropRepo.listTasks(farmOwnerId, offset, limit);
  },

  createTask: async (
    farmOwnerId: string,
    input: z.infer<typeof createTaskSchema>,
  ) => {
    const id = randomUUID();
    await cropRepo.createTask({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  listSprayRecords: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { limit, offset } = parsePagination(query);
    return cropRepo.listSprayRecords(farmOwnerId, offset, limit);
  },

  createSprayRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createSprayRecordSchema>,
  ) => {
    const id = randomUUID();
    await cropRepo.createSprayRecord({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },
};
