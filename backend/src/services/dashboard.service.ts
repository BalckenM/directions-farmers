import { dashboardRepo } from "../repositories/dashboard.repo";

export const dashboardService = {
  getSummary: (farmOwnerId: string) => dashboardRepo.getSummary(farmOwnerId),
};
