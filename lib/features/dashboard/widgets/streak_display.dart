import 'package:flutter/material.dart';
import '../../logbook/diary/models/diary_entry_model.dart';

class StreakDisplay extends StatefulWidget {
  final List<DiaryEntryModel> diaryEntries;

  const StreakDisplay({super.key, required this.diaryEntries});

  @override
  State<StreakDisplay> createState() => _StreakDisplayState();
}

class _StreakDisplayState extends State<StreakDisplay> {
  int? _cachedStreak;
  List<DiaryEntryModel>? _cachedEntries;

  int _calculateStreak() {
    // Cache-Check
    if (_cachedStreak != null && _cachedEntries == widget.diaryEntries) {
      return _cachedStreak!;
    }

    if (widget.diaryEntries.isEmpty) {
      _cachedStreak = 0;
      _cachedEntries = widget.diaryEntries;
      return 0;
    }

    final sortedEntries = List<DiaryEntryModel>.from(widget.diaryEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime checkDate = today;

    // Heute checken
    final todayEntry = sortedEntries.cast<DiaryEntryModel?>().firstWhere((
      entry,
    ) {
      if (entry == null) return false;
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }, orElse: () => null);

    if (todayEntry != null) {
      final todayGoalsReached =
          todayEntry.caloriesReached && todayEntry.proteinReached;
      if (!todayGoalsReached) {
        checkDate = today.subtract(const Duration(days: 1));
      }
    } else {
      checkDate = today.subtract(const Duration(days: 1));
    }

    // Streak berechnen
    for (var entry in sortedEntries) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );

      if (entryDate.isAtSameMomentAs(checkDate)) {
        if (entry.caloriesReached && entry.proteinReached) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else if (entryDate.isBefore(checkDate)) {
        break;
      }
    }

    _cachedStreak = streak;
    _cachedEntries = widget.diaryEntries;
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _calculateStreak();
    final hasStreak = streak > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 32,
            color:
                hasStreak
                      ? Colors.deepOrange
                      : Theme.of(context).colorScheme.onSurfaceVariant
                  ..withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasStreak
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
