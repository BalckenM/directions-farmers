import { poultryDailyRecordsController } from "./daily-records.controller";
import { poultryFlocksController } from "./flocks.controller";
import { poultryHarvestController } from "./harvest.controller";
import { poultryVaccinationsController } from "./vaccinations.controller";

export const poultryController = {
  ...poultryFlocksController,
  ...poultryDailyRecordsController,
  ...poultryVaccinationsController,
  ...poultryHarvestController,
};
