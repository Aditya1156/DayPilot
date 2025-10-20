import 'package:intl/intl.dart';

/// Very small recurrence expansion helper.
/// Supports rules like: FREQ=DAILY;INTERVAL=1 or FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE
class RecurrenceService {
  /// Parse a simple RRULE-style string into a map.
  static Map<String, String> parseRule(String? rrule) {
    if (rrule == null || rrule.trim().isEmpty) return {};
    final Map<String, String> out = {};
    final parts = rrule.split(';');
    for (final p in parts) {
      final idx = p.indexOf('=');
      if (idx > 0) {
        final k = p.substring(0, idx).trim().toUpperCase();
        final v = p.substring(idx + 1).trim();
        out[k] = v;
      }
    }
    return out;
  }

  /// Expand the next [count] occurrences starting after [from]. [start] is the original start time.
  /// Returns list of DateTime for the start times of future occurrences.
  static List<DateTime> expandNext({
    required String? rrule,
    required DateTime start,
    required DateTime from,
    int count = 10,
  }) {
    final rule = parseRule(rrule);
    if (rule.isEmpty) return [];

    final freq = rule['FREQ'] ?? 'DAILY';
    final interval = int.tryParse(rule['INTERVAL'] ?? '1') ?? 1;
    final List<DateTime> results = [];

    DateTime current = start.isAfter(from) ? start : from;
    // Normalize current to the same time-of-day as start
    current = DateTime(current.year, current.month, current.day, start.hour, start.minute);

    while (results.length < count) {
      if (current.isAfter(from) || current.isAtSameMomentAs(from)) {
        // For weekly with BYDAY support
        if (freq == 'WEEKLY' && rule.containsKey('BYDAY')) {
          final days = rule['BYDAY']!.split(',').map((s) => s.trim().toUpperCase()).toList();
          final weekdayMap = {
            'MO': DateTime.monday,
            'TU': DateTime.tuesday,
            'WE': DateTime.wednesday,
            'TH': DateTime.thursday,
            'FR': DateTime.friday,
            'SA': DateTime.saturday,
            'SU': DateTime.sunday,
          };
          for (final d in days) {
            final wd = weekdayMap[d];
            if (wd == null) continue;
            // find the next date with that weekday starting at 'current'
            DateTime candidate = current;
            while (candidate.weekday != wd) {
              candidate = candidate.add(const Duration(days: 1));
            }
            if (candidate.isAfter(from) || candidate.isAtSameMomentAs(from)) {
              results.add(candidate);
              if (results.length >= count) break;
            }
          }
          current = current.add(Duration(days: 7 * interval));
        } else if (freq == 'MONTHLY') {
          // Keep the same day-of-month when possible
          final next = DateTime(current.year, current.month + interval, current.day, start.hour, start.minute);
          if (next.isAfter(from)) results.add(next);
          current = next;
        } else {
          // DAILY or default
          results.add(current);
          current = current.add(Duration(days: interval));
        }
      } else {
        // move current forward
        if (freq == 'MONTHLY') {
          current = DateTime(current.year, current.month + interval, current.day, start.hour, start.minute);
        } else if (freq == 'WEEKLY') {
          current = current.add(Duration(days: 7 * interval));
        } else {
          current = current.add(Duration(days: interval));
        }
      }
      // safety
      if (results.length > 500) break;
    }

    // ensure sorted and limited
    results.sort();
    return results.take(count).toList();
  }

  static String pretty(DateTime dt) => DateFormat.yMd().add_Hm().format(dt);
}
