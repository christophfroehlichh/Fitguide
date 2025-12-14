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

class CalendarStrip extends StatelessWidget {
  final List<String> moods;
  const CalendarStrip({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => CalendarTile(emoji: moods[i]),
      ),
    );
  }
}

class CalendarTile extends StatelessWidget {
  final String emoji;
  const CalendarTile({super.key, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktuelles Gewicht',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: WeightChartPainter(
                  values: const [92.4, 92.1, 91.9, 91.7, 91.5, 80.3],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  final List<double> values;

  WeightChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = size.width / (values.length - 1) * i;
      final normalized = (values[i] - min) / range;
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MacroOverview extends StatelessWidget {
  const MacroOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: MacroCard(
            label: 'Protein',
            value: '180g',
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MacroCard(label: 'Carbs', value: '220g', color: Colors.orange),
        ),
        SizedBox(width: 12),
        Expanded(
          child: MacroCard(label: 'Fat', value: '70g', color: Colors.blue),
        ),
      ],
    );
  }
}

class MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MacroCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
