import { count, eq } from "drizzle-orm";
import { db } from "../config/database";
import {
  cattleAnimals,
  cropFields,
  feedLogs,
  financialTransactions,
  goatAnimals,
  livestockGroups,
  movementRecords,
  payrollEmployees,
  poultryFlocks,
} from "../db/schema";

export const dashboardRepo = {
  getSummary: async (farmOwnerId: string) => {
    const [
      goats,
      cattle,
      flocks,
      fields,
      employees,
      transactions,
      groups,
      movements,
      feedLogsCount,
    ] = await Promise.all([
      db
        .select({ count: count() })
        .from(goatAnimals)
        .where(eq(goatAnimals.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(cattleAnimals)
        .where(eq(cattleAnimals.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(poultryFlocks)
        .where(eq(poultryFlocks.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(cropFields)
        .where(eq(cropFields.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(payrollEmployees)
        .where(eq(payrollEmployees.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(financialTransactions)
        .where(eq(financialTransactions.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(livestockGroups)
        .where(eq(livestockGroups.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(movementRecords)
        .where(eq(movementRecords.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
      db
        .select({ count: count() })
        .from(feedLogs)
        .where(eq(feedLogs.farmOwnerId, farmOwnerId))
        .then((r) => Number(r[0]?.count ?? 0)),
    ]);

    return {
      livestock: { goats, cattle, poultryFlocks: flocks, groups },
      crops: { fields },
      payroll: { employees },
      financial: { transactions },
      records: { movements, feedLogs: feedLogsCount },
    };
  },
};
