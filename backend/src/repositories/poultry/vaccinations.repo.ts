import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { poultryVaccinationSchedules } from "../../db/schema";

export const poultryVaccinationsRepo = {
  listVaccinationSchedules: (farmOwnerId: string, flockId: string) =>
    db
      .select()
      .from(poultryVaccinationSchedules)
      .where(
        and(
          eq(poultryVaccinationSchedules.farmOwnerId, farmOwnerId),
          eq(poultryVaccinationSchedules.flockId, flockId),
        ),
      )
      .orderBy(desc(poultryVaccinationSchedules.scheduledDate)),

  createVaccinationSchedule: (data: any) =>
    db.insert(poultryVaccinationSchedules).values(data),
};
