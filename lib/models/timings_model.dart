class TimingsModel {
  final String fajr, dhuhr, asr, maghrib, isha;

  TimingsModel.fromJson(Map<String, dynamic> json)
      : fajr = json['Fajr'],
        dhuhr = json['Dhuhr'],
        asr = json['Asr'],
        maghrib = json['Maghrib'],
        isha = json['Isha'];
}
