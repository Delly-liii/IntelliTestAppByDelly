import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0, // modern flat design
      backgroundColor: Theme.of(context).colorScheme.surface,
      toolbarHeight: 64,
      titleSpacing: 16,

      // Left side: Logo + App Name
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'IntelliTest APP',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),

      // Right side: Search + Notifications + Avatar
      actions: [
        // 🔍 Search bar
        SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: TextFormField(
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: 'Search tests, questions, or students...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),
        ),

        // 🔔 Notifications
        IconButton(
          icon: const Icon(Icons.notifications_none),
          color: Theme.of(context).colorScheme.onSurface,
          tooltip: "Notifications",
          onPressed: () {
            // TODO: open notifications panel
          },
        ),

        // 👤 User avatar with dropdown menu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: PopupMenuButton<int>(
            tooltip: "User Menu",
            offset: const Offset(0, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text("Profile")),
              const PopupMenuItem(value: 1, child: Text("Settings")),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 2,
                child: Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value == 2) {
                // TODO: implement logout
              }
            },
            child: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text("AZ", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
