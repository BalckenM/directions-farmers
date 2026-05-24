// Payslip label localisation for the four languages most commonly spoken
// by farm workers in South Africa: English, Afrikaans, isiZulu, isiXhosa.
//
// Usage:
//   final labels = PayslipL10n.labelsFor(PayslipLocale.afrikaans);
//   Text(labels[PayslipLabel.grossPay]!);

// ─── Locale enum ─────────────────────────────────────────────────────────────

enum PayslipLocale {
  english,
  afrikaans,
  zulu,
  xhosa,
}

extension PayslipLocaleX on PayslipLocale {
  String get displayName => switch (this) {
        PayslipLocale.english   => 'English',
        PayslipLocale.afrikaans => 'Afrikaans',
        PayslipLocale.zulu      => 'isiZulu',
        PayslipLocale.xhosa     => 'isiXhosa',
      };
}

// ─── Label keys ──────────────────────────────────────────────────────────────

enum PayslipLabel {
  employee,
  employer,
  payPeriod,
  payDate,

  // Earnings
  basicWage,
  overtime,
  holidayPay,
  nightShift,
  commission,
  bonus,
  otherEarnings,
  totalEarnings,
  grossPay,

  // In-kind
  housingAllowance,

  // Deductions
  deductions,
  paye,
  uif,
  sdl,
  pension,
  providentFund,
  medicalAid,
  retirementAnnuity,
  garnishee,
  totalDeductions,

  // Bottom line
  netPay,
  hoursWorked,
  overtimeHours,

  // Certificate
  taxCertificate,
  eti,

  // General
  total,
  notes,
}

// ─── Translation tables ───────────────────────────────────────────────────────

class PayslipL10n {
  PayslipL10n._();

  static const Map<PayslipLabel, String> _en = {
    PayslipLabel.employee        : 'Employee',
    PayslipLabel.employer        : 'Employer',
    PayslipLabel.payPeriod       : 'Pay Period',
    PayslipLabel.payDate         : 'Pay Date',
    PayslipLabel.basicWage       : 'Basic Wage',
    PayslipLabel.overtime        : 'Overtime',
    PayslipLabel.holidayPay      : 'Holiday Pay',
    PayslipLabel.nightShift      : 'Night Shift Premium',
    PayslipLabel.commission      : 'Commission',
    PayslipLabel.bonus           : 'Bonus',
    PayslipLabel.otherEarnings   : 'Other Earnings',
    PayslipLabel.totalEarnings   : 'Total Earnings',
    PayslipLabel.grossPay        : 'Gross Pay',
    PayslipLabel.housingAllowance: 'Housing Allowance',
    PayslipLabel.deductions      : 'Deductions',
    PayslipLabel.paye            : 'Income Tax (PAYE)',
    PayslipLabel.uif             : 'UIF',
    PayslipLabel.sdl             : 'Skills Development Levy (SDL)',
    PayslipLabel.pension         : 'Pension Fund',
    PayslipLabel.providentFund   : 'Provident Fund',
    PayslipLabel.medicalAid      : 'Medical Aid',
    PayslipLabel.retirementAnnuity: 'Retirement Annuity',
    PayslipLabel.garnishee       : 'Garnishee Order',
    PayslipLabel.totalDeductions : 'Total Deductions',
    PayslipLabel.netPay          : 'Net Pay',
    PayslipLabel.hoursWorked     : 'Hours Worked',
    PayslipLabel.overtimeHours   : 'Overtime Hours',
    PayslipLabel.taxCertificate  : 'Tax Certificate',
    PayslipLabel.eti             : 'Employment Tax Incentive (ETI)',
    PayslipLabel.total           : 'Total',
    PayslipLabel.notes           : 'Notes',
  };

  static const Map<PayslipLabel, String> _af = {
    PayslipLabel.employee        : 'Werknemer',
    PayslipLabel.employer        : 'Werkgewer',
    PayslipLabel.payPeriod       : 'Betalingstydperk',
    PayslipLabel.payDate         : 'Betalingsdatum',
    PayslipLabel.basicWage       : 'Basiese Loon',
    PayslipLabel.overtime        : 'Oortyd',
    PayslipLabel.holidayPay      : 'Vakansiegeld',
    PayslipLabel.nightShift      : 'Nagskofpremie',
    PayslipLabel.commission      : 'Kommissie',
    PayslipLabel.bonus           : 'Bonus',
    PayslipLabel.otherEarnings   : 'Ander Verdienste',
    PayslipLabel.totalEarnings   : 'Totale Verdienste',
    PayslipLabel.grossPay        : 'Brutoloon',
    PayslipLabel.housingAllowance: 'Behuisingstoelaag',
    PayslipLabel.deductions      : 'Aftrekkings',
    PayslipLabel.paye            : 'Inkomstebelasting (PAYE)',
    PayslipLabel.uif             : 'WVF',
    PayslipLabel.sdl             : 'Vaardigheidsontwikkelingsheffing (VOH)',
    PayslipLabel.pension         : 'Pensioenfonds',
    PayslipLabel.providentFund   : 'Voorsorgfonds',
    PayslipLabel.medicalAid      : 'Mediese Hulp',
    PayslipLabel.retirementAnnuity: 'Aftreeleifrente',
    PayslipLabel.garnishee       : 'Beslagleggingsbevel',
    PayslipLabel.totalDeductions : 'Totale Aftrekkings',
    PayslipLabel.netPay          : 'Nettoloon',
    PayslipLabel.hoursWorked     : 'Gewerkte Ure',
    PayslipLabel.overtimeHours   : 'Oortydure',
    PayslipLabel.taxCertificate  : 'Belastingsertifikaat',
    PayslipLabel.eti             : 'Belastingaansporings vir Indiensneming (ETI)',
    PayslipLabel.total           : 'Totaal',
    PayslipLabel.notes           : 'Aantekeninge',
  };

