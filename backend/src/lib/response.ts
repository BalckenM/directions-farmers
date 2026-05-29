import type { Response } from "express";
import type { PaginationMeta } from "../types/api.types";

export function sendOne<T>(res: Response, data: T, status = 200): void {
  res.status(status).json({ data });
}

export function sendList<T>(
  res: Response,
  data: T[],
  meta: PaginationMeta,
): void {
  res.status(200).json({ data, meta });
}

export function sendError(
  res: Response,
  status: number,
  code: string,
  message: string,
): void {
  res.status(status).json({ error: { code, message } });
}

export function sendNoContent(res: Response): void {
  res.status(204).end();
}
