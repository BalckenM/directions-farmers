// ── Module slugs (mirrors Flutter feature paths) ──────────────────────────────
abstract final class FarmerModules {
  static const cattle = 'cattle';
  static const goat = 'goat';
  static const poultry = 'poultry';
  static const pigs = 'pigs';
  static const apiculture = 'apiculture';
  static const crop = 'crop';
  static const financial = 'financial';
  static const insights = 'insights';
  static const traceability = 'traceability';
  static const reports = 'reports';
}

// ── Subscription plan definitions ─────────────────────────────────────────────

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.label,
    required this.price,
    required this.currency,
    required this.tagline,
    required this.includedModules,
    required this.features,
  });

  final String id;
  final String label;
  final int price;
  final String currency;
  final String tagline;
  final List<String> includedModules;
  final List<String> features;
}

const List<SubscriptionPlan> kSubscriptionPlans = [
  SubscriptionPlan(
    id: 'starter',
    label: 'Starter',
    price: 199,
    currency: 'ZAR',
    tagline: 'Perfect for small family farms',
    includedModules: [
      FarmerModules.cattle,
      FarmerModules.goat,
      FarmerModules.poultry,
      FarmerModules.pigs,
    ],
    features: [
      'Up to 4 livestock species',
      'Health & vaccination tracking',
      'Basic production records',
      'Breeding & calving/kidding records',
      '30-day data history',
    ],
  ),
  SubscriptionPlan(
    id: 'growth',
    label: 'Growth',
    price: 499,
    currency: 'ZAR',
    tagline: 'Scale your farming operation',
    includedModules: [
      FarmerModules.cattle,
      FarmerModules.goat,
      FarmerModules.poultry,
      FarmerModules.pigs,
      FarmerModules.apiculture,
      FarmerModules.crop,
      FarmerModules.financial,
      FarmerModules.insights,
    ],
    features: [
      'Everything in Starter',
      'Crop farming & season planner',
      'Financial records & profitability',
      'Apiculture module',
      'Analytics & insights dashboard',
      'Unlimited data history',
    ],
  ),
  SubscriptionPlan(
    id: 'enterprise',
    label: 'Enterprise',
    price: 999,
    currency: 'ZAR',
    tagline: 'Full-scale commercial farming',
    includedModules: [
      FarmerModules.cattle,
      FarmerModules.goat,
      FarmerModules.poultry,
      FarmerModules.pigs,
      FarmerModules.apiculture,
      FarmerModules.crop,
      FarmerModules.financial,
      FarmerModules.insights,
      FarmerModules.traceability,
      FarmerModules.reports,
    ],
    features: [
      'Everything in Growth',
      'Animal movement traceability',
      'Automated PDF/CSV reports',
      'Multi-farm support (coming soon)',
      'Priority support',
      'Early access to new features',
    ],
  ),
];

// ── Country → Province data ───────────────────────────────────────────────────

const Map<String, List<String>> kCountryProvinces = {
  'South Africa': [
    'Eastern Cape',
    'Free State',
    'Gauteng',
    'KwaZulu-Natal',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Northern Cape',
    'Western Cape',
  ],
  'Zimbabwe': [
    'Bulawayo',
    'Harare',
    'Manicaland',
    'Mashonaland Central',
    'Mashonaland East',
    'Mashonaland West',
    'Masvingo',
    'Matabeleland North',
    'Matabeleland South',
    'Midlands',
  ],
  'Zambia': [
    'Central',
    'Copperbelt',
    'Eastern',
    'Luapula',
    'Lusaka',
    'Muchinga',
    'Northern',
    'North-Western',
    'Southern',
    'Western',
  ],
  'Kenya': [
    'Central',
    'Coast',
    'Eastern',
    'Nairobi',
    'North Eastern',
    'Nyanza',
    'Rift Valley',
    'Western',
  ],
  'Other': ['N/A'],
};
