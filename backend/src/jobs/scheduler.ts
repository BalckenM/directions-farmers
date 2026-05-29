import cron from "node-cron";
import pino from "pino";
import { emailWorker } from "./workers/email.worker";
import { notifyWorker } from "./workers/notify.worker";
import { pdfWorker } from "./workers/pdf.worker";
import { syncWorker } from "./workers/sync.worker";

const logger = pino({ name: "scheduler" });

export function startScheduler(): void {
  // Process email queue every minute
  cron.schedule("* * * * *", async () => {
    try {
      await emailWorker.run();
    } catch (err) {
      logger.error({ err }, "email worker error");
    }
  });

  // Generate pending PDFs every 2 minutes
  cron.schedule("*/2 * * * *", async () => {
    try {
      await pdfWorker.run();
    } catch (err) {
      logger.error({ err }, "pdf worker error");
    }
  });

  // Push notifications every 5 minutes
  cron.schedule("*/5 * * * *", async () => {
    try {
      await notifyWorker.run();
    } catch (err) {
      logger.error({ err }, "notify worker error");
    }
  });

  // Data sync every 15 minutes
  cron.schedule("*/15 * * * *", async () => {
    try {
      await syncWorker.run();
    } catch (err) {
      logger.error({ err }, "sync worker error");
    }
  });

  logger.info("Scheduler started");
}
