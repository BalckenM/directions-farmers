import { describe, expect, it } from "vitest";
import { parsePagination } from "../../src/lib/pagination";

describe("parsePagination", () => {
  it("returns defaults for empty query", () => {
    const result = parsePagination({});
    expect(result).toEqual({ page: 1, limit: 20, offset: 0 });
  });

  it("parses valid page and limit", () => {
    const result = parsePagination({ page: "3", limit: "10" });
    expect(result).toEqual({ page: 3, limit: 10, offset: 20 });
  });

  it("clamps limit to max 100", () => {
    const result = parsePagination({ limit: "500" });
    expect(result.limit).toBe(100);
  });

  it("clamps limit to min 1", () => {
    const result = parsePagination({ limit: "0" });
    expect(result.limit).toBe(1);
  });

  it("defaults page to 1 for invalid input", () => {
    const result = parsePagination({ page: "abc" });
    expect(result.page).toBe(1);
  });
});
