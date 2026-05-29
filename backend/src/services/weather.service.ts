import { LRUCache } from "lru-cache";

const cache = new LRUCache<string, object>({
  max: 200,
  ttl: 15 * 60 * 1000, // 15 minutes
});

const BASE = "https://api.open-meteo.com/v1";

async function fetchWeather(url: string): Promise<object> {
  const res = await fetch(url);
  if (!res.ok)
    throw Object.assign(new Error("Weather API unavailable"), {
      status: 502,
      code: "WEATHER_ERROR",
    });
  return res.json() as Promise<object>;
}

export const weatherService = {
  getCurrent: async (lat: number, lon: number) => {
    const key = `current:${lat}:${lon}`;
    if (cache.has(key)) return cache.get(key);
    const url =
      `${BASE}/forecast?latitude=${lat}&longitude=${lon}` +
      `&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code` +
      `&timezone=auto`;
    const data = await fetchWeather(url);
    cache.set(key, data);
    return data;
  },

  getForecast: async (lat: number, lon: number) => {
    const key = `forecast:${lat}:${lon}`;
    if (cache.has(key)) return cache.get(key);
    const url =
      `${BASE}/forecast?latitude=${lat}&longitude=${lon}` +
      `&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,weather_code` +
      `&timezone=auto&forecast_days=7`;
    const data = await fetchWeather(url);
    cache.set(key, data);
    return data;
  },

  // Open-Meteo does not expose an alerts endpoint; return empty structure
  getAlerts: (_lat: number, _lon: number) =>
    Promise.resolve({ alerts: [] as unknown[] }),
};
