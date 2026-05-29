import { randomUUID } from "crypto";
import { parsePagination } from "../lib/pagination";
import { eventsRepo } from "../repositories/events.repo";
import type {
  AddBreedingEventInput,
  AddHealthEventInput,
  AddWeightRecordInput,
} from "../validators/events.validator";

export const eventsService = {
  listHealthEvents: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await eventsRepo.listHealth(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  addHealthEvent: async (farmOwnerId: string, input: AddHealthEventInput) => {
    const id = randomUUID();
    await eventsRepo.insertHealth({ id, farmOwnerId, ...input, createdAt: new Date() });
    return eventsRepo.findHealthById(farmOwnerId, id);
  },

  listWeightRecords: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await eventsRepo.listWeights(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  addWeightRecord: async (farmOwnerId: string, input: AddWeightRecordInput) => {
    const id = randomUUID();
    await eventsRepo.insertWeight({ id, farmOwnerId, ...input, createdAt: new Date() });
    return eventsRepo.findWeightById(farmOwnerId, id);
  },

  listBreedingEvents: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await eventsRepo.listBreeding(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  addBreedingEvent: async (farmOwnerId: string, input: AddBreedingEventInput) => {
    const id = randomUUID();
    await eventsRepo.insertBreeding({ id, farmOwnerId, ...input, createdAt: new Date() });
    return eventsRepo.findBreedingById(farmOwnerId, id);
  },
};
