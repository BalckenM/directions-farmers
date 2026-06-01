import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    cattleVaccinations
} from "../../db/schema";

import { vaccinationSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleVaccinationsRepo = {

  listVaccinations: (farmOwnerId: string) =>
    db
      .select(vaccinationSelect)
      .from(cattleVaccinations)
      .where(eq(cattleVaccinations.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleVaccinations.vaccinationDate)),

  findVaccinationById: (farmOwnerId: string, id: string) =>
    db
      .select(vaccinationSelect)
      .from(cattleVaccinations)
      .where(and(eq(cattleVaccinations.farmOwnerId, farmOwnerId), eq(cattleVaccinations.id, id)))
      .then((r) => r[0] ?? null),

  createVaccination: (data: any) => db.insert(cattleVaccinations).values(data),

  updateVaccination: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleVaccinations)
      .set(data)
      .where(and(eq(cattleVaccinations.farmOwnerId, farmOwnerId), eq(cattleVaccinations.id, id))),
};