  static const Map<PayslipLabel, String> _zu = {
    PayslipLabel.employee        : 'Umsebenzi',
    PayslipLabel.employer        : 'Umqashi',
    PayslipLabel.payPeriod       : 'Isikhathi Sokukhokha',
    PayslipLabel.payDate         : 'Usuku Lokukhokha',
    PayslipLabel.basicWage       : 'Iholo Elikhulu',
    PayslipLabel.overtime        : 'Isikhathi Esengeziwe',
    PayslipLabel.holidayPay      : 'Inkokhelo Yeholide',
    PayslipLabel.nightShift      : 'Inkokhelo Yasebusuku',
    PayslipLabel.commission      : 'Ikhomishani',
    PayslipLabel.bonus           : 'Ibhonasi',
    PayslipLabel.otherEarnings   : 'Ezinye Izimali',
    PayslipLabel.totalEarnings   : 'Imali Eyonke',
    PayslipLabel.grossPay        : 'Iholo Elingenamali Ehluliwe',
    PayslipLabel.housingAllowance: 'Isibonelelo Sokuhlala',
    PayslipLabel.deductions      : 'Izinqunyiwe',
    PayslipLabel.paye            : 'Intela Yemali Engenayo (PAYE)',
    PayslipLabel.uif             : 'UIF',
    PayslipLabel.sdl             : 'Intela Yezakhono (SDL)',
    PayslipLabel.pension         : 'Isikhwama Sembuluzo',
    PayslipLabel.providentFund   : 'Isikhwama Sembuluzo Esingenamali Entela',
    PayslipLabel.medicalAid      : 'Usizo Lwezempilo',
    PayslipLabel.retirementAnnuity: 'Isiphakamiso Sokuphulukana Nomsebenzi',
    PayslipLabel.garnishee       : 'Isikhwama Sangaphandle',
    PayslipLabel.totalDeductions : 'Konke Okuhlunyiwe',
    PayslipLabel.netPay          : 'Iholo Elikhokhelwe',
    PayslipLabel.hoursWorked     : 'Amahora Asebenzile',
    PayslipLabel.overtimeHours   : 'Amahora Ezengeziwe',
    PayslipLabel.taxCertificate  : 'Isitifiketi Sentela',
    PayslipLabel.eti             : 'Isikhuthazo Sentela (ETI)',
    PayslipLabel.total           : 'Isamba',
    PayslipLabel.notes           : 'Amanothi',
  };

  static const Map<PayslipLabel, String> _xh = {
    PayslipLabel.employee        : 'Umsebenzi',
    PayslipLabel.employer        : 'Umqeshi',
    PayslipLabel.payPeriod       : 'Ixesha Lentlawulo',
    PayslipLabel.payDate         : 'Umhla Wentlawulo',
    PayslipLabel.basicWage       : 'Umvuzo Oyisiseko',
    PayslipLabel.overtime        : 'Ixesha Elingaphezulu',
    PayslipLabel.holidayPay      : 'Intlawulo Yeeholide',
    PayslipLabel.nightShift      : 'Inzuzo Yobusuku',
    PayslipLabel.commission      : 'Ikhomishini',
    PayslipLabel.bonus           : 'IBhonasi',
    PayslipLabel.otherEarnings   : 'Ezinye Iinzuzo',
    PayslipLabel.totalEarnings   : 'Inzuzo Yonke',
    PayslipLabel.grossPay        : 'Umvuzo Opheleleyo',
    PayslipLabel.housingAllowance: 'Inkxaso-Mali Yokuhlala',
    PayslipLabel.deductions      : 'Izifinyezelo',
    PayslipLabel.paye            : 'Irhafu Yemali Engenayo (PAYE)',
    PayslipLabel.uif             : 'UIF',
    PayslipLabel.sdl             : 'Irhafu Yokuphuhlisa Izakhono (SDL)',
    PayslipLabel.pension         : 'Igranti Yembuluzo',
    PayslipLabel.providentFund   : 'Igranti Yembuluzo Engenayo',
    PayslipLabel.medicalAid      : 'Uncedo Lwezempilo',
    PayslipLabel.retirementAnnuity: 'Inzuzo Yobuphoxo',
    PayslipLabel.garnishee       : 'Umyalelo Wesibhambathiso',
    PayslipLabel.totalDeductions : 'Izifinyezelo Zonke',
    PayslipLabel.netPay          : 'Umvuzo Wangempela',
    PayslipLabel.hoursWorked     : 'Iiyure Ezimsebenzileyo',
    PayslipLabel.overtimeHours   : 'Iiyure Ezithe Ngaphezulu',
    PayslipLabel.taxCertificate  : 'Isatifikethi Serhafu',
    PayslipLabel.eti             : 'Inkuthazo Yerhafu Yengqesho (ETI)',
    PayslipLabel.total           : 'Isiqulatho',
    PayslipLabel.notes           : 'Amanqaku',
  };

  /// Returns the full label map for [locale].
  static Map<PayslipLabel, String> labelsFor(PayslipLocale locale) =>
      switch (locale) {
        PayslipLocale.english   => _en,
        PayslipLocale.afrikaans => _af,
        PayslipLocale.zulu      => _zu,
        PayslipLocale.xhosa     => _xh,
      };

  /// Convenience: translate a single label to the given locale.
  static String translate(PayslipLabel label, PayslipLocale locale) =>
      labelsFor(locale)[label] ?? _en[label]!;
}
