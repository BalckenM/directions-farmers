import { randomUUID } from "crypto";
import { subscriptionRepo } from "../repositories/subscription.repo";

export const subscriptionService = {
  getModulesForFarm: async (farmOwnerId: string): Promise<string[]> => {
    const rows = await subscriptionRepo.getActivatedModules(farmOwnerId);
    return rows.map((r) => r.slug);
  },

  hasModule: async (farmOwnerId: string, slug: string): Promise<boolean> => {
    const slugs = await subscriptionService.getModulesForFarm(farmOwnerId);
    return slugs.includes(slug);
  },

  getPlan: (farmOwnerId: string) => subscriptionRepo.findByFarmOwner(farmOwnerId),

  getAllPlans: () => subscriptionRepo.findAllPlans(),

  upgradePlan: async (farmOwnerId: string, planId: string): Promise<{ planId: string; activatedModules: string[] }> => {
    // Validate the plan ID against known plans
    const validPlans = ["starter", "growth", "enterprise"];
    if (!validPlans.includes(planId)) {
      throw Object.assign(new Error("Invalid plan ID"), { status: 400, code: "INVALID_PLAN" });
    }

    // Check if the user already has a subscription
    const existing = await subscriptionRepo.findByFarmOwner(farmOwnerId);
    if (existing) {
      // Update to new plan
      await subscriptionRepo.updatePlan(farmOwnerId, planId);
    } else {
      // Create a new subscription
      await subscriptionRepo.createSubscription({
        id: randomUUID(),
        farmOwnerId,
        planId,
        status: "active",
        startDate: new Date(),
        endDate: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    }

    // Sync module activations based on plan tier
    const planModuleMap: Record<string, string[]> = {
      starter: ["cattle", "goat", "poultry", "pigs"],
      growth: ["cattle", "goat", "poultry", "pigs", "apiculture", "crop", "financial", "insights"],
      enterprise: ["cattle", "goat", "poultry", "pigs", "apiculture", "crop", "financial", "insights", "traceability", "reports"],
    };

    const targetSlugs = planModuleMap[planId] ?? [];
    const allModules = await subscriptionRepo.findAllModules();
    const currentActivations = await subscriptionRepo.getActivatedModules(farmOwnerId);
    const currentSlugs = new Set(currentActivations.map((m) => m.slug));

    for (const slug of targetSlugs) {
      if (!currentSlugs.has(slug)) {
        const mod = allModules.find((m) => m.slug === slug);
        if (mod) {
          await subscriptionRepo.activateModule({
            id: randomUUID(),
            farmOwnerId,
            moduleId: mod.id,
            isActive: true,
            activatedAt: new Date(),
            createdAt: new Date(),
          });
        }
      }
    }

    // Return updated state
    const updatedModules = await subscriptionRepo.getActivatedModules(farmOwnerId);
    return {
      planId,
      activatedModules: updatedModules.map((m) => m.slug),
    };
  },
};
