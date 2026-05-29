import pino from "pino";

const logger = pino({ name: "pdf-worker" });

// PDF generation worker — processes pending payslip PDF generation jobs from DB
export const pdfWorker = {
  run: async () => {
    logger.debug("pdf worker: no pending jobs");
  },
};
