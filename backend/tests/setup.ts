import { afterAll, beforeAll, vi } from "vitest";

// Mock env before any module loads
vi.stubEnv("NODE_ENV", "test");
vi.stubEnv("DATABASE_URL", "mysql://test:test@localhost:3306/4dfarmer_test");
vi.stubEnv("JWT_ACCESS_SECRET", "test-access-secret-min-32-chars-long!!");
vi.stubEnv("JWT_REFRESH_SECRET", "test-refresh-secret-min-32-chars-long!");
vi.stubEnv("JWT_ACCESS_TTL", "900");
vi.stubEnv("JWT_REFRESH_TTL", "604800");
vi.stubEnv("PORT", "3001");
vi.stubEnv("SMTP_HOST", "localhost");
vi.stubEnv("SMTP_PORT", "1025");
vi.stubEnv("SMTP_USER", "test");
vi.stubEnv("SMTP_PASS", "test");
vi.stubEnv("EMAIL_FROM", "noreply@test.com");
vi.stubEnv("FRONTEND_URL", "http://localhost:3000");
vi.stubEnv("CORS_ORIGINS", "http://localhost:3000");

beforeAll(() => {
  // Global setup
});

afterAll(() => {
  // Global teardown
});
