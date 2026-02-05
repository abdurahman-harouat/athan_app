class PrayerNotificationSettings {
  final bool enabled;
  final int prePrayerReminderMinutes;
  final int departureReminderMinutes;

  PrayerNotificationSettings({
    this.enabled = true,
    this.prePrayerReminderMinutes = 10,
    this.departureReminderMinutes = 5,
  });

  PrayerNotificationSettings copyWith({
    bool? enabled,
    int? prePrayerReminderMinutes,
    int? departureReminderMinutes,
  }) {
    return PrayerNotificationSettings(
      enabled: enabled ?? this.enabled,
      prePrayerReminderMinutes:
          prePrayerReminderMinutes ?? this.prePrayerReminderMinutes,
      departureReminderMinutes:
          departureReminderMinutes ?? this.departureReminderMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'prePrayerReminderMinutes': prePrayerReminderMinutes,
      'departureReminderMinutes': departureReminderMinutes,
    };
  }

  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationSettings(
      enabled: json['enabled'] ?? true,
      prePrayerReminderMinutes: json['prePrayerReminderMinutes'] ?? 10,
      departureReminderMinutes: json['departureReminderMinutes'] ?? 5,
    );
  }
}

class TravelTimeSettings {
  final int fajrTravelMinutes;
  final int dhuhrTravelMinutes;
  final int asrTravelMinutes;
  final int maghribTravelMinutes;
  final int ishaTravelMinutes;

  TravelTimeSettings({
    this.fajrTravelMinutes = 10,
    this.dhuhrTravelMinutes = 10,
    this.asrTravelMinutes = 10,
    this.maghribTravelMinutes = 10,
    this.ishaTravelMinutes = 10,
  });

  int getTravelTimeForPrayer(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return fajrTravelMinutes;
      case 'Dhuhr':
        return dhuhrTravelMinutes;
      case 'Asr':
        return asrTravelMinutes;
      case 'Maghrib':
        return maghribTravelMinutes;
      case 'Isha':
        return ishaTravelMinutes;
      default:
        return 10;
    }
  }

  TravelTimeSettings copyWith({
    int? fajrTravelMinutes,
    int? dhuhrTravelMinutes,
    int? asrTravelMinutes,
    int? maghribTravelMinutes,
    int? ishaTravelMinutes,
  }) {
    return TravelTimeSettings(
      fajrTravelMinutes: fajrTravelMinutes ?? this.fajrTravelMinutes,
      dhuhrTravelMinutes: dhuhrTravelMinutes ?? this.dhuhrTravelMinutes,
      asrTravelMinutes: asrTravelMinutes ?? this.asrTravelMinutes,
      maghribTravelMinutes: maghribTravelMinutes ?? this.maghribTravelMinutes,
      ishaTravelMinutes: ishaTravelMinutes ?? this.ishaTravelMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajrTravelMinutes': fajrTravelMinutes,
      'dhuhrTravelMinutes': dhuhrTravelMinutes,
      'asrTravelMinutes': asrTravelMinutes,
      'maghribTravelMinutes': maghribTravelMinutes,
      'ishaTravelMinutes': ishaTravelMinutes,
    };
  }

  factory TravelTimeSettings.fromJson(Map<String, dynamic> json) {
    return TravelTimeSettings(
      fajrTravelMinutes: json['fajrTravelMinutes'] ?? 10,
      dhuhrTravelMinutes: json['dhuhrTravelMinutes'] ?? 10,
      asrTravelMinutes: json['asrTravelMinutes'] ?? 10,
      maghribTravelMinutes: json['maghribTravelMinutes'] ?? 10,
      ishaTravelMinutes: json['ishaTravelMinutes'] ?? 10,
    );
  }
}

class AppSettings {
  final PrayerNotificationSettings fajrSettings;
  final PrayerNotificationSettings dhuhrSettings;
  final PrayerNotificationSettings asrSettings;
  final PrayerNotificationSettings maghribSettings;
  final PrayerNotificationSettings ishaSettings;
  final TravelTimeSettings travelTimeSettings;
  final bool darkMode;

  AppSettings({
    PrayerNotificationSettings? fajrSettings,
    PrayerNotificationSettings? dhuhrSettings,
    PrayerNotificationSettings? asrSettings,
    PrayerNotificationSettings? maghribSettings,
    PrayerNotificationSettings? ishaSettings,
    TravelTimeSettings? travelTimeSettings,
    this.darkMode = false,
  })  : fajrSettings = fajrSettings ?? PrayerNotificationSettings(),
        dhuhrSettings = dhuhrSettings ?? PrayerNotificationSettings(),
        asrSettings = asrSettings ?? PrayerNotificationSettings(),
        maghribSettings = maghribSettings ?? PrayerNotificationSettings(),
        ishaSettings = ishaSettings ?? PrayerNotificationSettings(),
        travelTimeSettings = travelTimeSettings ?? TravelTimeSettings();

  PrayerNotificationSettings getSettingsForPrayer(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return fajrSettings;
      case 'Dhuhr':
        return dhuhrSettings;
      case 'Asr':
        return asrSettings;
      case 'Maghrib':
        return maghribSettings;
      case 'Isha':
        return ishaSettings;
      default:
        return PrayerNotificationSettings();
    }
  }

  AppSettings copyWith({
    PrayerNotificationSettings? fajrSettings,
    PrayerNotificationSettings? dhuhrSettings,
    PrayerNotificationSettings? asrSettings,
    PrayerNotificationSettings? maghribSettings,
    PrayerNotificationSettings? ishaSettings,
    TravelTimeSettings? travelTimeSettings,
    bool? darkMode,
  }) {
    return AppSettings(
      fajrSettings: fajrSettings ?? this.fajrSettings,
      dhuhrSettings: dhuhrSettings ?? this.dhuhrSettings,
      asrSettings: asrSettings ?? this.asrSettings,
      maghribSettings: maghribSettings ?? this.maghribSettings,
      ishaSettings: ishaSettings ?? this.ishaSettings,
      travelTimeSettings: travelTimeSettings ?? this.travelTimeSettings,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajrSettings': fajrSettings.toJson(),
      'dhuhrSettings': dhuhrSettings.toJson(),
      'asrSettings': asrSettings.toJson(),
      'maghribSettings': maghribSettings.toJson(),
      'ishaSettings': ishaSettings.toJson(),
      'travelTimeSettings': travelTimeSettings.toJson(),
      'darkMode': darkMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      fajrSettings: json['fajrSettings'] != null
          ? PrayerNotificationSettings.fromJson(json['fajrSettings'])
          : null,
      dhuhrSettings: json['dhuhrSettings'] != null
          ? PrayerNotificationSettings.fromJson(json['dhuhrSettings'])
          : null,
      asrSettings: json['asrSettings'] != null
          ? PrayerNotificationSettings.fromJson(json['asrSettings'])
          : null,
      maghribSettings: json['maghribSettings'] != null
          ? PrayerNotificationSettings.fromJson(json['maghribSettings'])
          : null,
      ishaSettings: json['ishaSettings'] != null
          ? PrayerNotificationSettings.fromJson(json['ishaSettings'])
          : null,
      travelTimeSettings: json['travelTimeSettings'] != null
          ? TravelTimeSettings.fromJson(json['travelTimeSettings'])
          : null,
      darkMode: json['darkMode'] ?? false,
    );
  }
}
