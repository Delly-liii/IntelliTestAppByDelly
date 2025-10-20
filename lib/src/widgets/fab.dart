import 'package:flutter/material.dart';

class FAB extends StatelessWidget {
  const FAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (_) => const SizedBox(
                height: 180,
                child: Column(children: [
                  ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Add New Question')),
                  ListTile(
                      leading: Icon(Icons.library_add),
                      title: Text('Add From Bank'))
                ])));
      },
      child: const Icon(Icons.add),
    );
  }
}
