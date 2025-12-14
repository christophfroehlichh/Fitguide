import 'package:flutter/material.dart';

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
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}
