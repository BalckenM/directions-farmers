import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import {
    poultryChickSalesRepo,
    poultryDiseaseEventsRepo,
    poultryEggSalesRepo,
    poultryEnvironmentReadingsRepo,
    poultryFeedPhasesRepo,
    poultryInventoryRepo,
    poultryMedicationLogsRepo,
} from "../../repositories/poultry/sub-resources.repo";

function buildListService(repo: { list: Function; create: Function }) {
  return {
    list: (farmOwnerId: string, query: Record<string, unknown>) => {
      const { page, limit, offset } = parsePagination(query);
      return repo.list(farmOwnerId, offset, limit).then(({ rows, total }: any) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
    },
    create: async (farmOwnerId: string, input: any) => {
      const id = randomUUID();
      await repo.create({ id, farmOwnerId, ...input, createdAt: new Date() });
      return { id };
    },
  };
}

export const poultryFeedPhasesService = buildListService(poultryFeedPhasesRepo);
export const poultryMedicationLogsService = buildListService(poultryMedicationLogsRepo);
export const poultryDiseaseEventsService = buildListService(poultryDiseaseEventsRepo);
export const poultryEnvironmentReadingsService = buildListService(poultryEnvironmentReadingsRepo);
export const poultryInventoryService = buildListService(poultryInventoryRepo);
export const poultryEggSalesService = buildListService(poultryEggSalesRepo);
export const poultryChickSalesService = buildListService(poultryChickSalesRepo);
