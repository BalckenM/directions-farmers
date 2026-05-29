import { SignJWT, jwtVerify } from "jose";
import { env } from "../config/env";
import type { JwtPayload } from "../types/api.types";

const secret = new TextEncoder().encode(env.JWT_SECRET);

export async function signAccessToken(payload: JwtPayload): Promise<string> {
  return new SignJWT({ ...payload })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(`${env.ACCESS_TOKEN_TTL}s`)
    .sign(secret);
}

export async function signRefreshToken(
  payload: Pick<JwtPayload, "sub" | "subType">,
): Promise<string> {
  return new SignJWT({ ...payload })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(`${env.REFRESH_TOKEN_TTL}s`)
    .sign(secret);
}

export async function verifyToken(token: string): Promise<JwtPayload> {
  const { payload } = await jwtVerify(token, secret);
  return payload as unknown as JwtPayload;
}
