/// Static vaccination schedule reference data for common poultry production types.
library;

typedef VaccineEntry = ({int dayOfAge, String vaccine, String route});

class VaccinationReference {
  const VaccinationReference._();

  static const List<VaccineEntry> _broiler = [
    (dayOfAge: 1, vaccine: "Marek's Disease (in-ovo)", route: 'Subcutaneous'),
    (dayOfAge: 7, vaccine: 'Newcastle Disease (LaSota)', route: 'Eye drop'),
    (dayOfAge: 14, vaccine: 'Infectious Bronchitis (H120)', route: 'Drinking water'),
    (dayOfAge: 18, vaccine: 'Gumboro IBD (intermediate)', route: 'Drinking water'),
    (dayOfAge: 24, vaccine: 'Gumboro IBD (booster)', route: 'Drinking water'),
  ];

  static const List<VaccineEntry> _layer = [
    (dayOfAge: 1, vaccine: "Marek's Disease", route: 'Subcutaneous'),
    (dayOfAge: 7, vaccine: 'Newcastle + IB (Ma5+Clone30)', route: 'Spray'),
    (dayOfAge: 14, vaccine: 'Gumboro IBD', route: 'Drinking water'),
    (dayOfAge: 28, vaccine: 'Newcastle Disease (LaSota)', route: 'Eye drop'),
    (dayOfAge: 42, vaccine: 'Infectious Laryngotracheitis', route: 'Eye drop'),
    (dayOfAge: 56, vaccine: 'Newcastle + IB booster', route: 'Drinking water'),
    (dayOfAge: 112, vaccine: 'Newcastle N2a (killed)', route: 'Injection'),
  ];

  static const List<VaccineEntry> _duck = [
    (dayOfAge: 7, vaccine: 'Duck Hepatitis Virus Type 1 (DHV-1)', route: 'Subcutaneous'),
    (dayOfAge: 14, vaccine: 'Duck Plague (DVE)', route: 'Subcutaneous'),
  ];

  static const List<VaccineEntry> _turkey = [
    (dayOfAge: 1, vaccine: "Marek's Disease", route: 'Subcutaneous'),
    (dayOfAge: 7, vaccine: 'Newcastle Disease (La Sota)', route: 'Eye drop'),
    (dayOfAge: 21, vaccine: 'Hemorrhagic Enteritis (HE)', route: 'Drinking water'),
    (dayOfAge: 28, vaccine: 'Fowl Cholera', route: 'Injection'),
  ];

  /// Returns the reference vaccination schedule for a given [productionType].
  /// Recognised values (case-insensitive): broiler, layer, duck, turkey.
  /// Falls back to the broiler schedule for unknown types.
  static List<VaccineEntry> forProductionType(String productionType) {
    return switch (productionType.toLowerCase()) {
      'layer' || 'layers' => _layer,
      'duck' || 'ducks' => _duck,
      'turkey' || 'turkeys' => _turkey,
      _ => _broiler, // default: broiler
    };
  }

  /// Computes absolute due dates from a [placementDate] and the schedule
  /// entries' [VaccineEntry.dayOfAge] offsets.
  static List<({DateTime dueDate, String vaccine, String route})> scheduledDates({
    required DateTime placementDate,
    required String productionType,
  }) {
    final entries = forProductionType(productionType);
    return entries
        .map((e) => (
              dueDate: placementDate.add(Duration(days: e.dayOfAge)),
              vaccine: e.vaccine,
              route: e.route,
            ))
        .toList();
  }
}
