import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cattleSaleRecords } from "../../db/schema";

import { saleSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleSalesRepo = {

  listSaleRecords: (farmOwnerId: string) =>
    db
      .select(saleSelect)
      .from(cattleSaleRecords)
      .where(eq(cattleSaleRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleSaleRecords.saleDate)),

  findSaleRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(saleSelect)
      .from(cattleSaleRecords)
      .where(and(eq(cattleSaleRecords.farmOwnerId, farmOwnerId), eq(cattleSaleRecords.id, id)))
      .then((r) => r[0] ?? null),

  createSaleRecord: (data: any) => db.insert(cattleSaleRecords).values(data),

  updateSaleRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleSaleRecords)
      .set(data)
      .where(and(eq(cattleSaleRecords.farmOwnerId, farmOwnerId), eq(cattleSaleRecords.id, id))),

  deleteSaleRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(cattleSaleRecords)
      .where(and(eq(cattleSaleRecords.farmOwnerId, farmOwnerId), eq(cattleSaleRecords.id, id))),
};

