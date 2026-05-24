import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/payroll_employee.dart';
import '../models/payslip.dart';

// ─── Brand colours ─────────────────────────────────────────────────────────────
final _navy = PdfColor.fromHex('1E3A5F');
final _teal = PdfColor.fromHex('00695C');
final _green = PdfColor.fromHex('2E7D32');
final _rose = PdfColor.fromHex('C62828');
final _amber = PdfColor.fromHex('F57F17');
final _grey = PdfColor.fromHex('757575');

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);
final _zarInt = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);
final _dateFmt = DateFormat('d MMMM y');
final _mf = DateFormat('MMMM y');

abstract final class PayslipPdfGenerator {
  // ─── Translation tables ──────────────────────────────────────────────────
  /// Map of [languageCode] → label key → translated string.
  /// All 11 South African official languages are supported:
  ///   'en'  English       'af'  Afrikaans      'zu'  isiZulu
  ///   'xh'  isiXhosa      'st'  Sesotho        'tn'  Setswana
  ///   'ts'  Xitsonga      've'  Tshivenda      'nr'  isiNdebele
  ///   'ss'  siSwati       'nso' Sepedi
  static const Map<String, Map<String, String>> _i18n = {
    // ── English ─────────────────────────────────────────────────────────────
    'en': {
      'PAYSLIP': 'PAYSLIP',
      'EMPLOYEE': 'EMPLOYEE',
      'EARNINGS': 'EARNINGS',
      'DEDUCTIONS': 'DEDUCTIONS',
      'LEAVE BALANCES': 'LEAVE BALANCES',
      'Basic Wage': 'Basic Wage',
      'Overtime Pay': 'Overtime Pay',
      'Holiday Pay': 'Holiday Pay',
      'Housing (in-kind)': 'Housing (in-kind)',
      'Food (in-kind)': 'Food (in-kind)',
      'Other Earnings': 'Other Earnings',
      'Gross Pay': 'Gross Pay',
      'Net Pay': 'Net Pay',
      'Period': 'Period',
      'Pay Date': 'Pay Date',
      'Payslip #': 'Payslip #',
      'Annual': 'Annual',
      'Name': 'Name',
      'ID / Passport': 'ID / Passport',
      'Occupation': 'Occupation',
      'Bank': 'Bank',
      'Branch Code': 'Branch Code',
    },
    // ── Afrikaans ────────────────────────────────────────────────────────────
    'af': {
      'PAYSLIP': 'LOONSTROKIE',
      'EMPLOYEE': 'WERKNEMER',
      'EARNINGS': 'VERDIENSTE',
      'DEDUCTIONS': 'AFTREKKINGS',
      'LEAVE BALANCES': 'VERLOF SALDO',
      'Basic Wage': 'Basiese Loon',
      'Overtime Pay': 'Oortyd Betaling',
      'Holiday Pay': 'Vakansie Betaling',
      'Housing (in-kind)': 'Behuising (in natura)',
      'Food (in-kind)': 'Kos (in natura)',
      'Other Earnings': 'Ander Verdienste',
      'Gross Pay': 'Bruto Loon',
      'Net Pay': 'Netto Loon',
      'Period': 'Tydperk',
      'Pay Date': 'Betaaldatum',
      'Payslip #': 'Loonstrokie #',
      'Annual': 'Jaarliks',
      'Name': 'Naam',
      'ID / Passport': 'ID / Paspoort',
      'Occupation': 'Beroep',
      'Bank': 'Bank',
      'Branch Code': 'Takkode',
    },
    // ── isiZulu ──────────────────────────────────────────────────────────────
    'zu': {
      'PAYSLIP': 'ISICWECWE SOKUKHOKHA',
      'EMPLOYEE': 'ISISEBENZI',
      'EARNINGS': 'IMALI EHOLWAYO',
      'DEDUCTIONS': 'UKUSUSWA',
      'LEAVE BALANCES': 'INSALELA YEHOLIDE',
      'Basic Wage': 'Iholo Elikhokhelwayo',
      'Overtime Pay': 'Inkokhelo Yesikhathi Esengeziwe',
      'Holiday Pay': 'Inkokhelo Yeholide',
      'Housing (in-kind)': 'Indawo Yokuhlala',
      'Food (in-kind)': 'Ukudla (in-kind)',
      'Other Earnings': 'Enye Imali',
      'Gross Pay': 'Inkokhelo Enkulu',
      'Net Pay': 'Inkokhelo Enethiwe',
      'Period': 'Isikhathi',
      'Pay Date': 'Usuku Lokukhokha',
      'Payslip #': 'Isicwecwe #',
      'Annual': 'Ngamonyaka',
      'Name': 'Igama',
      'ID / Passport': 'ID / Pasipoti',
      'Occupation': 'Umsebenzi',
      'Bank': 'Ibhange',
      'Branch Code': 'Ikhodi Yebranchi',
    },
    // ── isiXhosa ─────────────────────────────────────────────────────────────
    'xh': {
      'PAYSLIP': 'ISIQEPHU SEMALI',
      'EMPLOYEE': 'ISISEBENZI',
      'EARNINGS': 'IMALI EKHOKHELWAYO',
      'DEDUCTIONS': 'UKUTSALWA',
      'LEAVE BALANCES': 'IRESALISHI YELIPHULI',
      'Basic Wage': 'Umvuzo Owunchangololo',
      'Overtime Pay': 'Imbuyekezo Yexesha Elingaphezulu',
      'Holiday Pay': 'Imbuyekezo Yeholide',
      'Housing (in-kind)': 'Indlu (ngendlela)',
      'Food (in-kind)': 'Ukutya (ngendlela)',
      'Other Earnings': 'Enye Imali',
      'Gross Pay': 'Umvuzo Omkhulu',
      'Net Pay': 'Umvuzo Omsulwa',
      'Period': 'Ixesha',
      'Pay Date': 'Usuku Lokuhlawula',
      'Payslip #': 'Isiqephu #',
      'Annual': 'Rhoqo Ngonyaka',
      'Name': 'Igama',
      'ID / Passport': 'ID / Ipasipoti',
      'Occupation': 'Umsebenzi',
      'Bank': 'IBhanki',
      'Branch Code': 'Ikhowudi Yesebe',
    },
    // ── Sesotho ──────────────────────────────────────────────────────────────
    'st': {
      'PAYSLIP': 'MOKOTLA OA MOPUTSO',
      'EMPLOYEE': 'MOSEBETSI',
      'EARNINGS': 'MEPUTSO',
      'DEDUCTIONS': 'DIKGETHO',
      'LEAVE BALANCES': 'PALOHELO EA TLOSO',
      'Basic Wage': 'Moputso o Tloaelehileng',
      'Overtime Pay': 'Tefelo ea Nako e Fetesang',
      'Holiday Pay': 'Tefelo ea Phomolo',
      'Housing (in-kind)': 'Ntlo (ka boleng)',
      'Food (in-kind)': 'Dijo (ka boleng)',
      'Other Earnings': 'Meputso e Meng',
      'Gross Pay': 'Moputso o Moholo',
      'Net Pay': 'Moputso o Hlwekisitsoeng',
      'Period': 'Nako',
      'Pay Date': 'Letsatsi la Tefelo',
      'Payslip #': 'Mokotla #',
      'Annual': 'Selemo se seng le se seng',
      'Name': 'Lebitso',
      'ID / Passport': 'ID / Pasepoto',
      'Occupation': 'Mosebetsi',
      'Bank': 'Banka',
      'Branch Code': 'Khoto ea Lekala',
    },
    // ── Setswana ─────────────────────────────────────────────────────────────
    'tn': {
      'PAYSLIP': 'PHEPHAFATSO YA MOTLHAPISI',
      'EMPLOYEE': 'MOITIRII',
      'EARNINGS': 'DITSHONO',
      'DEDUCTIONS': 'DIPHUTHEGO',
      'LEAVE BALANCES': 'DITHEPA TSA LAEFO',
      'Basic Wage': 'Tefelo e e Tlwaelegileng',
      'Overtime Pay': 'Tefelo ya Nako e e Fetang',
      'Holiday Pay': 'Tefelo ya Laefo',
      'Housing (in-kind)': 'Ntlo (go akaretsa)',
      'Food (in-kind)': 'Dijo (go akaretsa)',
      'Other Earnings': 'Ditshono tse Dingwe',
      'Gross Pay': 'Tefelo e Kgolo',
      'Net Pay': 'Tefelo e e Hlwekisitsweng',
      'Period': 'Nako',
      'Pay Date': 'Letsatsi la Tefo',
      'Payslip #': 'Phephafatso #',
      'Annual': 'Ngwaga',
      'Name': 'Leina',
      'ID / Passport': 'ID / Pasepoto',
      'Occupation': 'Tiro',
      'Bank': 'Banka',
      'Branch Code': 'Khoutho ya Lekala',
    },
    // ── Xitsonga ─────────────────────────────────────────────────────────────
    'ts': {
      'PAYSLIP': 'XIBALO XA NGHENI',
      'EMPLOYEE': 'MUTIRHI',
      'EARNINGS': 'SWINGHENELO',
      'DEDUCTIONS': 'SWIKUKULELO',
      'LEAVE BALANCES': 'XIRHO XA LUSWELO',
      'Basic Wage': 'Muholo Lowukulu',
      'Overtime Pay': 'Maholo ya Nkarhi wo Engeteleka',
      'Holiday Pay': 'Maholo ya Holoha',
      'Housing (in-kind)': 'Ndhawu yo Helela',
      'Food (in-kind)': 'Swakudya (swa ku nyikiwa)',
      'Other Earnings': "Swinghenelo Swin'wana",
      'Gross Pay': 'Muholo Lowukulu Hinkwaho',
      'Net Pay': 'Muholo Lowucheteleka',
      'Period': 'Nkarhi',
      'Pay Date': 'Siku ro Nyika Muholo',
      'Payslip #': 'Xibalo #',
      'Annual': 'Lembe',
      'Name': 'Vito',
      'ID / Passport': 'ID / Pasipoto',
      'Occupation': 'Ntirho',
      'Bank': 'Banka',
      'Branch Code': 'Khodi ya Ntlawa',
    },
    // ── Tshivenda ─────────────────────────────────────────────────────────────
    've': {
      'PAYSLIP': 'PEPA LA MUHATULI',
      'EMPLOYEE': 'MUSHUMELI',
      'EARNINGS': 'MBUELO',
      'DEDUCTIONS': 'DZITORESWA',
      'LEAVE BALANCES': 'MISALA YA MAFUNZHO',
      'Basic Wage': 'Muholo Mutukulu',
      'Overtime Pay': 'Muholo wa Tshifhinga Tshi Engedzeaho',
      'Holiday Pay': 'Muholo wa Duvha la Vhulamulaho',
      'Housing (in-kind)': 'Nndu (ndi mbuno)',
      'Food (in-kind)': 'Zwiliwha (zwi tuwadziwa)',
      'Other Earnings': 'Mbuelo nngwe',
      'Gross Pay': 'Muholo Mutukulu Wothe',
      'Net Pay': 'Muholo Mutuhu',
      'Period': 'Tshifhinga',
      'Pay Date': 'Duvha la Muholo',
      'Payslip #': 'Pepa #',
      'Annual': 'Nwaha',
      'Name': 'Dzina',
      'ID / Passport': 'ID / Pasipoto',
      'Occupation': 'Mushumo',
      'Bank': 'Banka',
      'Branch Code': 'Khodi ya Tshakha',
    },
    // ── isiNdebele ───────────────────────────────────────────────────────────
    'nr': {
      'PAYSLIP': 'ISIQEPHU SEMALI',
      'EMPLOYEE': 'ISISEBENZI',
      'EARNINGS': 'IMALI EKHOKHELWAYO',
      'DEDUCTIONS': 'UKUSUSWA KWEMALI',
      'LEAVE BALANCES': 'INSALELA YELIFU',
      'Basic Wage': 'Umvuzo Owunchangololo',
      'Overtime Pay': 'Imali Yesikhathi Esingaphezulu',
      'Holiday Pay': 'Imali Yelifu',
      'Housing (in-kind)': 'Indlu (ngendlela)',
      'Food (in-kind)': 'Ukudla (ngendlela)',
      'Other Earnings': 'Enye Imali',
      'Gross Pay': 'Umvuzo Omkhulu',
      'Net Pay': 'Umvuzo Omsulwa',
      'Period': 'Isikhathi',
      'Pay Date': 'Usuku Lokukhokha',
      'Payslip #': 'Isiqephu #',
      'Annual': 'Unyaka',
      'Name': 'Igama',
      'ID / Passport': 'ID / Ipasipoti',
      'Occupation': 'Umsebenzi',
      'Bank': 'IBhange',
      'Branch Code': 'Ikhodi Yesebe',
    },
    // ── siSwati ──────────────────────────────────────────────────────────────
    'ss': {
      'PAYSLIP': 'INCWADZI YEKUKHOKHA',
      'EMPLOYEE': 'SISEBENTI',
      'EARNINGS': 'IMALI LETFOLA',
      'DEDUCTIONS': 'KUKHIPHA EMALI',
      'LEAVE BALANCES': 'INSALELA YELIPHUMULELE',
      'Basic Wage': 'Umholo Losisekelo',
      'Overtime Pay': 'Inkokhelo Yesikhathi Lesingaphezulu',
      'Holiday Pay': 'Inkokhelo Yeliphumulele',
      'Housing (in-kind)': 'Indzawo Yekuhlala',
      'Food (in-kind)': 'Kudla (ngendlela)',
      'Other Earnings': 'Enye Imali',
      'Gross Pay': 'Inkokhelo Lenkhulu',
      'Net Pay': 'Inkokhelo Lehlobile',
      'Period': 'Isikhathi',
      'Pay Date': 'Lililanga Lekukhokha',
      'Payslip #': 'Incwadzi #',
      'Annual': 'Umnyaka',
      'Name': 'Ligama',
      'ID / Passport': 'ID / Iphasipoti',
      'Occupation': 'Umsebenzi',
      'Bank': 'IBhange',
      'Branch Code': 'Ikhodi Yegatsha',
    },
    // ── Sepedi (Northern Sotho) ──────────────────────────────────────────────
    'nso': {
      'PAYSLIP': 'PEPA LA MOPUTSO',
      'EMPLOYEE': 'MOSOMEDI',
      'EARNINGS': 'DITSENO',
      'DEDUCTIONS': 'DIKGEO',
      'LEAVE BALANCES': 'KHATO YA MATSALO',
      'Basic Wage': 'Moputso wa Motheo',
      'Overtime Pay': 'Tefelo ya Nako e Oketsegilego',
      'Holiday Pay': 'Tefelo ya Lephato',
      'Housing (in-kind)': 'Ntlo (ka bophelo)',
      'Food (in-kind)': 'Dijo (ka bophelo)',
      'Other Earnings': 'Ditseno tse Dingwe',
      'Gross Pay': 'Moputso wo Mogolo',
      'Net Pay': 'Moputso wo Hlwekago',
      'Period': 'Nako',
      'Pay Date': 'Letsatsi la Tefo',
      'Payslip #': 'Pepa #',
      'Annual': 'Ngwaga',
      'Name': 'Leina',
      'ID / Passport': 'ID / Pasepoto',
      'Occupation': 'Modiro',
      'Bank': 'Banka',
      'Branch Code': 'Khoutho ya Lekala',
    },
  };

