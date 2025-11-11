extension DateTimeExtension on DateTime {
  String get hhmm {
    return "$hour:$minute";
  }
}
