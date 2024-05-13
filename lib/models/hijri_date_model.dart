class HijriDateModel {
  final String day, arabicWeekDay, arabicMonth, year;

  HijriDateModel.fromJson(Map<String, dynamic> json)
      : day = json['day'],
        arabicWeekDay = json['weekday']['ar'],
        arabicMonth = json['month']['ar'],
        year = json['year'];
}
