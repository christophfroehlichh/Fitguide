import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/diary_entry_model.dart';
import '../cubit/diary_cubit.dart';
import '../widgets/diary_date_picker.dart';
import '../widgets/diary_photo_picker.dart';

class DiaryFormScreen extends StatefulWidget {
  final DiaryEntryModel? entry;
  final int dailyCalories;
  final int dailyProtein;
  final String userGoal;

  const DiaryFormScreen({
    super.key,
    this.entry,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.userGoal,
  });

  @override
  State<DiaryFormScreen> createState() => _DiaryFormScreenState();
}

class _DiaryFormScreenState extends State<DiaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  DiaryEntryModel? _currentEntry;

  final GlobalKey<DiaryPhotoPickerState> _photoPickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
    _weightController = TextEditingController(
      text: widget.entry?.weight.toString() ?? '',
    );
    _caloriesController = TextEditingController(
      text: widget.entry?.caloriesConsumed.toString() ?? '',
    );
    _proteinController = TextEditingController(
      text: widget.entry?.proteinConsumed.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.entry?.notes ?? '');
    _selectedDate = widget.entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get isEditing => _currentEntry != null;

  bool _calculateCaloriesReached(int consumed) {
    final goal = widget.dailyCalories;
    switch (widget.userGoal) {
      case 'Muskelaufbau':
        return consumed >= goal * 0.9 && consumed <= goal * 1.2;
      case 'Halten':
        return consumed >= goal * 0.85 && consumed <= goal * 1.15;
      case 'Abnehmen':
        return consumed >= goal * 0.8 && consumed <= goal * 1.05;
      default:
        return false;
    }
  }

  bool _calculateProteinReached(int consumed) {
    final goal = widget.dailyProtein;
    switch (widget.userGoal) {
      case 'Muskelaufbau':
        return consumed >= goal * 0.9;
      case 'Halten':
        return consumed >= goal * 0.85 && consumed <= goal * 1.15;
      case 'Abnehmen':
        return consumed >= goal * 0.9 && consumed <= goal * 1.2;
      default:
        return false;
    }
  }

  void _onDateChanged(DateTime newDate, DiaryEntryModel? entry) {
    setState(() {
      _selectedDate = newDate;
      _currentEntry = entry;

      if (entry != null) {
        _weightController.text = entry.weight.toString();
        _caloriesController.text = entry.caloriesConsumed.toString();
        _proteinController.text = entry.proteinConsumed.toString();
        _notesController.text = entry.notes ?? '';
      } else {
        _weightController.clear();
        _caloriesController.clear();
        _proteinController.clear();
        _notesController.clear();
      }
    });
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<DiaryCubit>();
    final weight = double.parse(_weightController.text.trim());
    final calories = int.parse(_caloriesController.text.trim());
    final protein = int.parse(_proteinController.text.trim());
    final notes = _notesController.text.trim();

    final photoUrl = await _photoPickerKey.currentState?.uploadImage();

    if (isEditing) {
      await cubit.updateEntry(
        entry: _currentEntry!,
        date: _selectedDate,
        weight: weight,
        caloriesConsumed: calories,
        proteinConsumed: protein,
        dailyCalories: widget.dailyCalories,
        dailyProtein: widget.dailyProtein,
        userGoal: widget.userGoal,
        notes: notes.isEmpty ? null : notes,
        photoUrl: photoUrl,
      );
    } else {
      await cubit.createEntry(
        date: _selectedDate,
        weight: weight,
        caloriesConsumed: calories,
        proteinConsumed: protein,
        dailyCalories: widget.dailyCalories,
        dailyProtein: widget.dailyProtein,
        userGoal: widget.userGoal,
        notes: notes.isEmpty ? null : notes,
        photoUrl: photoUrl,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: const Text('Möchtest du diesen Eintrag wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<DiaryCubit>().deleteEntry(_currentEntry!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DiaryCubit>();
    final isPhotoUploading = _photoPickerKey.currentState?.isUploading ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Eintrag bearbeiten' : 'Neuer Eintrag'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteEntry,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DiaryDatePicker(
              selectedDate: _selectedDate,
              onDateChanged: _onDateChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Gewicht',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte Gewicht eingeben';
                }
                if (double.tryParse(value) == null) {
                  return 'Bitte gültige Zahl eingeben';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: 'Kalorien',
                suffixText: 'kcal',
                border: const OutlineInputBorder(),
                helperText: 'Ziel: ${widget.dailyCalories} kcal',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte Kalorien eingeben';
                }
                if (int.tryParse(value) == null) {
                  return 'Bitte gültige Zahl eingeben';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
            if (_caloriesController.text.isNotEmpty &&
                int.tryParse(_caloriesController.text) != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      _calculateCaloriesReached(
                            int.parse(_caloriesController.text),
                          )
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 20,
                      color:
                          _calculateCaloriesReached(
                            int.parse(_caloriesController.text),
                          )
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _calculateCaloriesReached(
                            int.parse(_caloriesController.text),
                          )
                          ? 'Ziel erreicht'
                          : 'Ziel nicht erreicht',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proteinController,
              decoration: InputDecoration(
                labelText: 'Protein',
                suffixText: 'g',
                border: const OutlineInputBorder(),
                helperText: 'Ziel: ${widget.dailyProtein} g',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte Protein eingeben';
                }
                if (int.tryParse(value) == null) {
                  return 'Bitte gültige Zahl eingeben';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
            if (_proteinController.text.isNotEmpty &&
                int.tryParse(_proteinController.text) != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      _calculateProteinReached(
                            int.parse(_proteinController.text),
                          )
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 20,
                      color:
                          _calculateProteinReached(
                            int.parse(_proteinController.text),
                          )
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _calculateProteinReached(
                            int.parse(_proteinController.text),
                          )
                          ? 'Ziel erreicht'
                          : 'Ziel nicht erreicht',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notizen (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            DiaryPhotoPicker(
              key: _photoPickerKey,
              initialPhotoUrl: _currentEntry?.photoUrl,
              selectedDate: _selectedDate,
              userId: cubit.userId,
              onPhotoChanged: (url) {},
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isPhotoUploading ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isPhotoUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Speichern' : 'Erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
