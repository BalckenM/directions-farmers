import type { NextFunction, Request, Response } from "express";
import pino from "pino";
import { sendError } from "../lib/response";

const logger = pino({ name: "error-handler" });

interface AppError extends Error {
  status?: number;
  code?: string;
}

export function errorHandler(
  err: AppError,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  const status = typeof err.status === "number" ? err.status : 500;
  const code = err.code ?? "INTERNAL_ERROR";

  // Only expose message for client errors; mask internals for 5xx
  const message =
    status < 500 ? err.message : "An unexpected error occurred";

  if (status >= 500) {
    logger.error({ err }, "Unhandled server error");
  }

  sendError(res, status, code, message);
}
