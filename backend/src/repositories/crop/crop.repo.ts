import { cropFieldsRepo } from "./fields.repo";
import { cropHarvestRepo } from "./harvest.repo";
import { cropPlantingPlansRepo } from "./planting-plans.repo";
import { cropSprayRecordsRepo } from "./spray-records.repo";
import { cropTasksRepo } from "./tasks.repo";

export const cropRepo = {
  ...cropFieldsRepo,
  ...cropPlantingPlansRepo,
  ...cropHarvestRepo,
  ...cropTasksRepo,
  ...cropSprayRecordsRepo,
};
