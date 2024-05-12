class PrayerTimesResponse {
  final int code;
  final String status;
  final List<PrayerData> data;

  PrayerTimesResponse(
      {required this.code, required this.status, required this.data});

  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<PrayerData> dataList =
        list.map((i) => PrayerData.fromJson(i)).toList();
    return PrayerTimesResponse(
      code: json['code'],
      status: json['status'],
      data: dataList,
    );
  }
}

class PrayerData {
  final Timings timings;

  PrayerData({required this.timings});

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      timings: Timings.fromJson(json['timings']),
    );
  }
}

class Timings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final String firstThird;
  final String lastThird;

  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.firstThird,
    required this.lastThird,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      fajr: json['Fajr'],
      sunrise: json['Sunrise'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      sunset: json['Sunset'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
      imsak: json['Imsak'],
      midnight: json['Midnight'],
      firstThird: json['Firstthird'],
      lastThird: json['Lastthird'],
    );
  }
}
