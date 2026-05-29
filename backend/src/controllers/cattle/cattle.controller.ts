import { cattleAnimalsController } from "./animals.controller";
import { cattleWeightController } from "./weight.controller";
import { cattleBreedingController } from "./breeding.controller";
import { cattlePregnancyController } from "./pregnancy.controller";
import { cattleCalvingController } from "./calving.controller";
import { cattleMilkController } from "./milk.controller";
import { cattleHealthController } from "./health.controller";
import { cattleMedicationsController } from "./medications.controller";
import { cattleVaccinationsController } from "./vaccinations.controller";
import { cattleSalesController } from "./sales.controller";
import { cattleFeedController } from "./feed.controller";
import { cattlePastureController } from "./pasture.controller";
import { cattleBcsController } from "./bcs.controller";
import { cattleDippingController } from "./dipping.controller";

export const cattleController = {
  ...cattleAnimalsController,
  ...cattleWeightController,
  ...cattleBreedingController,
  ...cattlePregnancyController,
  ...cattleCalvingController,
  ...cattleMilkController,
  ...cattleHealthController,
  ...cattleMedicationsController,
  ...cattleVaccinationsController,
  ...cattleSalesController,
  ...cattleFeedController,
  ...cattlePastureController,
  ...cattleBcsController,
  ...cattleDippingController,
};

