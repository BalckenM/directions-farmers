import { cattleAnimalsService } from "./animals.service";
import { cattleWeightService } from "./weight.service";
import { cattleBreedingService } from "./breeding.service";
import { cattlePregnancyService } from "./pregnancy.service";
import { cattleCalvingService } from "./calving.service";
import { cattleMilkService } from "./milk.service";
import { cattleHealthService } from "./health.service";
import { cattleMedicationsService } from "./medications.service";
import { cattleVaccinationsService } from "./vaccinations.service";
import { cattleSalesService } from "./sales.service";
import { cattleFeedService } from "./feed.service";
import { cattlePastureService } from "./pasture.service";
import { cattleBcsService } from "./bcs.service";
import { cattleDippingService } from "./dipping.service";

export const cattleService = {
  ...cattleAnimalsService,
  ...cattleWeightService,
  ...cattleBreedingService,
  ...cattlePregnancyService,
  ...cattleCalvingService,
  ...cattleMilkService,
  ...cattleHealthService,
  ...cattleMedicationsService,
  ...cattleVaccinationsService,
  ...cattleSalesService,
  ...cattleFeedService,
  ...cattlePastureService,
  ...cattleBcsService,
  ...cattleDippingService,
};

