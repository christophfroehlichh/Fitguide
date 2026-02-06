import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  String? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatsController = TextEditingController();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          final user = authState.user;

          if (_caloriesController.text.isEmpty) {
            _caloriesController.text = user.dailyCalories?.toString() ?? '';
            _proteinController.text = user.dailyProtein?.toString() ?? '';
            _carbsController.text = user.dailyCarbs?.toString() ?? '';
            _fatsController.text = user.dailyFats?.toString() ?? '';
            _selectedGoal = user.goal;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: ListView(
              children: [
                const SizedBox(height: 8),
                _buildThemeSection(context),
                const Divider(),
                _buildMacrosSection(context, user),
                const Divider(),
                _buildGoalSection(context, user),
                const Divider(),
                _buildLogoutSection(context),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: const Center(child: Text('Nicht angemeldet')),
        );
      },
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Theme'),
          subtitle: Text(isDark ? 'Dark Mode' : 'Light Mode'),
          trailing: IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              size: 28,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        );
      },
    );
  }

  Widget _buildMacrosSection(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Makronährstoffe',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _caloriesController,
            decoration: const InputDecoration(
              labelText: 'Kalorien (kcal)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _proteinController,
            decoration: const InputDecoration(
              labelText: 'Protein (g)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _carbsController,
            decoration: const InputDecoration(
              labelText: 'Kohlenhydrate (g)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fatsController,
            decoration: const InputDecoration(
              labelText: 'Fette (g)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _saveMacros(context, user),
            child: const Text('Makros speichern'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context, user) {
    final goals = ['Halten', 'Muskelaufbau', 'Abnehmen'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trainingsziel',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedGoal,
            decoration: const InputDecoration(
              labelText: 'Ziel',
              border: OutlineInputBorder(),
            ),
            items: goals.map((goal) {
              return DropdownMenuItem(
                value: goal,
                child: Text(goal),
              );
            }).toList(),
            onChanged: (value) {
              _selectedGoal = value;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _saveGoal(context, user),
            child: const Text('Ziel speichern'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: () => _showLogoutDialog(context),
    );
  }

  void _saveMacros(BuildContext context, user) {
    final calories = int.tryParse(_caloriesController.text);
    final protein = int.tryParse(_proteinController.text);
    final carbs = int.tryParse(_carbsController.text);
    final fats = int.tryParse(_fatsController.text);

    if (calories != null && protein != null && carbs != null && fats != null) {
      final updatedUser = user.copyWith(
        dailyCalories: calories,
        dailyProtein: protein,
        dailyCarbs: carbs,
        dailyFats: fats,
      );
      context.read<AuthCubit>().updateUserProfile(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Makros gespeichert')),
      );
    }
  }

  void _saveGoal(BuildContext context, user) {
    if (_selectedGoal != null) {
      final updatedUser = user.copyWith(goal: _selectedGoal);
      context.read<AuthCubit>().updateUserProfile(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ziel gespeichert')),
      );
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
