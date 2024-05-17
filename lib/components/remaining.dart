import 'package:athan_app_v2/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RemainingWidget extends StatefulWidget {
  const RemainingWidget({super.key});

  @override
  State<RemainingWidget> createState() => _RemainingWidgetState();
}

class _RemainingWidgetState extends State<RemainingWidget> {
  bool hasCalledNextPrayerTime = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DataModel>(
      builder: (context, value, child) {
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            var remaining = value.nextPrayerTime.difference(DateTime.now());

            if (remaining <= Duration.zero && !hasCalledNextPrayerTime) {
              hasCalledNextPrayerTime = true;
              Future.delayed(Duration.zero, () async {
                if (mounted) {
                  value.updateCurrentTime();
                  value.calculateNextPrayerTime();
                }
              });
            } else if (remaining > Duration.zero) {
              hasCalledNextPrayerTime = false;
            }

            String remainingStr = remaining.isNegative
                ? "00:00:00"
                : remaining.toString().split('.').first.padLeft(8, '0');

            return Text(
              remainingStr,
              style: GoogleFonts.qahiri(
                textStyle: Theme.of(context).textTheme.displayLarge!,
              ),
            );
          },
        );
      },
    );
  }
}
