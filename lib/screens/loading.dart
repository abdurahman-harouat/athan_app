import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingHomePage extends StatelessWidget {
  const LoadingHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // S P A C E R
        const SizedBox(
          height: 40,
        ),
        // C U R R E N T - H I J R I - D A T E - S K E L E T O N
        SizedBox(
          height: 85,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 85.0,
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surface,
                    highlightColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    child: Container(
                      height: 100.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Theme.of(context).colorScheme.surface),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        // R E M A I N I N G  - T I M E
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 110.0,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.tertiaryContainer,
                  highlightColor: Theme.of(context).colorScheme.onTertiary,
                  child: Container(
                    height: 100.0,
                    width: 30.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).colorScheme.surface),
                  ),
                ),
              ),
            ),
          ],
        ),
        // S P A C E R
        const SizedBox(
          height: 40,
        ),
        // P R A Y E R - T I M E - B O A R D
        Column(
          children: [
            Text(
              "مواقيت الصلاة",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.right,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 2; i++)
                  Column(children: [
                    for (var i = 0; i < 5; i++)
                      Column(
                        children: [
                          SizedBox(
                            width: 85.0,
                            height: 29.0,
                            child: Shimmer.fromColors(
                              baseColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              highlightColor:
                                  Theme.of(context).colorScheme.surface,
                              child: Container(
                                height: 100.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color:
                                        Theme.of(context).colorScheme.surface),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          )
                        ],
                      )
                  ])
              ],
            )
          ],
        )
      ],
    );
  }
}
