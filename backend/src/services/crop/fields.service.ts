import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { cropFieldsRepo } from "../../repositories/crop/fields.repo";
import type {
  createFieldSchema,
  updateFieldSchema,
} from "../../validators/crop/crop.validator";

export const cropFieldsService = {
  listFields: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropFieldsRepo
      .listFields(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getField: async (farmOwnerId: string, id: string) => {
    const field = await cropFieldsRepo.findFieldById(farmOwnerId, id);
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
    await cropFieldsRepo.createField({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return cropFieldsRepo.findFieldById(farmOwnerId, id);
  },

  updateField: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateFieldSchema>,
  ) => {
    await cropFieldsService.getField(farmOwnerId, id);
    await cropFieldsRepo.updateField(farmOwnerId, id, input);
    return cropFieldsRepo.findFieldById(farmOwnerId, id);
  },

  deleteField: async (farmOwnerId: string, id: string) => {
    await cropFieldsService.getField(farmOwnerId, id);
    await cropFieldsRepo.deleteField(farmOwnerId, id);
  },
};
