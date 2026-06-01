import { cropAdvisoryController } from "./advisory.controller";
import { cropCalendarEventsController } from "./calendar-events.controller";
import { cropCropsController } from "./crops.controller";
import { cropExpensesController } from "./expenses.controller";
import { cropFieldsController } from "./fields.controller";
import { cropHarvestController } from "./harvest.controller";
import { cropPestObservationsController } from "./pest-observations.controller";
import { cropPlantingPlansController } from "./planting-plans.controller";
import { cropSalesController } from "./sales.controller";
import { cropSeasonsController } from "./seasons.controller";
import { cropSprayRecordsController } from "./spray-records.controller";
import { cropTasksController } from "./tasks.controller";

export const cropController = {
  ...cropCropsController,
  ...cropFieldsController,
  ...cropSeasonsController,
  ...cropPlantingPlansController,
  ...cropHarvestController,
  ...cropTasksController,
  ...cropPestObservationsController,
  ...cropSprayRecordsController,
  ...cropExpensesController,
  ...cropCalendarEventsController,
  ...cropSalesController,
  ...cropAdvisoryController,
};
