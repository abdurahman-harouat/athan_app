import 'package:intl/intl.dart';

String formatDateReverse(DateTime dateTime) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(dateTime);
}
