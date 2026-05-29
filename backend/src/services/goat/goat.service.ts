import { goatAnimalsService } from "./animals.service";
import { goatWeightService } from "./weight.service";
import { goatMatingService } from "./mating.service";
import { goatPregnancyService } from "./pregnancy.service";
import { goatKiddingService } from "./kidding.service";
import { goatMilkService } from "./milk.service";
import { goatShearingService } from "./shearing.service";
import { goatHealthService } from "./health.service";
import { goatMedicationsService } from "./medications.service";
import { goatVaccinationsService } from "./vaccinations.service";
import { goatSalesService } from "./sales.service";
import { goatFeedService } from "./feed.service";
import { goatPastureService } from "./pasture.service";
import { goatFamachaService } from "./famacha.service";
import { goatBcsService } from "./bcs.service";

export const goatService = {
  ...goatAnimalsService,
  ...goatWeightService,
  ...goatMatingService,
  ...goatPregnancyService,
  ...goatKiddingService,
  ...goatMilkService,
  ...goatShearingService,
  ...goatHealthService,
  ...goatMedicationsService,
  ...goatVaccinationsService,
  ...goatSalesService,
  ...goatFeedService,
  ...goatPastureService,
  ...goatFamachaService,
  ...goatBcsService,
};

