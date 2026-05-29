
export interface AuthPayload {
  sub: string;
  subType: "owner" | "staff";
  farmId: string;
  modules: string[];
  role: string;
  farmOwnerId: string;
}

declare global {
  namespace Express {
    interface Request {
      auth: AuthPayload;
    }
  }
}

export { };

