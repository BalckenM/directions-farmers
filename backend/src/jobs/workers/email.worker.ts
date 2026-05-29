import pino from "pino";

const logger = pino({ name: "email-worker" });

export const emailWorker = {
  run: async () => {
    // Email jobs would be stored in a DB table; for now log a no-op
    logger.debug("email worker: no pending jobs");
  },
};
