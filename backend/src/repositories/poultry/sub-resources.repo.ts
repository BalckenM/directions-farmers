import { count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    poultryChickSales,
    poultryDiseaseEvents,
    poultryEggSales,
    poultryEnvironmentReadings,
    poultryFeedPhases,
    poultryInventory,
    poultryMedicationLogs,
} from "../../db/schema";

export const poultryFeedPhasesRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryFeedPhases)
        .where(eq(poultryFeedPhases.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryFeedPhases.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryFeedPhases)
        .where(eq(poultryFeedPhases.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
  create: (data: any) => db.insert(poultryFeedPhases).values(data),
};

export const poultryMedicationLogsRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryMedicationLogs)
        .where(eq(poultryMedicationLogs.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryMedicationLogs.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryMedicationLogs)
        .where(eq(poultryMedicationLogs.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
  create: (data: any) => db.insert(poultryMedicationLogs).values(data),
};

export const poultryDiseaseEventsRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryDiseaseEvents)
        .where(eq(poultryDiseaseEvents.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryDiseaseEvents.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryDiseaseEvents)
        .where(eq(poultryDiseaseEvents.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
  create: (data: any) => db.insert(poultryDiseaseEvents).values(data),
};

export const poultryEnvironmentReadingsRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryEnvironmentReadings)
        .where(eq(poultryEnvironmentReadings.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryEnvironmentReadings.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryEnvironmentReadings)
        .where(eq(poultryEnvironmentReadings.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
  create: (data: any) => db.insert(poultryEnvironmentReadings).values(data),
};

export const poultryInventoryRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryInventory)
        .where(eq(poultryInventory.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryInventory.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryInventory)
        .where(eq(poultryInventory.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
  create: (data: any) => db.insert(poultryInventory).values(data),
};

export const poultryEggSalesRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryEggSales)
        .where(eq(poultryEggSales.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryEggSales.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryEggSales)
        .where(eq(poultryEggSales.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
  create: (data: any) => db.insert(poultryEggSales).values(data),
};

export const poultryChickSalesRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryChickSales)
        .where(eq(poultryChickSales.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryChickSales.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryChickSales)
        .where(eq(poultryChickSales.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
  create: (data: any) => db.insert(poultryChickSales).values(data),
};
