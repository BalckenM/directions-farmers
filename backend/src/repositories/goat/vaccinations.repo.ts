import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { goatVaccinations } from "../../db/schema";

import { vaccinationSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatVaccinationsRepo = {
  listVaccinations: (farmOwnerId: string) =>
    db
      .select(vaccinationSelect)
      .from(goatVaccinations)
      .where(eq(goatVaccinations.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatVaccinations.createdAt)),

  findVaccinationById: (farmOwnerId: string, id: string) =>
    db
      .select(vaccinationSelect)
      .from(goatVaccinations)
      .where(and(eq(goatVaccinations.farmOwnerId, farmOwnerId), eq(goatVaccinations.id, id)))
      .then((r) => r[0] ?? null),

  createVaccination: (data: any) => db.insert(goatVaccinations).values(data),

  updateVaccination: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatVaccinations)
      .set(data)
      .where(and(eq(goatVaccinations.farmOwnerId, farmOwnerId), eq(goatVaccinations.id, id))),
};

