import { and, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollGarnisheeOrders, payrollPayStructures } from "../../db/schema";

export const payrollPayStructuresRepo = {
  listPayStructures: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollPayStructures)
      .where(eq(payrollPayStructures.farmOwnerId, farmOwnerId)),

  createPayStructure: (data: typeof payrollPayStructures.$inferInsert) =>
    db.insert(payrollPayStructures).values(data),

  updatePayStructure: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollPayStructures.$inferInsert>,
  ) =>
    db
      .update(payrollPayStructures)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollPayStructures.farmOwnerId, farmOwnerId),
          eq(payrollPayStructures.id, id),
        ),
      ),

  // Garnishee orders
  listGarnisheeOrders: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollGarnisheeOrders)
      .where(eq(payrollGarnisheeOrders.farmOwnerId, farmOwnerId)),

  createGarnisheeOrder: (data: typeof payrollGarnisheeOrders.$inferInsert) =>
    db.insert(payrollGarnisheeOrders).values(data),

  updateGarnisheeOrder: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollGarnisheeOrders.$inferInsert>,
  ) =>
    db
      .update(payrollGarnisheeOrders)
      .set(data)
      .where(
        and(
          eq(payrollGarnisheeOrders.farmOwnerId, farmOwnerId),
          eq(payrollGarnisheeOrders.id, id),
        ),
      ),
};

