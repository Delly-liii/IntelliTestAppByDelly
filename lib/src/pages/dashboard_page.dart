import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/action_card.dart';
import '../widgets/fab.dart';
import '../pages/test_provider.dart';
import '../pages/test_editor_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int notificationCount = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: DashboardColors.primary,
              child: Text(
                'T',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('John Doe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('teacher@school.edu',
                style: TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_customize),
              title: const Text('Customize Dashboard'),
              onTap: _showCustomizationOptions,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logoutUser(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomizationOptions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Customize Dashboard'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _customizationOption('Show Performance Charts', true),
              _customizationOption('Show Recent Activity', true),
              _customizationOption('Show Quick Actions', true),
              _customizationOption('Show Upcoming Deadlines', false),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dashboard customized')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _customizationOption(String title, bool value) {
    return StatefulBuilder(
      builder: (context, setState) => SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: (bool newValue) {
          setState(() {});
        },
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              ListTile(
                leading: Icon(Icons.message, color: DashboardColors.primary),
                title: Text('New student question'),
                subtitle: Text('Math 101 · 5m ago'),
              ),
              ListTile(
                leading: Icon(Icons.assessment, color: DashboardColors.success),
                title: Text('Test results ready'),
                subtitle: Text('Science 202 · 1h ago'),
              ),
              ListTile(
                leading: Icon(Icons.warning, color: DashboardColors.warning),
                title: Text('Low performance alert'),
                subtitle: Text('English 103 · 3h ago'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                notificationCount = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Mark All as Read'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _TestSearchDelegate(),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Tests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildFilterOption('Recent Tests', true),
            _buildFilterOption('High Priority', false),
            _buildFilterOption('Needs Grading', true),
            _buildFilterOption('Completed', false),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, bool value) {
    return StatefulBuilder(
      builder: (context, setState) => CheckboxListTile(
        title: Text(title),
        value: value,
        onChanged: (bool? newValue) {
          setState(() {});
        },
      ),
    );
  }

  void _logoutUser() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final width = MediaQuery.of(context).size.width;

    final metricCardWidth = width > 1200
        ? 240.0
        : width > 800
            ? 200.0
            : ((width - 48) / 2).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // IntelliTest Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: DashboardColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'IntelliTest',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: DashboardColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, size: 26),
                if (notificationCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: DashboardColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$notificationCount',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: _showProfileMenu,
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: isWide ? null : const SideBar(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) const Expanded(flex: 2, child: SideBar()),
            Expanded(
              flex: 8,
              child: _isLoading
                  ? _buildLoadingSkeleton()
                  : _buildDashboardContent(isWide, metricCardWidth),
            ),
          ],
        ),
      ),
      floatingActionButton: const FAB(),
    );
  }

  // ✅ FIXED: Replaced with SingleChildScrollView to prevent overflow
  Widget _buildDashboardContent(bool isWide, double metricCardWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(),
          const SizedBox(height: 24),

          // Action Cards
          _buildActionCardsSection(isWide),
          const SizedBox(height: 24),

          // At-a-Glance Metrics
          _buildMetricsSection(metricCardWidth),
          const SizedBox(height: 24),

          // Performance Chart Section
          _buildPerformanceChartSection(),
          const SizedBox(height: 24),

          // Your Tests Section (no Expanded - fixed!)
          _buildTestsSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Good morning, Teacher 👋',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          _getFormattedDate(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
              ),
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildActionCardsSection(bool isWide) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200
        ? 3
        : screenWidth > 600
            ? 2
            : 1;
    final childAspectRatio = screenWidth > 600 ? 3.0 : 3.5;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ActionCard(
          title: 'Create New Test',
          subtitle: 'Build a new assessment from scratch or from your bank',
          icon: Icons.add_circle_outline,
          iconColor: DashboardColors.primary,
          onTap: () => Navigator.pushNamed(context, '/create-test'),
        ),
        ActionCard(
          title: 'Add to Question Bank',
          subtitle: 'Save and organize questions easily',
          icon: Icons.storage_outlined,
          iconColor: DashboardColors.success,
          onTap: () => Navigator.pushNamed(context, '/question-bank'),
        ),
        ActionCard(
          title: 'View Analytics',
          subtitle: 'Track performance and progress',
          icon: Icons.bar_chart_outlined,
          iconColor: DashboardColors.warning,
          onTap: () => Navigator.pushNamed(context, '/analytics'),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(double metricCardWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'At-a-Glance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _enhancedMetricCard('Tests to Grade', '3', DashboardColors.warning,
                0.3, isMobile ? double.infinity : metricCardWidth),
            _enhancedMetricCard(
                'Average Performance',
                '85%',
                DashboardColors.success,
                0.85,
                isMobile ? double.infinity : metricCardWidth),
            _enhancedMetricCard(
                'Unread Questions',
                '1',
                DashboardColors.primary,
                0.1,
                isMobile ? double.infinity : metricCardWidth),
            _enhancedMetricCard(
                'Student Engagement',
                '92%',
                DashboardColors.success,
                0.92,
                isMobile ? double.infinity : metricCardWidth),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceChartSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar(80, 'Mon', DashboardColors.primary),
                  _buildChartBar(65, 'Tue', DashboardColors.primary),
                  _buildChartBar(90, 'Wed', DashboardColors.success),
                  _buildChartBar(75, 'Thu', DashboardColors.primary),
                  _buildChartBar(85, 'Fri', DashboardColors.primary),
                  _buildChartBar(95, 'Sat', DashboardColors.success),
                  _buildChartBar(70, 'Sun', DashboardColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(double height, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 20,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ✅ FIXED: Removed nested Expanded and added fixed height
  Widget _buildTestsSection() {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Tests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, size: 18),
                  ),
                  onPressed: _showSearch,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.filter_list, size: 18),
                  ),
                  onPressed: _showFilters,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (testProvider.tests.isEmpty)
              _buildEmptyTestsState()
            else
              SizedBox(
                height: 400, // Fixed height to prevent overflow
                child: _buildTestsList(testProvider),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTestsList(TestProvider testProvider) {
    return ListView.builder(
      itemCount: testProvider.tests.length,
      itemBuilder: (context, index) {
        final test = testProvider.tests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DashboardColors.primary.withOpacity(0.1),
                    DashboardColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.assignment, color: DashboardColors.primary),
            ),
            title: Text(test.title,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
                '${test.type ?? 'Manual'} • ${test.questions?.length ?? 0} questions'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: DashboardColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit,
                        size: 18, color: DashboardColors.primary),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TestEditorPage(testId: ''),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: DashboardColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete,
                        size: 18, color: DashboardColors.error),
                  ),
                  onPressed: () {
                    testProvider.removeTest(index as String);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTestsState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No tests created yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first test to get started with assessments',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/create-test'),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enhancedMetricCard(
      String title, String value, Color color, double progress, double width) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      progress > 0.7 ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}% complete',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            width: 200,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),

          // Action cards skeleton
          Row(
            children: List.generate(
                3,
                (index) => Expanded(
                      child: Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
          ),
        ],
      ),
    );
  }
}

class DashboardColors {
  static const primary = Color(0xFF4361EE);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);
}

class _TestSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.assignment),
          title: Text('Math Midterm Exam'),
          subtitle: Text('Mathematics • 25 questions'),
        ),
        ListTile(
          leading: Icon(Icons.assignment),
          title: Text('Science Quiz 1'),
          subtitle: Text('Science • 15 questions'),
        ),
      ],
    );
  }
}
