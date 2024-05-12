import 'dart:async';
import 'dart:convert';

import 'package:athan_app_v2/loading/home_page_loading.dart';
import 'package:athan_app_v2/local_notification_service.dart';
import 'package:athan_app_v2/timer.dart';
import 'package:athan_app_v2/utils/chooseIcon.dart';
import 'package:athan_app_v2/utils/formatCurrentDate.dart';
import 'package:athan_app_v2/utils/formatCurrentPrayer.dart';
import 'package:athan_app_v2/utils/location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double latitude;
  late double longitude;

  Future _handleRefresh() async {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  Future scheduledNotification() async {
    final bool? grantedNotificationPermission = await LocalNotificationService
        .androidImplementation
        ?.requestNotificationsPermission();

    if (grantedNotificationPermission != null) {
      if (nextPrayerTime.isAfter(prayerReminder) &&
          nextPrayerTime.isAfter(thirtyMinuteReminder)) {
        LocalNotificationService.showSchduledNotification(
            _currentDate.year,
            _currentDate.month,
            _currentDate.day,
            (isFriday && nextPrayerName == "Dhuhr")
                ? thirtyMinuteReminder.hour
                : prayerReminder.hour,
            (isFriday && nextPrayerName == "Dhuhr")
                ? thirtyMinuteReminder.minute
                : prayerReminder.minute,
            formatPrayerName(nextPrayerName));
      }
    }
  }

  late Duration nextPrayerDuration = const Duration(days: 1);
  String nextPrayerName = "";
  late DateTime nextPrayerTime;
  late DateTime prayerReminder;
  DateTime thirtyMinuteReminder = DateTime.now();
  bool isFriday = false;

  DateTime _currentDate = DateTime.now();
  // this will be parsed in a DateTime
  String formattedCurrentDate = formatDateReverse(DateTime.now());
  String formattedTommorowDate =
      formatDateReverse(DateTime.now().add(const Duration(days: 1)));

  late Duration difference;
  String currentHijriYear = "";
  String currentHijriDay = "";
  String currentHijriMonth = "";

  Set<String> desiredTimingNames = {'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'};
  Map<String, dynamic> todaysTimings = {};
  late dynamic tomorrowFajr;
  late DateTime tommorowsFajr;

  List passedPrayer = [];

  Future<void> getAthanTimes() async {
    Position position = await UsersLocation.determineLocation();
    latitude = position.latitude;
    longitude = position.longitude;

    try {
      var response = await http.get(Uri.https(
        'api.aladhan.com',
        '/v1/calendar/${_currentDate.year}/${_currentDate.month}',
        {'latitude': '$latitude', 'longitude': '$longitude'},
      ));

      if (response.statusCode == 200) {
        // Decode data
        var jsonData = jsonDecode(response.body);

        // if response is 200
        if (jsonData['code'] == 200 && jsonData['data'] != null) {
          // Getting every single item in data
          for (var item in jsonData['data']) {
            // Getting Todays date
            if (item['date']['gregorian']['date'] == formatDate(_currentDate)) {
              // Getting todays timings
              todaysTimings = item['timings'];

              isFriday = item['date']['hijri']['weekday']['ar'] == "الجمعة";
              //setting current hijri year
              currentHijriYear = item['date']['hijri']['year'];
              currentHijriDay = item['date']['hijri']['day'];
              currentHijriMonth = item['date']['hijri']['month']['ar'];
            }

            // Getting Tomorrows Date
            if (item['date']['gregorian']['date'] ==
                formatDate(_currentDate.add(const Duration(days: 1)))) {
              // Get tommorows fajr
              tomorrowFajr = item['timings']["Fajr"];
              break; // Exit the loop after finding the date
            }
          }

          // finding next prayer duration and name
          todaysTimings.forEach((key, value) {
            if (desiredTimingNames.contains(key)) {
              // Step 1 : Get current time and prayers time
              // get todays prayer time
              DateTime prayerTime = DateTime.parse(
                  "$formattedCurrentDate ${value.toString().substring(0, 5)}:00");

              // get current time
              String currentHour = _currentDate.hour.toString().padLeft(2, '0');
              String currentMinute =
                  _currentDate.minute.toString().padLeft(2, '0');
              String currentTimeString =
                  "$formattedCurrentDate $currentHour:$currentMinute:00";

              DateTime currentTime = DateTime.parse(currentTimeString);

              // Step 2 : checking is we are after or before isha
              // if passedPrayer >= 5 , we are after isha
              if (currentTime.isAfter(prayerTime)) {
                passedPrayer.add(key);
              }

              if (passedPrayer.length < 5) {
                // Step 3: Calculate the difference
                difference = prayerTime.difference(currentTime);

                if (!difference.isNegative) {
                  if ((difference < nextPrayerDuration)) {
                    nextPrayerDuration = difference;
                    nextPrayerName = key;
                    nextPrayerTime = prayerTime;

                    // this reminder is for Jumuaa
                    thirtyMinuteReminder =
                        nextPrayerTime.subtract(const Duration(minutes: 30));
                    scheduledNotification();
                    if (nextPrayerName == "Fajr" ||
                        nextPrayerName == "Maghrib") {
                      prayerReminder =
                          nextPrayerTime.subtract(const Duration(minutes: 10));
                      // TODO : making custom reminder for every prayer
                    } else {
                      prayerReminder =
                          nextPrayerTime.subtract(const Duration(minutes: 5));
                    }
                  }
                }
              } else {
                // Get tomorrow Fajr DateTime
                tommorowsFajr = DateTime.parse(
                    "$formattedTommorowDate ${tomorrowFajr?.toString().substring(0, 5)}:00");

                nextPrayerDuration = tommorowsFajr.difference(currentTime);
                nextPrayerName = "Fajr";
              }
            }
          });
        } else {
          // Handle API errors (e.g., print error message)
          print('Error: ${jsonData['status']}');
        }
      } else {
        // Handle API errors (e.g., print error message)
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors
      print('Network Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime firstDayOfNextMonth =
        DateTime(_currentDate.year, _currentDate.month + 1, 1);
    DateTime lastDayOfThisMonth =
        firstDayOfNextMonth.subtract(const Duration(days: 1));
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
                                      color: _currentDate.day == 1
                                          ? Theme.of(context)
                                              .colorScheme
                                              .outline
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                    ),
                                    onPressed: _currentDate.day == 1
                                        ? null
                                        : () {
                                            setState(() {
                                              _currentDate =
                                                  _currentDate.subtract(
                                                      const Duration(days: 1));
                                            });
                                          },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(currentHijriDay.toString(),
                                          style: GoogleFonts.qahiri(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!)),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(currentHijriMonth.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(currentHijriYear.toString(),
                                          style: GoogleFonts.qahiri(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!))
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_circle_left_rounded,
                                      color: _currentDate.day ==
                                              lastDayOfThisMonth.day
                                          ? Theme.of(context)
                                              .colorScheme
                                              .outline
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                    ),
                                    onPressed: _currentDate.day ==
                                            lastDayOfThisMonth.day
                                        ? null
                                        : () {
                                            setState(() {
                                              _currentDate = _currentDate
                                                  .add(const Duration(days: 1));
                                            });
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
                                            // Text(
                                            //   "$difference",
                                            //   style: GoogleFonts.qahiri(
                                            //       textStyle: Theme.of(context)
                                            //           .textTheme
                                            //           .displaySmall!),
                                            // )
                                            MyTimer(
                                                difference: nextPrayerDuration)
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
                            Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "مواقيت الصلاة",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children:
                                          todaysTimings.entries.map((entry) {
                                        final timingName = entry.key;
                                        final timingValue = entry.value;

                                        if (desiredTimingNames
                                            .contains(timingName)) {
                                          return Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // P R A Y E R - I C O N
                                                      getIcon(timingName),

                                                      // S P A C E
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      // P R A Y E R -  N A M E
                                                      nextPrayerName ==
                                                              timingName
                                                          ? Text(
                                                              formatPrayerName(
                                                                  timingName),
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary),
                                                            )
                                                          : Text(
                                                              formatPrayerName(
                                                                  timingName),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          20),
                                                            ),
                                                    ],
                                                  ),
                                                  // P R A Y E R - T I M E
                                                  nextPrayerName == timingName
                                                      ? Text(
                                                          timingValue
                                                              .toString()
                                                              .substring(0, 5),
                                                          style: GoogleFonts
                                                              .qahiri(
                                                                  textStyle:
                                                                      TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            fontSize: 30,
                                                          )),
                                                        )
                                                      : Text(
                                                          timingValue
                                                              .toString()
                                                              .substring(0, 5),
                                                          style: GoogleFonts
                                                              .qahiri(
                                                                  textStyle:
                                                                      const TextStyle(
                                                            fontSize: 30,
                                                          )),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                        return const SizedBox
                                            .shrink(); // or return an empty container
                                      }).toList(),
                                    )
                                  ],
                                )),
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
