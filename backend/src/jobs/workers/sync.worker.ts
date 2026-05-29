import pino from "pino";

const logger = pino({ name: "sync-worker" });

export const syncWorker = {
  run: async () => {
    logger.debug("sync worker: no pending jobs");
  },
};
