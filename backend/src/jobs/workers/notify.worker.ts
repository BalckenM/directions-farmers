import pino from "pino";

const logger = pino({ name: "notify-worker" });

export const notifyWorker = {
  run: async () => {
    logger.debug("notify worker: no pending jobs");
  },
};
