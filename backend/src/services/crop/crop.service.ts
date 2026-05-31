import { cropFieldsService } from "./fields.service";
import { cropHarvestService } from "./harvest.service";
import { cropPlantingPlansService } from "./planting-plans.service";
import { cropSprayRecordsService } from "./spray-records.service";
import { cropTasksService } from "./tasks.service";

export const cropService = {
  ...cropFieldsService,
  ...cropPlantingPlansService,
  ...cropHarvestService,
  ...cropTasksService,
  ...cropSprayRecordsService,
};
