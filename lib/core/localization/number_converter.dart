


class NumberConverter {
  // Mapping of English numbers to other scripts
  static const Map<String, String> _engToBn = {
    '1': '১', '2': '২', '3': '৩', '4': '৪', '5': '৫',
    '6': '৬', '7': '৭', '8': '৮', '9': '৯', '0': '০',
  };

  static const Map<String, String> _engToHi = {
    '1': '१', '2': '२', '3': '३', '4': '४', '5': '५',
    '6': '६', '7': '७', '8': '८', '9': '९', '0': '०',
  };

  // Reverse mapping for Bangla to English
  static final Map<String, String> _bnToEng = 
      _engToBn.map((key, value) => MapEntry(value, key));

  /// 1. Helper: Bangla to English
  static String banglaToEnglish(String text) {
    return text.replaceAllMapped(
      RegExp(r'[০-৯]'),
      (match) => _bnToEng[match.group(0)] ?? match.group(0)!,
    );
  }

  /// 2. Helper: English to Bangla
  static String englishToBangla(String text) {
    return text.replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _engToBn[match.group(0)] ?? match.group(0)!,
    );
  }

  /// 3. Helper: English to Hindi
  static String englishToHindi(String text) {
    return text.replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _engToHi[match.group(0)] ?? match.group(0)!,
    );
  }
}