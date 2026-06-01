import dotenv from "dotenv";
import { z } from "zod";

dotenv.config();

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(32),
  ACCESS_TOKEN_TTL: z.coerce.number().int().positive().default(900),
  REFRESH_TOKEN_TTL: z.coerce.number().int().positive().default(2592000),
  SMTP_HOST: z.string().min(1),
  SMTP_PORT: z.coerce.number().int().positive().default(587),
  SMTP_USER: z.string().min(1),
  SMTP_PASS: z.string().min(1),
  EMAIL_FROM: z.string().email(),
  APP_URL: z.string().url(),
  PORT: z.coerce.number().int().positive().default(3000),
  NODE_ENV: z
    .enum(["development", "test", "production"])
    .default("development"),
  ALLOWED_ORIGINS: z
    .string()
    .min(1)
    .default("http://localhost:8080,http://localhost:3000"),
  WEATHER_API_KEY: z.string().optional(),
  ADVISOR_API_KEY: z.string().optional(),
  DISEASE_API_KEY: z.string().optional(),
  // Redis (optional — falls back to in-memory stores if unset)
  REDIS_URL: z.string().url().optional(),
  // Social auth provider credentials (optional — social login disabled if unset)
  GOOGLE_CLIENT_ID: z.string().optional(),
  APPLE_CLIENT_ID: z.string().optional(),
  FACEBOOK_APP_ID: z.string().optional(),
  FACEBOOK_APP_SECRET: z.string().optional(),
});

const result = envSchema.safeParse(process.env);

if (!result.success) {
  console.error(
    "Invalid environment variables:",
    result.error.flatten().fieldErrors,
  );
  process.exit(1);
}

export const env = result.data;
