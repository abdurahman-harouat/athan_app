import 'dart:async';
import 'dart:convert';

import 'package:athan_app_v2/models/hijri_date_model.dart';
import 'package:athan_app_v2/models/timings_model.dart';
import 'package:athan_app_v2/screens/loading.dart';
import 'package:athan_app_v2/local_notification_service.dart';
import 'package:athan_app_v2/timer.dart';
import 'package:athan_app_v2/utils/current_time.dart';
import 'package:athan_app_v2/utils/formatCurrentDate.dart';
import 'package:athan_app_v2/utils/location.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';

import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future scheduledNotification() async {
    final bool? grantedNotificationPermission = await LocalNotificationService
        .androidImplementation
        ?.requestNotificationsPermission();

    if (grantedNotificationPermission != null) {
      LocalNotificationService.showSchduledNotification(
          _currentDate.year,
          _currentDate.month,
          _currentDate.day,
          (isFriday && nextPrayerName == "الظهر")
              ? jumuaaPrayerReminder.hour
              : prayerReminderTime.hour,
          (isFriday && nextPrayerName == "الظهر")
              ? jumuaaPrayerReminder.minute
              : prayerReminderTime.minute,
          nextPrayerName);
    }
  }

  final athan_box = Hive.box('athan_box');
  late DateTime nextPrayerTime;
  late String nextPrayerName;
  late DateTime prayerReminderTime; // i will use it later
  late DateTime jumuaaPrayerReminder; // i will use it later
  bool isFriday = false; // i will use it later

  final DateTime _currentDate = DateTime.now();

  String formattedCurrentDate =
      formatDateReverse(DateTime.now()); // needs an improvement
  String formattedTommorowDate =
      formatDateReverse(DateTime.now().add(const Duration(days: 1)));

  late Duration difference;

  List<TimingsModel> prayerTimingsOfTheMonth = [];
  List<HijriDateModel> hijriDateOfTheMonth = [];
  int currentIndex = DateTime.now().day - 1;

  late double latitude;
  late double longitude;
  late String? locationName;

  Future<void> getAthanTimes() async {
    var storage = athan_box.get('athan_data');
    if (storage == null || storage.isEmpty) {
      Position position = await UsersLocation.determineLocation();
      latitude = position.latitude;
      longitude = position.longitude;

      setLocaleIdentifier("ar_DZ");
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      locationName = placemarks[0].locality;

      // storing data in our device
      athan_box.put('athan_data', [latitude, longitude, locationName]);
    } else {
      latitude = storage[0];
      longitude = storage[1];
      locationName = storage[2];
    }

    var response = await http.get(Uri.https(
      'api.aladhan.com',
      '/v1/calendar/${_currentDate.year}/${_currentDate.month}',
      {'latitude': '$latitude', 'longitude': '$longitude'},
    ));

    if (response.statusCode == 200) {
      // Decode data
      var jsonData = jsonDecode(response.body);

      // Getting every single item in data
      for (var item in jsonData['data']) {
        // making a list of all prayers of the month
        var timings = item['timings'];
        prayerTimingsOfTheMonth.add(TimingsModel.fromJson(timings));

        // making a list of all hijri dates of the month
        var hijri = item['date']['hijri'];
        hijriDateOfTheMonth.add(HijriDateModel.fromJson(hijri));
      }

      DateTime fajrTime = DateTime.parse(
          "$formattedCurrentDate ${prayerTimingsOfTheMonth[currentIndex].fajr.toString().substring(0, 5)}:00");
      DateTime dhuhrTime = DateTime.parse(
          "$formattedCurrentDate ${prayerTimingsOfTheMonth[currentIndex].dhuhr.toString().substring(0, 5)}:00");
      DateTime asrTime = DateTime.parse(
          "$formattedCurrentDate ${prayerTimingsOfTheMonth[currentIndex].asr.toString().substring(0, 5)}:00");
      DateTime maghribTime = DateTime.parse(
          "$formattedCurrentDate ${prayerTimingsOfTheMonth[currentIndex].maghrib.toString().substring(0, 5)}:00");
      DateTime ishaTime = DateTime.parse(
          "$formattedCurrentDate ${prayerTimingsOfTheMonth[currentIndex].isha.toString().substring(0, 5)}:00");

      DateTime tomorrowFajrTime = DateTime.parse(
          "$formattedTommorowDate ${prayerTimingsOfTheMonth[currentIndex + 1].fajr.toString().substring(0, 5)}:00");

      isFriday = hijriDateOfTheMonth[currentIndex].arabicWeekDay == "الجمعة";

      if (currentTime.isBefore(fajrTime)) {
        nextPrayerName = 'الفجر';
        difference = fajrTime.difference(currentTime);
        prayerReminderTime = fajrTime.subtract(const Duration(minutes: 10));
        nextPrayerTime = fajrTime;
      } else if (currentTime.isAfter(fajrTime) &&
          currentTime.isBefore(dhuhrTime)) {
        nextPrayerName = 'الظهر';
        difference = dhuhrTime.difference(currentTime);
        prayerReminderTime = dhuhrTime.subtract(const Duration(minutes: 5));
        nextPrayerTime = dhuhrTime;
        if (isFriday) {
          jumuaaPrayerReminder =
              dhuhrTime.subtract(const Duration(minutes: 30));
        }
      } else if (currentTime.isAfter(dhuhrTime) &&
          currentTime.isBefore(asrTime)) {
        nextPrayerName = 'العصر';
        difference = asrTime.difference(currentTime);
        prayerReminderTime = asrTime.subtract(const Duration(minutes: 5));
        nextPrayerTime = asrTime;
      } else if (currentTime.isAfter(asrTime) &&
          currentTime.isBefore(maghribTime)) {
        nextPrayerName = 'المغرب';
        difference = maghribTime.difference(currentTime);
        prayerReminderTime = maghribTime.subtract(const Duration(minutes: 10));
        nextPrayerTime = maghribTime;
      } else if (currentTime.isAfter(maghribTime) &&
          currentTime.isBefore(ishaTime)) {
        nextPrayerName = 'العشاء';
        difference = ishaTime.difference(currentTime);
        prayerReminderTime = ishaTime.subtract(const Duration(minutes: 5));
        nextPrayerTime = ishaTime;
      } else if (currentTime.isAfter(ishaTime)) {
        nextPrayerName = 'الفجر';
        difference = tomorrowFajrTime.difference(currentTime);
        prayerReminderTime =
            tomorrowFajrTime.subtract(const Duration(minutes: 10));
        nextPrayerTime = tomorrowFajrTime;
      }
      scheduledNotification();
    }
    print("prayer reminder time $prayerReminderTime");
    throw Error();
  }

  Future _handleRefresh() async {
    currentIndex = DateTime.now().day - 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: LiquidPullToRefresh(
          height: 250,
          onRefresh: _handleRefresh,
          child: ListView(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: FutureBuilder(
                    future: getAthanTimes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Column(
                          children: [
                            // S P A C E R
                            const SizedBox(
                              height: 40,
                            ),
                            // C U R R E N T - H I J R I - D A T E
                            SizedBox(
                              height: 85,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_circle_right_rounded,
                                      color: currentIndex == 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .outline
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                    ),
                                    onPressed: currentIndex == 0
                                        ? null
                                        : () {
                                            currentIndex--;
                                            setState(() {});
                                          },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          hijriDateOfTheMonth[currentIndex].day,
                                          style: GoogleFonts.qahiri(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!)),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                          hijriDateOfTheMonth[currentIndex]
                                              .arabicMonth,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                          hijriDateOfTheMonth[currentIndex]
                                              .year,
                                          style: GoogleFonts.qahiri(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!))
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_circle_left_rounded,
                                      color: currentIndex ==
                                              hijriDateOfTheMonth.length - 1
                                          ? Theme.of(context)
                                              .colorScheme
                                              .outline
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                    ),
                                    onPressed: currentIndex ==
                                            hijriDateOfTheMonth.length - 1
                                        ? null
                                        : () {
                                            currentIndex++;
                                            setState(() {});
                                          },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            // R E M A I N I N G  - T I M E
                            Container(
                              height: 110,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              'يتبقى على الصلاة',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary),
                                            ),
                                            // R E M A I N I N G -  T O -  A T H A N
                                            MyTimer(difference: difference)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // S P A C E R
                            const SizedBox(
                              height: 40,
                            ),
                            // P R A Y E R - T I M E - B O A R D
                            CarouselSlider(
                                items: prayerTimingsOfTheMonth.map((prayer) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "مواقيت الصلاة",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                      size: 20,
                                                      Icons.location_pin),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Text(
                                                    locationName.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                children: [
                                                  BoardItem(
                                                    prayerName: 'الفجر',
                                                    prayerTime: prayer.fajr,
                                                    nextPrayerName:
                                                        nextPrayerName,
                                                  ),
                                                  BoardItem(
                                                    prayerName: 'الظهر',
                                                    prayerTime: prayer.dhuhr,
                                                    nextPrayerName:
                                                        nextPrayerName,
                                                  ),
                                                  BoardItem(
                                                    prayerName: 'العصر',
                                                    prayerTime: prayer.asr,
                                                    nextPrayerName:
                                                        nextPrayerName,
                                                  ),
                                                  BoardItem(
                                                    prayerName: 'المغرب',
                                                    prayerTime: prayer.maghrib,
                                                    nextPrayerName:
                                                        nextPrayerName,
                                                  ),
                                                  BoardItem(
                                                    prayerName: 'العشاء',
                                                    prayerTime: prayer.isha,
                                                    nextPrayerName:
                                                        nextPrayerName,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ));
                                    },
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                  height: 360,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 0.98,
                                  initialPage: currentIndex,
                                  enableInfiniteScroll: false,
                                  reverse: false,
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  enlargeFactor: 0.2,
                                  scrollDirection: Axis.horizontal,
                                ))
                          ],
                        );
                      } else {
                        return const Center(child: LoadingHomePage());
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class BoardItem extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String nextPrayerName;

  const BoardItem(
      {super.key,
      required this.prayerTime,
      required this.prayerName,
      required this.nextPrayerName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            getIcon(prayerName),
            const SizedBox(
              width: 10,
            ),
            Text(
              prayerName,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: prayerName == nextPrayerName
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: prayerName == nextPrayerName
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.inverseSurface),
            ),
          ],
        ),
        Text(
          prayerTime.substring(0, 5),
          style: GoogleFonts.qahiri(
            textStyle: TextStyle(
                fontSize: 30,
                color: prayerName == nextPrayerName
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.inverseSurface),
          ),
        )
      ],
    );
  }
}

Icon getIcon(prayerName) {
  if (prayerName == 'الفجر') {
    return const Icon(
      CupertinoIcons.moon_stars,
    );
  } else if (prayerName == 'الظهر') {
    return const Icon(CupertinoIcons.sun_max_fill);
  } else if (prayerName == 'العصر') {
    return const Icon(CupertinoIcons.sun_min);
  } else if (prayerName == 'المغرب') {
    return const Icon(Icons.sunny_snowing);
  } else if (prayerName == 'العشاء') {
    return const Icon(CupertinoIcons.moon);
  } else {
    return const Icon(Icons.error);
  }
}
