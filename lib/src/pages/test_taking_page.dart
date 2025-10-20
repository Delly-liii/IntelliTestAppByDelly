import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';

class TestTakingPage extends StatelessWidget {
  const TestTakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(64), child: TopBar()),
      drawer: const SideBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SizedBox(
              width: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Intro to Biology',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(value: 0.25, minHeight: 8),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('What is the powerhouse of the cell?',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          RadioListTile(
                              value: 'a',
                              groupValue: null,
                              onChanged: (v) {},
                              title: const Text('Ribosome')),
                          RadioListTile(
                              value: 'b',
                              groupValue: null,
                              onChanged: (v) {},
                              title: const Text('Mitochondria')),
                          RadioListTile(
                              value: 'c',
                              groupValue: null,
                              onChanged: (v) {},
                              title: const Text('Nucleus')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Previous')),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Next')),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
