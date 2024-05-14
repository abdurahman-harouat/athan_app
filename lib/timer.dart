import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTimer extends StatefulWidget {
  final Duration difference;

  const MyTimer({super.key, required this.difference});

  @override
  State<MyTimer> createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> {
  late DateTime endTime;

  @override
  void initState() {
    super.initState();
    endTime = DateTime.now().add(widget.difference);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        // Calculate the remaining time based on current time and end time
        Duration remaining = endTime.difference(DateTime.now());

        // Check if the remaining time is 0
        if (remaining <= Duration.zero) {
          // Delay the update of endTime by one second
          Future.delayed(const Duration(seconds: 0), () {
            if (mounted) {
              // Check if the widget is still in the tree
              setState(() {
                // Update endTime to the next prayer time
                // You'll need to replace getNextPrayerTime() with your own function
                endTime = DateTime.now().add(widget.difference);
                remaining = endTime.difference(DateTime.now());
              });
            }
          });
        }

        // Format the remaining time as a string
        String remainingStr =
            remaining.toString().split('.').first.padLeft(8, '0');
        return Text(
          remainingStr,
          style: GoogleFonts.qahiri(
            textStyle: Theme.of(context).textTheme.displayLarge!,
          ),
        );
      },
    );
  }
}
