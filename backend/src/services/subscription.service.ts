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
};
