// Market price reference data — South African agricultural commodity prices

interface MarketPrice {
  commodity: string;
  unit: string;
  price: number;
  currency: string;
  market: string;
  date: string;
}

function today(): string {
  return new Date().toISOString().split("T")[0]!;
}

const PRICES: MarketPrice[] = [
  { commodity: "Beef (per kg live weight)", unit: "kg", price: 28, currency: "ZAR", market: "National Average", date: today() },
  { commodity: "Mutton (per kg live weight)", unit: "kg", price: 32, currency: "ZAR", market: "National Average", date: today() },
  { commodity: "Goat (live, per head)", unit: "head", price: 1200, currency: "ZAR", market: "National Average", date: today() },
  { commodity: "Cattle Weaner (per head)", unit: "head", price: 8500, currency: "ZAR", market: "National Average", date: today() },
  { commodity: "Milk (per litre)", unit: "litre", price: 6.5, currency: "ZAR", market: "Producer Price", date: today() },
  { commodity: "Eggs (per dozen)", unit: "dozen", price: 32, currency: "ZAR", market: "Retail", date: today() },
  { commodity: "Wool (greasy, per kg)", unit: "kg", price: 55, currency: "ZAR", market: "Export Parity", date: today() },
  { commodity: "Yellow Maize (per ton)", unit: "ton", price: 3800, currency: "ZAR", market: "SAFEX", date: today() },
  { commodity: "White Maize (per ton)", unit: "ton", price: 3950, currency: "ZAR", market: "SAFEX", date: today() },
  { commodity: "Wheat (per ton)", unit: "ton", price: 5200, currency: "ZAR", market: "SAFEX", date: today() },
  { commodity: "Sunflower (per ton)", unit: "ton", price: 7100, currency: "ZAR", market: "SAFEX", date: today() },
  { commodity: "Soybeans (per ton)", unit: "ton", price: 8300, currency: "ZAR", market: "SAFEX", date: today() },
];

export const insightsService = {
  getMarketPrices: (commodity?: string): MarketPrice[] => {
    if (commodity) {
      const lower = commodity.toLowerCase();
      return PRICES.filter((p) => p.commodity.toLowerCase().includes(lower));
    }
    return PRICES;
  },
};
