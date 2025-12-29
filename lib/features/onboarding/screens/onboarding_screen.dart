import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _goal;
  String? _activityLevel;
  int? _trainingFrequency;
  int? _trainingDuration;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.isNotEmpty;
      case 1:
        return _heightController.text.isNotEmpty &&
            _weightController.text.isNotEmpty;
      case 2:
        return _goal != null;
      case 3:
        return _activityLevel != null;
      case 4:
        return _trainingFrequency != null && _trainingDuration != null;
      default:
        return false;
    }
  }

  void _completeOnboarding() {
    if (!_canProceed()) return;

    context.read<AuthCubit>().completeOnboarding(
          name: _nameController.text.trim(),
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          goal: _goal!,
          activityLevel: _activityLevel!,
          trainingFrequency: _trainingFrequency!,
          trainingDuration: _trainingDuration!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einrichtung'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildNamePage(),
                _buildBodyDataPage(),
                _buildGoalPage(),
                _buildActivityPage(),
                _buildTrainingPage(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Zurück'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _canProceed() ? _nextPage : null,
                    child: Text(_currentPage == 4 ? 'Fertig' : 'Weiter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Wie heißt du?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outlined),
            ),
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildBodyDataPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Deine Körperdaten',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _heightController,
            decoration: const InputDecoration(
              labelText: 'Größe (cm)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.height),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Gewicht (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_weight_outlined),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    final goals = ['Abnehmen', 'Muskelaufbau', 'Halten'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Was ist dein Ziel?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...goals.map((goal) {
            final isSelected = _goal == goal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: FilterChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    goal,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _goal = goal;
                  });
                },
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityPage() {
    final activities = {
      'Sedentary': 'Wenig bis keine Bewegung',
      'Lightly Active': 'Leichte Aktivität (1-3 Tage/Woche)',
      'Moderately Active': 'Moderate Aktivität (3-5 Tage/Woche)',
      'Very Active': 'Hohe Aktivität (6-7 Tage/Woche)',
      'Extra Active': 'Sehr hohe Aktivität (täglich + körperliche Arbeit)',
    };

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Wie aktiv bist du?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...activities.entries.map((entry) {
              final isSelected = _activityLevel == entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FilterChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _activityLevel = entry.key;
                    });
                  },
                  showCheckmark: false,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dein Training',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Text(
            'Wie oft möchtest du trainieren?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final days = index + 1;
              final isSelected = _trainingFrequency == days;
              return ChoiceChip(
                label: Text('$days ${days == 1 ? 'Tag' : 'Tage'}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _trainingFrequency = days;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 32),

          Text(
            'Wie lange pro Training? (Minuten)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [30, 45, 60, 90, 120].map((minutes) {
              final isSelected = _trainingDuration == minutes;
              return ChoiceChip(
                label: Text('$minutes min'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _trainingDuration = minutes;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
