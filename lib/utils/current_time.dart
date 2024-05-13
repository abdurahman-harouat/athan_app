import 'package:intl/intl.dart';

// Assuming _currentDate is a DateTime object
DateTime _currentDate = DateTime.now();

// Use DateFormat to format the current DateTime object directly
String currentTimeString =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(_currentDate);

// Parse the formatted string back into a DateTime if needed
DateTime currentTime = DateTime.parse(currentTimeString);
