import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { cropCalendarEventsRepo } from "../../repositories/crop/calendar-events.repo";

export const cropCalendarEventsService = {
  listCalendarEvents: (
    farmOwnerId: string,
    query: Record<string, unknown>,
  ) => {
    const { page, limit, offset } = parsePagination(query);
    return cropCalendarEventsRepo
      .listCalendarEvents(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getCalendarEvent: async (farmOwnerId: string, id: string) => {
    const row = await cropCalendarEventsRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  createCalendarEvent: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await cropCalendarEventsRepo.create({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return cropCalendarEventsRepo.findById(farmOwnerId, id);
  },

  updateCalendarEvent: async (
    farmOwnerId: string,
    id: string,
    input: any,
  ) => {
    await cropCalendarEventsService.getCalendarEvent(farmOwnerId, id);
    await cropCalendarEventsRepo.update(farmOwnerId, id, input);
    return cropCalendarEventsRepo.findById(farmOwnerId, id);
  },

  deleteCalendarEvent: async (farmOwnerId: string, id: string) => {
    await cropCalendarEventsService.getCalendarEvent(farmOwnerId, id);
    await cropCalendarEventsRepo.delete(farmOwnerId, id);
  },
};
