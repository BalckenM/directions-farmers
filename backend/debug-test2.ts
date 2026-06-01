import { goatAnimals, goatBcsRecords, goatDailyMilk, goatFamachaRecords, goatFeedRecords, goatHealthEvents, goatKiddingEvents, goatMatingRecords, goatMedicationLogs, goatPastureRecords, goatPregnancyChecks, goatSaleRecords, goatShearingRecords, goatVaccinations, goatWeightRecords } from "./src/db/schema";

async function test() {
  const tables: Record<string, any> = {goatAnimals, goatWeightRecords, goatMatingRecords, goatPregnancyChecks, goatKiddingEvents, goatDailyMilk, goatShearingRecords, goatHealthEvents, goatMedicationLogs, goatVaccinations, goatSaleRecords, goatFeedRecords, goatPastureRecords, goatFamachaRecords, goatBcsRecords};
  for (const [name, table] of Object.entries(tables)) {
    const cols = Object.keys(table).filter(c => !c.startsWith("_") && !c.startsWith("$"));
    console.log(`${name}: ${cols.join(", ")}`);
  }
  process.exit(0);
}

test();
