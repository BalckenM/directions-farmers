import { and, eq } from "drizzle-orm";
import { db } from "../config/database";
import {
  farmModuleActivations,
  farmSubscriptions,
  modules,
  subscriptionPlans,
} from "../db/schema";

export const subscriptionRepo = {
  findByFarmOwner: (farmOwnerId: string) =>
    db
      .select()
      .from(farmSubscriptions)
      .where(eq(farmSubscriptions.farmOwnerId, farmOwnerId))
      .then((r) => r[0] ?? null),

  findAllPlans: () =>
    db
      .select()
      .from(subscriptionPlans)
      .where(eq(subscriptionPlans.isActive, true)),

  getActivatedModules: (farmOwnerId: string) =>
    db
      .select({ slug: modules.slug })
      .from(farmModuleActivations)
      .innerJoin(modules, eq(farmModuleActivations.moduleId, modules.id))
      .where(
        and(
          eq(farmModuleActivations.farmOwnerId, farmOwnerId),
          eq(farmModuleActivations.isActive, true),
        ),
      ),

  activateModule: (data: Record<string, unknown>) =>
    db.insert(farmModuleActivations).values(data as any),

  deactivateModule: (farmOwnerId: string, moduleId: string) =>
    db
      .update(farmModuleActivations)
      .set({ isActive: false })
      .where(
        and(
          eq(farmModuleActivations.farmOwnerId, farmOwnerId),
          eq(farmModuleActivations.moduleId, moduleId),
        ),
      ),

  updatePlan: (farmOwnerId: string, planId: string) =>
    db
      .update(farmSubscriptions)
      .set({ planId, updatedAt: new Date() })
      .where(eq(farmSubscriptions.farmOwnerId, farmOwnerId)),
};
