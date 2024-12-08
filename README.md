# Athan app

## introduction

Athan app that displays prayer times for the current month and the next month according to your geographical location based on GPS, in addition to a notification you will get before athan at a specific time.

[API](https://aladhan.com/prayer-times-api)

## Features

- [x] notification before athan
- [x] no internet connection screen
- [x] prayer time for the entire month
- [x] hijri date "dd-mm-yyyy"
- [x] loading skeleton "shimmer effect"
- [x] material 3 design
- [x] remaining time before athan
- [x] location saved on device

### notification

- 10 minutes before fajr
- 5 minutes before dhuhr
- 5 minutes before asr
- 10 minutes before maghrib
- 5 minutes before isha

## Future improvement [TODO]

- [ ] custom notification time
- [ ] proper permission handling
- [ ] ios support "notification"
- [ ] custom location "map based"
- [ ] switch between dark / light theme
- [ ] adding multi-languge support
- [ ] adding tasks to work manager

## App images

<div><img src="https://raw.githubusercontent.com/abdurahman-harouat/athan_app/main/showcase/light.png" height=400px>
<img src="https://raw.githubusercontent.com/abdurahman-harouat/athan_app/main/showcase/dark.png" height=400px>
</div>

> development started 28 Apr 2024

## my environment

```bash
java -version
# openjdk version "23.0.1" 2024-10-15
# OpenJDK Runtime Environment Homebrew (build 23.0.1)
# OpenJDK 64-Bit Server VM Homebrew (build 23.0.1, mixed mode, sharing)
```

**build the app for android**

```bash
flutter build apk --split-per-abi
```
