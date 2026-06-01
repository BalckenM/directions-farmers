import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatFeedRecords
} from "../../db/schema";

import { feedSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatFeedRepo = {
  listFeedRecords: (farmOwnerId: string) =>
    db
      .select(feedSelect)
      .from(goatFeedRecords)
      .where(eq(goatFeedRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatFeedRecords.feedDate)),

  findFeedRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(feedSelect)
      .from(goatFeedRecords)
      .where(and(eq(goatFeedRecords.farmOwnerId, farmOwnerId), eq(goatFeedRecords.id, id)))
      .then((r) => r[0] ?? null),

  createFeedRecord: (data: any) => db.insert(goatFeedRecords).values(data),

  deleteFeedRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(goatFeedRecords)
      .where(and(eq(goatFeedRecords.farmOwnerId, farmOwnerId), eq(goatFeedRecords.id, id))),
};

