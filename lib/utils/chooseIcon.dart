import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

getIcon(prayerName) {
  if (prayerName == 'Fajr') {
    return const Icon(
      CupertinoIcons.moon_stars,
    );
  } else if (prayerName == 'Dhuhr') {
    return const Icon(CupertinoIcons.sun_max_fill);
  } else if (prayerName == 'Asr') {
    return const Icon(CupertinoIcons.sun_min);
  } else if (prayerName == 'Maghrib') {
    return const Icon(Icons.sunny_snowing);
  } else if (prayerName == 'Isha') {
    return const Icon(CupertinoIcons.moon);
  } else {
    return const Icon(Icons.error);
  }
}
