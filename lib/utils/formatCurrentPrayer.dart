// 'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'
String formatPrayerName(String prayer) {
  if (prayer == 'Fajr') {
    return 'الفجر';
  } else if (prayer == 'Dhuhr') {
    return 'الظهر';
  } else if (prayer == 'Asr') {
    return 'العصر';
  } else if (prayer == 'Maghrib') {
    return 'المغرب';
  } else if (prayer == 'Isha') {
    return 'العشاء';
  } else {
    return 'خطأ';
  }
}
