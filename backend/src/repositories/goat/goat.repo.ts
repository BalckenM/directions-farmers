import { goatAnimalsRepo } from "./animals.repo";
import { goatWeightRepo } from "./weight.repo";
import { goatMatingRepo } from "./mating.repo";
import { goatPregnancyRepo } from "./pregnancy.repo";
import { goatKiddingRepo } from "./kidding.repo";
import { goatMilkRepo } from "./milk.repo";
import { goatShearingRepo } from "./shearing.repo";
import { goatHealthRepo } from "./health.repo";
import { goatMedicationsRepo } from "./medications.repo";
import { goatVaccinationsRepo } from "./vaccinations.repo";
import { goatSalesRepo } from "./sales.repo";
import { goatFeedRepo } from "./feed.repo";
import { goatPastureRepo } from "./pasture.repo";
import { goatFamachaRepo } from "./famacha.repo";
import { goatBcsRepo } from "./bcs.repo";

export const goatRepo = {
  ...goatAnimalsRepo,
  ...goatWeightRepo,
  ...goatMatingRepo,
  ...goatPregnancyRepo,
  ...goatKiddingRepo,
  ...goatMilkRepo,
  ...goatShearingRepo,
  ...goatHealthRepo,
  ...goatMedicationsRepo,
  ...goatVaccinationsRepo,
  ...goatSalesRepo,
  ...goatFeedRepo,
  ...goatPastureRepo,
  ...goatFamachaRepo,
  ...goatBcsRepo,
};

