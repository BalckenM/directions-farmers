export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
}

export interface ListResponse<T> {
  data: T[];
  meta: PaginationMeta;
}

export interface SingleResponse<T> {
  data: T;
}

export interface ErrorResponse {
  error: {
    code: string;
    message: string;
  };
}

export interface JwtPayload {
  sub: string;
  subType: "owner" | "staff";
  farmId: string;
  modules: string[];
  role: string;
  jti?: string;
  iss?: string;
  aud?: string;
}
