import { goatAnimalsController } from "./animals.controller";
import { goatWeightController } from "./weight.controller";
import { goatMatingController } from "./mating.controller";
import { goatPregnancyController } from "./pregnancy.controller";
import { goatKiddingController } from "./kidding.controller";
import { goatMilkController } from "./milk.controller";
import { goatShearingController } from "./shearing.controller";
import { goatHealthController } from "./health.controller";
import { goatMedicationsController } from "./medications.controller";
import { goatVaccinationsController } from "./vaccinations.controller";
import { goatSalesController } from "./sales.controller";
import { goatFeedController } from "./feed.controller";
import { goatPastureController } from "./pasture.controller";
import { goatFamachaController } from "./famacha.controller";
import { goatBcsController } from "./bcs.controller";

export const goatController = {
  ...goatAnimalsController,
  ...goatWeightController,
  ...goatMatingController,
  ...goatPregnancyController,
  ...goatKiddingController,
  ...goatMilkController,
  ...goatShearingController,
  ...goatHealthController,
  ...goatMedicationsController,
  ...goatVaccinationsController,
  ...goatSalesController,
  ...goatFeedController,
  ...goatPastureController,
  ...goatFamachaController,
  ...goatBcsController,
};

