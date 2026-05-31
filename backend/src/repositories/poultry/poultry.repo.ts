import { poultryDailyRecordsRepo } from "./daily-records.repo";
import { poultryFlocksRepo } from "./flocks.repo";
import { poultryHarvestRepo } from "./harvest.repo";
import { poultryVaccinationsRepo } from "./vaccinations.repo";

export const poultryRepo = {
  ...poultryFlocksRepo,
  ...poultryDailyRecordsRepo,
  ...poultryVaccinationsRepo,
  ...poultryHarvestRepo,
};
