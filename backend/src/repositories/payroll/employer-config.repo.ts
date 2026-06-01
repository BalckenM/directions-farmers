import { eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollEmployerConfig } from "../../db/schema";

export const payrollEmployerConfigRepo = {
  findByFarmOwner: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollEmployerConfig)
      .where(eq(payrollEmployerConfig.farmOwnerId, farmOwnerId))
      .then((r) => r[0] ?? null),

  upsert: async (farmOwnerId: string, id: string, data: any) => {
    const existing = await payrollEmployerConfigRepo.findByFarmOwner(
      farmOwnerId,
    );
    if (existing) {
      await db
        .update(payrollEmployerConfig)
        .set({ ...data, updatedAt: new Date() })
        .where(eq(payrollEmployerConfig.farmOwnerId, farmOwnerId));
    } else {
      await db.insert(payrollEmployerConfig).values({
        id,
        farmOwnerId,
        ...data,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    }
  },
};
