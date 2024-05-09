import 'package:flutter/material.dart';

class CheckingPermissionPage extends StatefulWidget {
  const CheckingPermissionPage({super.key});

  @override
  State<CheckingPermissionPage> createState() => _CheckingPermissionPageState();
}

class _CheckingPermissionPageState extends State<CheckingPermissionPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'تفعيل الأذونات',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        Text(
                          'يرجى تفعيلها جميعا حتى يعمل التطبيق بدون مشاكل',
                          style: Theme.of(context).textTheme.bodyLarge!,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                    value: false, onChanged: (value) {})),
                            Text(
                              "تفعيل تقنية تحديد الموقع",
                              style: Theme.of(context).textTheme.titleLarge!,
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                    value: false, onChanged: (value) {})),
                            Text(
                              "تفعيل الإشعارات ",
                              style: Theme.of(context).textTheme.titleLarge!,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
