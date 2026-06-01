import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("../../src/repositories/goat.repo", () => ({
  goatRepo: {
    listAnimals: vi.fn().mockResolvedValue({ rows: [], total: 0 }),
    findAnimalById: vi.fn().mockResolvedValue(null),
    createAnimal: vi.fn().mockResolvedValue(undefined),
    updateAnimal: vi.fn().mockResolvedValue(undefined),
    deleteAnimal: vi.fn().mockResolvedValue(undefined),
  },
}));

import { goatRepo } from "../../src/repositories/goat.repo";
import { goatService } from "../../src/services/goat/goat.service";

describe("goatService", () => {
  const farmOwnerId = "owner-1";

  beforeEach(() => vi.clearAllMocks());

  it("listAnimals returns paginated result", async () => {
    const result = await goatService.listAnimals(farmOwnerId, {});
    expect(result.data).toEqual([]);
    expect(result.meta.total).toBe(0);
  });

  it("getAnimal throws 404 when not found", async () => {
    vi.mocked(goatRepo.findAnimalById).mockResolvedValue(null);
    await expect(
      goatService.getAnimal(farmOwnerId, "nonexistent"),
    ).rejects.toMatchObject({ status: 404 });
  });
});
