import { beforeEach, describe, expect, it, vi } from "vitest";

// Mock database and repositories before importing auth service
vi.mock("../../src/repositories/auth.repo", () => ({
  authRepo: {
    findOwnerByEmail: vi.fn(),
    createOwner: vi.fn(),
    saveRefreshToken: vi.fn(),
    findOwnerById: vi.fn(),
    saveEmailVerificationToken: vi.fn(),
  },
}));

vi.mock("../../src/services/email.service", () => ({
  emailService: {
    sendVerificationEmail: vi.fn(),
  },
}));

vi.mock("../../src/lib/token-store", () => ({
  revokeToken: vi.fn(),
  isRevoked: vi.fn().mockReturnValue(false),
}));

import { authRepo } from "../../src/repositories/auth.repo";
import { authService } from "../../src/services/auth.service";

describe("authService.register", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("throws if email already exists", async () => {
    vi.mocked(authRepo.findOwnerByEmail).mockResolvedValue({
      id: "existing",
    } as never);

    await expect(
      authService.register({
        email: "a@b.com",
        password: "pass123456",
        farmName: "Farm",
      }),
    ).rejects.toMatchObject({ status: 409 });
  });

  it("creates owner and returns tokens", async () => {
    vi.mocked(authRepo.findOwnerByEmail).mockResolvedValue(null);
    vi.mocked(authRepo.createOwner).mockResolvedValue(undefined);
    vi.mocked(authRepo.saveRefreshToken).mockResolvedValue(undefined);
    vi.mocked(authRepo.saveEmailVerificationToken).mockResolvedValue(undefined);

    const result = await authService.register({
      email: "new@b.com",
      password: "pass123456",
      farmName: "Farm",
    });
    expect(result).toHaveProperty("accessToken");
    expect(result).toHaveProperty("refreshToken");
  });
});
