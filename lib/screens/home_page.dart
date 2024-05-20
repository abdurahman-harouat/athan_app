import 'package:athan_app/components/remaining.dart';
import 'package:athan_app/models/data_model.dart';
import 'package:athan_app/screens/loading.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Consumer<DataModel>(
          builder: (context, value, child) => SafeArea(
            child: LiquidPullToRefresh(
              height: 250,
              onRefresh: value.handleRefresh,
              child: ListView(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: FutureBuilder(
                        future: value.initializeData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Column(
                              children: [
                                // S P A C E R
                                // const SizedBox(
                                //   height: 40,
                                // ),
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
                                          color: value.currentIndex == 0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                        ),
                                        onPressed: value.currentIndex == 0
                                            ? null
                                            : () => value.decreaseIndex(),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              value
                                                  .hijriDateOfTheMonth[
                                                      value.currentIndex]
                                                  .day,
                                              style: GoogleFonts.qahiri(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall!)),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                              value
                                                  .hijriDateOfTheMonth[
                                                      value.currentIndex]
                                                  .arabicMonth,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                              value
                                                  .hijriDateOfTheMonth[
                                                      value.currentIndex]
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
                                          color: value.currentIndex ==
                                                  context
                                                          .read<DataModel>()
                                                          .hijriDateOfTheMonth
                                                          .length -
                                                      1
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                        ),
                                        onPressed: value.currentIndex ==
                                                value.hijriDateOfTheMonth
                                                        .length -
                                                    1
                                            ? null
                                            : () => value.increaseIndex(),
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
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary),
                                                ),
                                                // R E M A I N I N G -  T O -  A T H A N
                                                const RemainingWidget()
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
                                    items: value.prayerTimingsOfTheMonth
                                        .map((prayer) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
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
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                          size: 20,
                                                          Icons.location_pin),
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      Text(
                                                        value.locationName
                                                            .toString(),
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
                                                        nextPrayerName: value
                                                            .nextPrayerName,
                                                      ),
                                                      BoardItem(
                                                        prayerName: 'الظهر',
                                                        prayerTime:
                                                            prayer.dhuhr,
                                                        nextPrayerName: value
                                                            .nextPrayerName,
                                                      ),
                                                      BoardItem(
                                                        prayerName: 'العصر',
                                                        prayerTime: prayer.asr,
                                                        nextPrayerName: value
                                                            .nextPrayerName,
                                                      ),
                                                      BoardItem(
                                                        prayerName: 'المغرب',
                                                        prayerTime:
                                                            prayer.maghrib,
                                                        nextPrayerName: value
                                                            .nextPrayerName,
                                                      ),
                                                      BoardItem(
                                                        prayerName: 'العشاء',
                                                        prayerTime: prayer.isha,
                                                        nextPrayerName: value
                                                            .nextPrayerName,
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
                                      initialPage: value.currentIndex,
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
