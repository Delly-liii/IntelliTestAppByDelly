import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;
  bool _isHidden = false;
  bool _isHovering = false;
  int _selectedIndex = 0;

  static const double expandedWidth = 260;
  static const double collapsedWidth = 70;
  static const double mobileBreakpoint = 800;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'label': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'route': '/',
      'color': SideBarColors.primary
    },
    {
      'label': 'My Courses',
      'icon': Icons.book_outlined,
      'route': '/courses',
      'color': SideBarColors.secondary
    },
    {
      'label': 'Question Bank',
      'icon': Icons.storage_outlined,
      'route': '/question-bank',
      'color': SideBarColors.accent
    },
    {
      'label': 'Test Bank',
      'icon': Icons.assignment_outlined,
      'route': '/test-bank',
      'color': SideBarColors.warning
    },
    {
      'label': 'Analytics',
      'icon': Icons.analytics_outlined,
      'route': '/analytics',
      'color': SideBarColors.info
    },
    {
      'label': 'Gradebook',
      'icon': Icons.grade_outlined,
      'route': '/gradebook',
      'color': SideBarColors.success
    },
    {
      'label': 'Calendar',
      'icon': Icons.calendar_month_outlined,
      'route': '/calendar',
      'color': SideBarColors.neutral
    },
    {
      'label': 'Settings',
      'icon': Icons.settings_outlined,
      'route': '/settings',
      'color': SideBarColors.neutral
    },
  ];

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < mobileBreakpoint;

    if (isMobile) {
      return Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
        child: _buildSidebarContent(context, collapsed: false),
      );
    }

    if (_isHidden) {
      return Container(
        width: 48,
        margin: const EdgeInsets.only(right: 8),
        alignment: Alignment.center,
        child: FloatingActionButton.small(
          heroTag: 'show_sidebar',
          backgroundColor: SideBarColors.primary,
          child: const Icon(Icons.menu, color: Colors.white, size: 20),
          onPressed: () => setState(() => _isHidden = false),
        ),
      );
    }

    final bool effectiveCollapsed = _isCollapsed && !_isHovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: effectiveCollapsed ? collapsedWidth : expandedWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(4, 0))
          ],
          border: Border(
              right: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child:
                  _buildSidebarContent(context, collapsed: effectiveCollapsed),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, {required bool collapsed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBrandHeader(collapsed),
        if (!collapsed) _buildQuickStats(),
        Expanded(child: _buildNavigationMenu(collapsed)),
        _buildBottomControls(collapsed),
      ],
    );
  }

  Widget _buildBrandHeader(bool collapsed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(collapsed ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SideBarColors.primary,
            SideBarColors.primary.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: collapsed ? 36 : 44,
            height: collapsed ? 36 : 44,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: Icon(Icons.auto_awesome,
                color: SideBarColors.primary, size: collapsed ? 18 : 22),
          ),
          if (!collapsed)
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("IntelliTest",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text("Dr. Sarah Johnson",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {'label': 'Tests', 'value': 12, 'icon': Icons.assignment_turned_in},
      {'label': 'Students', 'value': 45, 'icon': Icons.people},
      {'label': 'Questions', 'value': 156, 'icon': Icons.quiz},
      {'label': 'Avg Score', 'value': 78, 'icon': Icons.bar_chart},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 16,
        runSpacing: 12,
        children: stats
            .map((s) => AnimatedStatItem(
                label: s['label'] as String,
                value: s['value'].toString(),
                icon: s['icon'] as IconData))
            .toList(),
      ),
    );
  }

  Widget _buildNavigationMenu(bool collapsed) {
    return ListView.builder(
      itemCount: _menuItems.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        final isActive = _selectedIndex == index;

        Widget tile = TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: isActive ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() => _selectedIndex = index);
                  if (ModalRoute.of(context)?.settings.name != item['route']) {
                    Navigator.of(context).pushReplacementNamed(item['route']);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? item['color'].withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? Border.all(
                            color: item['color'].withOpacity(0.3), width: 1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? item['color']
                              : item['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'],
                            color: isActive ? Colors.white : item['color'],
                            size: 20),
                      ),
                      if (!collapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(item['label'],
                                style: TextStyle(
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isActive
                                        ? item['color']
                                        : Colors.grey[700]))),
                        if (isActive)
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: item['color'],
                                  shape: BoxShape.circle)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        if (collapsed) {
          tile = Tooltip(
              message: item['label'],
              waitDuration: const Duration(milliseconds: 300),
              child: tile);
        }

        return tile;
      },
    );
  }

  Widget _buildBottomControls(bool collapsed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              Tooltip(
                message: collapsed ? "Expand Sidebar" : "Collapse Sidebar",
                child: IconButton(
                  icon: Icon(
                      collapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: SideBarColors.primary),
                  onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                ),
              ),
              if (!collapsed)
                Tooltip(
                  message: "Hide Sidebar",
                  child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => setState(() => _isHidden = true)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: "Logout",
            child: GestureDetector(
              onTap: () => _showLogoutConfirmation(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    SideBarColors.error.withOpacity(0.9),
                    SideBarColors.error
                  ]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.white, size: 18),
                    if (!collapsed) const SizedBox(width: 8),
                    if (!collapsed)
                      const Text("Logout",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: const [
          Icon(Icons.logout, color: SideBarColors.error),
          SizedBox(width: 8),
          Text("Logout Confirmation")
        ]),
        content:
            const Text("Are you sure you want to logout from IntelliTest?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: SideBarColors.error),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Animated Stat Item
class AnimatedStatItem extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;

  const AnimatedStatItem(
      {super.key,
      required this.label,
      required this.value,
      required this.icon});

  @override
  State<AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<AnimatedStatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: SideBarColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(widget.icon, size: 16, color: SideBarColors.primary),
            ),
            const SizedBox(height: 4),
            Text(widget.value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(widget.label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class SideBarColors {
  static const primary = Color(0xFF7E57C2);
  static const secondary = Color(0xFF26A69A);
  static const accent = Color(0xFF5C6BC0);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);
  static const success = Color(0xFF66BB6A);
  static const error = Color(0xFFEF5350);
  static const neutral = Color(0xFF78909C);
}
