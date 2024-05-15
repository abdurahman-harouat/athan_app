import 'dart:async';
import 'package:athan_app_v2/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyTimer extends StatefulWidget {
  const MyTimer({super.key});

  @override
  State<MyTimer> createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> {
  late Timer _timer;
  late DateTime _nextPrayerTime;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    final dataModel = context.read<DataModel>();
    _nextPrayerTime = dataModel.nextPrayerTime;
    _remaining = _nextPrayerTime.difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remaining -= const Duration(seconds: 1);
          if (_remaining <= Duration.zero) {
            dataModel.handleRefresh().then((_) {
              _startTimer(); // Start the timer for the next prayer
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the remaining time is 0 or less
    if (_remaining <= Duration.zero) {
      return Flexible(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 25.0,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.onTertiary,
                highlightColor: Theme.of(context).colorScheme.tertiaryContainer,
                child: Container(
                  height: 20.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Format the remaining time as a string
    String remainingStr =
        _remaining.toString().split('.').first.padLeft(8, '0');
    return Text(
      remainingStr,
      style: GoogleFonts.qahiri(
        textStyle: Theme.of(context).textTheme.displayLarge!,
      ),
    );
  }
}
