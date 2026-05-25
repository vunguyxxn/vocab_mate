class StreakUtils {
  /// Tính streak từ danh sách activity_date (đã sort giảm dần)
  static int calculateStreak(List<DateTime> activityDates) {
    if (activityDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Sort giảm dần
    final sorted = activityDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Ngày gần nhất phải là hôm nay hoặc hôm qua
    final latest = sorted.first;
    final diff = todayDate.difference(latest).inDays;
    if (diff > 1) return 0; // Streak bị gián đoạn

    int streak = 1;
    for (int i = 0; i < sorted.length - 1; i++) {
      final gap = sorted[i].difference(sorted[i + 1]).inDays;
      if (gap == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}