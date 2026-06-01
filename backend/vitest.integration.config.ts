import { defineConfig } from "vitest/config";

/**
 * Vitest config for INTEGRATION tests.
 * - Uses the real .env (no mocked env vars)
 * - Connects to the real database
 * - Setup file registers + authenticates a test user
 *
 * Run: npx vitest run --config vitest.integration.config.ts
 */
export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    setupFiles: ["./tests/integration/setup.ts"],
    include: ["tests/integration/**/*.test.ts"],
    testTimeout: 60000,
    hookTimeout: 60000,
    pool: "forks",
    poolOptions: {
      forks: { singleFork: true },
    },
  },
});
