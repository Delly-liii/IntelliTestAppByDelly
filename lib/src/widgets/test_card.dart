import 'package:flutter/material.dart';

class TestCard extends StatelessWidget {
  final String title;
  final String course;
  final String status;
  final String avgScore;
  final int responseRate;
  const TestCard({super.key, required this.title, required this.course, required this.status, required this.avgScore, required this.responseRate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height:4), Text('$course · Due TBD', style: const TextStyle(color: Colors.grey))]), Column(children: [Chip(label: Text(status)), const SizedBox(height:8), Text('Avg: $avgScore', style: const TextStyle(fontSize:12))])]),
          const Spacer(),
          LinearProgressIndicator(value: responseRate/100.0),
          const SizedBox(height:8),
          Text('$responseRate% responses', style: const TextStyle(fontSize:12, color: Colors.grey))
        ]),
      ),
    );
  }
}
