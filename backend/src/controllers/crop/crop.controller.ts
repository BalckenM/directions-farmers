import { cropFieldsController } from "./fields.controller";
import { cropHarvestController } from "./harvest.controller";
import { cropPlantingPlansController } from "./planting-plans.controller";
import { cropSprayRecordsController } from "./spray-records.controller";
import { cropTasksController } from "./tasks.controller";

export const cropController = {
  ...cropFieldsController,
  ...cropPlantingPlansController,
  ...cropHarvestController,
  ...cropTasksController,
  ...cropSprayRecordsController,
};
