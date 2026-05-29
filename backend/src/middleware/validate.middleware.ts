import { NextFunction, Request, Response } from "express";
import { ZodError, ZodSchema } from "zod";
import { sendError } from "../lib/response";

export function validate(
  schema: ZodSchema,
  source: "body" | "query" | "params" = "body",
) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req[source]);
    if (!result.success) {
      const message = (result.error as ZodError).errors
        .map((e) => `${e.path.join(".")}: ${e.message}`)
        .join("; ");
      sendError(res, 422, "VALIDATION_ERROR", message);
      return;
    }
    req[source] = result.data as never;
    next();
  };
}
