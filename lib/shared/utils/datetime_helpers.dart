class DateTimeHelpers {
  DateTimeHelpers._();

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Formats a date into user-friendly school logs (e.g. May 20, 2026)
  static String formatSchoolDate(DateTime date) {
    if (date.month < 1 || date.month > 12) return 'Unknown Date';
    final month = _months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  // Formats time for class scheduling (e.g. 08:30 AM)
  static String formatClassTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayHourStr = displayHour.toString().padLeft(2, '0');
    return '$displayHourStr:$minute $period';
  }

  // Checks if a student log was taken today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
