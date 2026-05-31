import { poultryDailyRecordsService } from "./daily-records.service";
import { poultryFlocksService } from "./flocks.service";
import { poultryHarvestService } from "./harvest.service";
import { poultryVaccinationsService } from "./vaccinations.service";

export const poultryService = {
  ...poultryFlocksService,
  ...poultryDailyRecordsService,
  ...poultryVaccinationsService,
  ...poultryHarvestService,
};
