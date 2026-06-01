import type { NextFunction, Request, Response } from "express";
import { sendList, sendOne } from "../../lib/response";
import {
    poultryChickSalesService,
    poultryDiseaseEventsService,
    poultryEggSalesService,
    poultryEnvironmentReadingsService,
    poultryFeedPhasesService,
    poultryInventoryService,
    poultryMedicationLogsService,
} from "../../services/poultry/sub-resources.service";

function listAndCreate(service: { list: Function; create: Function }) {
  return {
    list: async (req: Request, res: Response, next: NextFunction) => {
      try {
        const result = await service.list(
          req.auth.farmOwnerId,
          req.query as Record<string, unknown>,
        );
        sendList(res, result.data, result.meta);
      } catch (err) {
        next(err);
      }
    },
    create: async (req: Request, res: Response, next: NextFunction) => {
      try {
        res.status(201);
        sendOne(res, await service.create(req.auth.farmOwnerId, req.body));
      } catch (err) {
        next(err);
      }
    },
  };
}

const feedPhases = listAndCreate(poultryFeedPhasesService);
const medicationLogs = listAndCreate(poultryMedicationLogsService);
const diseaseEvents = listAndCreate(poultryDiseaseEventsService);
const environmentReadings = listAndCreate(poultryEnvironmentReadingsService);
const inventory = listAndCreate(poultryInventoryService);
const eggSales = listAndCreate(poultryEggSalesService);
const chickSales = listAndCreate(poultryChickSalesService);

export const poultrySubResourcesController = {
  listFeedPhases: feedPhases.list,
  addFeedPhase: feedPhases.create,
  listMedicationLogs: medicationLogs.list,
  addMedicationLog: medicationLogs.create,
  listDiseaseEvents: diseaseEvents.list,
  addDiseaseEvent: diseaseEvents.create,
  listEnvironmentReadings: environmentReadings.list,
  addEnvironmentReading: environmentReadings.create,
  listInventory: inventory.list,
  addInventoryItem: inventory.create,
  listEggSales: eggSales.list,
  addEggSale: eggSales.create,
  listChickSales: chickSales.list,
  addChickSale: chickSales.create,
};