  /// Resolve a label to the translated string for [language].
  /// Falls back to English if the key is not found in the given language.
  static String _t(String language, String key) {
    final lang = _i18n[language] ?? _i18n['en']!;
    return lang[key] ?? _i18n['en']![key] ?? key;
  }

  /// Returns the raw PDF bytes for [payslip].
  /// [employee] is optional — if null only the employee ID is shown.
  /// [language] selects the label language. All 11 SA official languages are
  /// supported: 'en', 'af', 'zu', 'xh', 'st', 'tn', 'ts', 've', 'nr', 'ss', 'nso'.
  static Future<List<int>> generate({
    required Payslip payslip,
    PayrollEmployee? employee,
    String language = 'en',
  }) async {
    final supported = {
      'en',
      'af',
      'zu',
      'xh',
      'st',
      'tn',
      'ts',
      've',
      'nr',
      'ss',
      'nso',
    };
    final lang = supported.contains(language) ? language : 'en';
    final doc = pw.Document(
      title: 'Payslip — ${_mf.format(payslip.periodStart)}',
      author: '4Directions Farm',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        header: (_) => _header(payslip, lang),
        footer: (_) => _footer(),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          _employeeSection(payslip, employee, lang),
          pw.SizedBox(height: 10),
          _earningsSection(payslip, lang),
          pw.SizedBox(height: 10),
          _deductionsSection(payslip, lang),
          pw.SizedBox(height: 10),
          _netPayBanner(payslip, lang),
          pw.SizedBox(height: 10),
          _uifNote(payslip),
          if (payslip.leaveBalanceSnapshot.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _leaveSection(payslip, lang),
          ],
          pw.SizedBox(height: 16),
          _statutoryNotice(),
        ],
      ),
    );

    return doc.save();
  }

  // ─── Page header (employer banner) ─────────────────────────────────────────
  static pw.Widget _header(Payslip payslip, String lang) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '4DIRECTIONS FARM',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Reg: 123/456  ·  UIF: U123456  ·  PAYE: 7890123456',
                style: pw.TextStyle(
                  color: const PdfColor(1, 1, 1, 0.7),
                  fontSize: 8,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: const PdfColor(1, 1, 1, 0.54)),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  _t(lang, 'PAYSLIP'),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _mf.format(payslip.periodStart),
                style: pw.TextStyle(
                  color: const PdfColor(1, 1, 1, 0.7),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Page footer ────────────────────────────────────────────────────────────
  static pw.Widget _footer() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Divider(color: _grey, height: 0.5),
    );
  }

  // ─── Employee info ──────────────────────────────────────────────────────────
  static pw.Widget _employeeSection(
    Payslip payslip,
    PayrollEmployee? employee,
    String lang,
  ) {
    return _sectionCard(
      title: _t(lang, 'EMPLOYEE'),
      titleColor: _navy,
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(1.2),
          1: const pw.FlexColumnWidth(2),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(2),
        },
        children: [
          _tableRow(
            _t(lang, 'Name'),
            employee != null
                ? '${employee.firstName} ${employee.lastName}'
                : payslip.employeeId,
            _t(lang, 'Period'),
            '${_dateFmt.format(payslip.periodStart)} – '
            '${_dateFmt.format(payslip.periodEnd)}',
          ),
          if (employee != null)
            _tableRow(
              _t(lang, 'ID / Passport'),
              employee.idOrPassportNumber,
              _t(lang, 'Pay Date'),
              _dateFmt.format(payslip.payDate),
            ),
          if (employee != null)
            _tableRow(
              _t(lang, 'Occupation'),
              employee.occupationTitle,
              _t(lang, 'Payslip #'),
              payslip.payslipNumber ?? '—',
            ),
          if (employee?.bankName != null)
            _tableRow(
              _t(lang, 'Bank'),
              '${employee!.bankName}  ****'
              '${employee.bankAccountNumber?.substring(employee.bankAccountNumber!.length > 4 ? employee.bankAccountNumber!.length - 4 : 0) ?? ''}',
              _t(lang, 'Branch Code'),
              employee.bankBranchCode ?? '—',
            ),
        ],
      ),
    );
  }

  // ─── Earnings ───────────────────────────────────────────────────────────────
  static pw.Widget _earningsSection(Payslip payslip, String lang) {
    final rows = <_LineItem>[
      _LineItem(_t(lang, 'Basic Wage'), payslip.basicWage),
      if (payslip.overtimePay > 0)
        _LineItem(_t(lang, 'Overtime Pay'), payslip.overtimePay),
      if (payslip.holidayPay > 0)
        _LineItem(_t(lang, 'Holiday Pay'), payslip.holidayPay),
      if (payslip.inKindHousing > 0)
        _LineItem(_t(lang, 'Housing (in-kind)'), payslip.inKindHousing),
      if (payslip.inKindFood > 0)
        _LineItem(_t(lang, 'Food (in-kind)'), payslip.inKindFood),
      if (payslip.otherEarnings > 0)
        _LineItem(_t(lang, 'Other Earnings'), payslip.otherEarnings),
    ];

    return _sectionCard(
      title: _t(lang, 'EARNINGS'),
      titleColor: _green,
      child: pw.Column(
        children: [
          ...rows.map((r) => _amountRow(r.label, r.amount)),
          _divider(),
          _amountRow(
            _t(lang, 'Gross Pay'),
            payslip.grossPay,
            bold: true,
            color: _navy,
          ),
        ],
      ),
    );
  }

  // ─── Deductions ─────────────────────────────────────────────────────────────
  static pw.Widget _deductionsSection(Payslip payslip, String lang) {
    return _sectionCard(
      title: _t(lang, 'DEDUCTIONS'),
      titleColor: _rose,
      child: pw.Column(
        children: [
          ...payslip.deductions.map(
            (d) => _amountRow(
              '${d.description}${d.isStatutory ? " (Statutory)" : ""}',
              d.amount,
              color: _rose,
            ),
          ),
          _divider(),
          _amountRow(
            'Total Deductions',
            payslip.totalDeductions,
            bold: true,
            color: _rose,
            prefix: '-',
          ),
        ],
      ),
    );
  }

  // ─── Net pay ────────────────────────────────────────────────────────────────
  static pw.Widget _netPayBanner(Payslip payslip, String lang) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            _t(lang, 'Net Pay').toUpperCase(),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.Text(
            _zarInt.format(payslip.netPay),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ─── UIF employer note ───────────────────────────────────────────────────────
  static pw.Widget _uifNote(Payslip payslip) {
    final uifEr = payslip.grossPay * 0.01;
    return _sectionCard(
      title: 'UIF EMPLOYER CONTRIBUTION',
      titleColor: _amber,
      child: pw.Text(
        'Employer contributes ${_zar.format(uifEr)} (1% of gross, remitted directly — '
        'not deducted from employee). Employee UIF: ${_zar.format(uifEr)}.',
        style: pw.TextStyle(fontSize: 8, color: _grey),
      ),
    );
  }

  // ─── Leave snapshot ─────────────────────────────────────────────────────────
  static pw.Widget _leaveSection(Payslip payslip, String lang) {
    return _sectionCard(
      title: _t(lang, 'LEAVE BALANCES'),
      titleColor: _teal,
      child: pw.Row(
        children: payslip.leaveBalanceSnapshot.entries
            .map(
              (e) => pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      '${e.key}: ',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: _teal,
                      ),
                    ),
                    pw.Text(
                      '${e.value.toStringAsFixed(1)} days',
                      style: pw.TextStyle(fontSize: 8, color: _grey),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ─── Statutory notice ────────────────────────────────────────────────────────
  static pw.Widget _statutoryNotice() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _grey, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        'This payslip is generated in accordance with the Basic Conditions of Employment '
        'Act (BCEA) and the Unemployment Insurance Act (UIA). UIF deductions are remitted '
        'to the Department of Labour. PAYE deductions are remitted to SARS. '
        'Retain this payslip for your records.',
        style: pw.TextStyle(fontSize: 7, color: _grey),
      ),
    );
  }

  // ─── Internal layout helpers ────────────────────────────────────────────────
  static pw.Widget _sectionCard({
    required String title,
    required PdfColor titleColor,
    required pw.Widget child,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            color: PdfColor.fromHex('F5F7FA'),
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
          pw.Divider(color: PdfColors.grey300, height: 0.5),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: child,
          ),
        ],
      ),
    );
  }

  static pw.TableRow _tableRow(String l1, String v1, String l2, String v2) {
    final labelStyle = pw.TextStyle(fontSize: 8, color: _grey);
    final valueStyle = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(l1, style: labelStyle),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(v1, style: valueStyle),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(l2, style: labelStyle),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(v2, style: valueStyle),
        ),
      ],
    );
  }

  static pw.Widget _amountRow(
    String label,
    double amount, {
    bool bold = false,
    PdfColor? color,
    String prefix = '',
  }) {
    final fg = color ?? PdfColors.black;
    final style = pw.TextStyle(
      fontSize: 9,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: fg,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text('$prefix${_zarInt.format(amount)}', style: style),
        ],
      ),
    );
  }

  static pw.Widget _divider() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Divider(color: PdfColors.grey300, height: 0.5),
  );
}

// ─── Value class ────────────────────────────────────────────────────────────
class _LineItem {
  const _LineItem(this.label, this.amount);
  final String label;
  final double amount;
}
