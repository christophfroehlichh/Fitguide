import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/diary_cubit.dart';
import '../cubit/diary_state.dart';
import '../models/diary_entry_model.dart';

class DiaryDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime, DiaryEntryModel?) onDateChanged;

  const DiaryDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final cubit = context.read<DiaryCubit>();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final state = cubit.state;

      if (state is DiaryLoaded) {
        final entriesForDate = state.entries
            .where(
              (e) =>
                  e.date.year == picked.year &&
                  e.date.month == picked.month &&
                  e.date.day == picked.day,
            )
            .toList();

        if (entriesForDate.isNotEmpty) {
          onDateChanged(picked, entriesForDate.first);
        } else {
          onDateChanged(picked, null);
        }
      } else {
        onDateChanged(picked, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Datum',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(dateFormat.format(selectedDate)),
      ),
    );
  }
}
