class MonthTranslations {
  static const Map<String, String> hijriMonths = {
    'Muḥarram': 'محرم',
    'Ṣafar': 'صفر',
    'Rabīʿ al-awwal': 'ربيع الأول',
    'Rabīʿ al-thānī': 'ربيع الثاني',
    'Jumādá al-ūlá': 'جمادى الأولى',
    'Jumādá al-ākhirah': 'جمادى الثانية',
    'Rajab': 'رجب',
    'Shaʿbān': 'شعبان',
    'Ramaḍān': 'رمضان',
    'Shawwāl': 'شوال',
    'Dhū al-Qaʿdah': 'ذو القعدة',
    'Dhū al-Ḥijjah': 'ذو الحجة',
  };

  static const Map<String, String> gregorianMonths = {
    'January': 'يناير',
    'February': 'فبراير',
    'March': 'مارس',
    'April': 'أبريل',
    'May': 'مايو',
    'June': 'يونيو',
    'July': 'يوليو',
    'August': 'أغسطس',
    'September': 'سبتمبر',
    'October': 'أكتوبر',
    'November': 'نوفمبر',
    'December': 'ديسمبر',
  };

  static const Map<String, String> arabicNumerals = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  static String getHijriMonth(String englishMonth) {
    return hijriMonths[englishMonth] ?? englishMonth;
  }

  static String getGregorianMonth(String englishMonth) {
    return gregorianMonths[englishMonth] ?? englishMonth;
  }

  /// Converts English numerals to Arabic-Indic numerals
  static String toArabicNumerals(String number) {
    String result = number;
    arabicNumerals.forEach((english, arabic) {
      result = result.replaceAll(english, arabic);
    });
    return result;
  }
}
