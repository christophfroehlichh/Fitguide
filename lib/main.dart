import 'package:flutter/material.dart';

void main() => runApp(const FitGuideApp());

class FitGuideApp extends StatelessWidget {
  const FitGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitGuide',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const DashboardScreen(),
    );
  }
}

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
              PlaceholderBox(height: 70),

              SizedBox(height: 28),
              SectionTitle('Gewicht'),
              SizedBox(height: 12),
              PlaceholderBox(height: 220),

              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionTitle('Makronährstoffe'),
                  TextButton(onPressed: null, child: Text('Anpassen')),
                ],
              ),
              SizedBox(height: 12),
              PlaceholderBox(height: 90),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            label: '',
          ),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: ''),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class PlaceholderBox extends StatelessWidget {
  final double height;
  const PlaceholderBox({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
