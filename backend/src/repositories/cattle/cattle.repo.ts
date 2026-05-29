import { cattleAnimalsRepo } from "./animals.repo";
import { cattleWeightRepo } from "./weight.repo";
import { cattleBreedingRepo } from "./breeding.repo";
import { cattlePregnancyRepo } from "./pregnancy.repo";
import { cattleCalvingRepo } from "./calving.repo";
import { cattleMilkRepo } from "./milk.repo";
import { cattleHealthRepo } from "./health.repo";
import { cattleMedicationsRepo } from "./medications.repo";
import { cattleVaccinationsRepo } from "./vaccinations.repo";
import { cattleSalesRepo } from "./sales.repo";
import { cattleFeedRepo } from "./feed.repo";
import { cattlePastureRepo } from "./pasture.repo";
import { cattleBcsRepo } from "./bcs.repo";
import { cattleDippingRepo } from "./dipping.repo";

export const cattleRepo = {
  ...cattleAnimalsRepo,
  ...cattleWeightRepo,
  ...cattleBreedingRepo,
  ...cattlePregnancyRepo,
  ...cattleCalvingRepo,
  ...cattleMilkRepo,
  ...cattleHealthRepo,
  ...cattleMedicationsRepo,
  ...cattleVaccinationsRepo,
  ...cattleSalesRepo,
  ...cattleFeedRepo,
  ...cattlePastureRepo,
  ...cattleBcsRepo,
  ...cattleDippingRepo,
};

