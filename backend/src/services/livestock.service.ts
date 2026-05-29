import { randomUUID } from "crypto";
import { livestockRepo } from "../repositories/livestock.repo";
import type {
  CreateLivestockGroupInput,
  UpdateLivestockGroupInput,
} from "../validators/livestock.validator";

export const livestockService = {
  getAnimals: async (farmOwnerId: string, species?: string) => {
    if (species === "goat") {
      const rows = await livestockRepo.getGoats(farmOwnerId);
      return rows.map((a) => ({ ...a, species: "goat" }));
    }
    if (species === "cattle") {
      const rows = await livestockRepo.getCattle(farmOwnerId);
      return rows.map((a) => ({ ...a, species: "cattle" }));
    }
    const [goats, cattle] = await Promise.all([
      livestockRepo.getGoats(farmOwnerId),
      livestockRepo.getCattle(farmOwnerId),
    ]);
    return [
      ...goats.map((a) => ({ ...a, species: "goat" })),
      ...cattle.map((a) => ({ ...a, species: "cattle" })),
    ];
  },

  getGroups: (farmOwnerId: string) => livestockRepo.listGroups(farmOwnerId),

  createGroup: async (farmOwnerId: string, input: CreateLivestockGroupInput) => {
    const id = randomUUID();
    await livestockRepo.createGroup({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return livestockRepo.findGroupById(farmOwnerId, id);
  },

  updateGroup: async (
    farmOwnerId: string,
    groupId: string,
    input: UpdateLivestockGroupInput,
  ) => {
    const group = await livestockRepo.findGroupById(farmOwnerId, groupId);
    if (!group)
      throw Object.assign(new Error("Group not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    await livestockRepo.updateGroup(farmOwnerId, groupId, input as Record<string, unknown>);
    return livestockRepo.findGroupById(farmOwnerId, groupId);
  },

  deleteGroup: async (farmOwnerId: string, groupId: string) => {
    const group = await livestockRepo.findGroupById(farmOwnerId, groupId);
    if (!group)
      throw Object.assign(new Error("Group not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    await livestockRepo.deleteGroup(farmOwnerId, groupId);
  },
};
