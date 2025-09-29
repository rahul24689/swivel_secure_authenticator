/// Date utility functions
/// Converted from DateUtils.java
class DateUtils {
  /// Get current seconds
  static int getSeconds() {
    final now = DateTime.now();
    return now.second;
  }

  /// Get thirty seconds calculation for OATH tokens
  static int getThirtySeconds() {
    int seconds = getSeconds();
    
    if (seconds > 30) {
      seconds = 30 - (60 - seconds);
    }
    
    return seconds;
  }

  /// Get current year
  static int getCurrentYear() {
    final now = DateTime.now();
    return now.year;
  }

  /// Get current timestamp in milliseconds
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Get current timestamp in seconds
  static int getCurrentTimestampSeconds() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Format date to string
  static String formatDate(DateTime date, [String pattern = 'yyyy-MM-dd HH:mm:ss']) {
    // Simple formatting - in production, use intl package
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}:'
           '${date.second.toString().padLeft(2, '0')}';
  }

  /// Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Get time remaining until next 30-second interval (for OATH)
  static int getTimeUntilNext30Seconds() {
    final seconds = getSeconds();
    if (seconds <= 30) {
      return 30 - seconds;
    } else {
      return 60 - seconds;
    }
  }
}
