import 'package:flutter/material.dart';
import 'widgets/section_title.dart';
import 'widgets/calendar_strip.dart';
import 'widgets/weight_card.dart';
import 'widgets/macro_overview.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FitGuide',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Kalender'),
              SizedBox(height: 12),
              CalendarStrip(moods: ['🤩', '🤩', '🤩', '😢', '😢', '😁', '😁']),

              SizedBox(height: 28),
              SectionTitle('Gewicht'),
              SizedBox(height: 12),
              WeightCard(),

              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionTitle('Makronährstoffe'),
                  TextButton(onPressed: null, child: Text('Anpassen')),
                ],
              ),
              SizedBox(height: 12),
              MacroOverview(),
            ],
          ),
        ),
      ),
    );
  }
}
