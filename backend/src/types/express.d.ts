
export interface AuthPayload {
  sub: string;
  subType: "owner" | "staff";
  farmId: string;
  modules: string[];
  role: string;
  farmOwnerId: string;
  jti?: string;
}

declare global {
  namespace Express {
    interface Request {
      auth: AuthPayload;
      /** Unique request identifier for tracing */
      id: string;
    }
  }
}

export { };

