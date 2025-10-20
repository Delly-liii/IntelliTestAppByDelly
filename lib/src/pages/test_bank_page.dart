import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';

class TestBankPage extends StatefulWidget {
  const TestBankPage({super.key});

  @override
  State<TestBankPage> createState() => _TestBankPageState();
}

class _TestBankPageState extends State<TestBankPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _sortBy = 'Recent';
  bool _isLoading = true;
  List<Map<String, dynamic>> _tests = [];
  List<Map<String, dynamic>> _filteredTests = [];

  @override
  void initState() {
    super.initState();
    _loadTests();
    _searchController.addListener(_filterTests);
  }

  void _loadTests() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    setState(() {
      _tests = _getSampleTests();
      _filteredTests = _tests;
      _isLoading = false;
    });
  }

  void _filterTests() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTests = _tests.where((test) {
        final matchesSearch = test['title'].toLowerCase().contains(query) ||
            test['course'].toLowerCase().contains(query);
        final matchesFilter =
            _selectedFilter == 'All' || test['status'] == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getSampleTests() {
    return [
      {
        'id': '1',
        'title': 'Mathematics Midterm Exam',
        'course': 'Calculus 101',
        'questionCount': 25,
        'duration': 90,
        'status': 'Published',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'averageScore': 78,
        'attempts': 45,
      },
      {
        'id': '2',
        'title': 'Science Quiz 1',
        'course': 'Biology 201',
        'questionCount': 15,
        'duration': 45,
        'status': 'Draft',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        'averageScore': null,
        'attempts': 0,
      },
      {
        'id': '3',
        'title': 'History Final Exam',
        'course': 'World History',
        'questionCount': 30,
        'duration': 120,
        'status': 'Published',
        'createdAt': DateTime.now().subtract(const Duration(days: 7)),
        'averageScore': 82,
        'attempts': 67,
      },
      {
        'id': '4',
        'title': 'Literature Quiz',
        'course': 'English Literature',
        'questionCount': 20,
        'duration': 60,
        'status': 'Archived',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)),
        'averageScore': 75,
        'attempts': 32,
      },
      {
        'id': '5',
        'title': 'Physics Practice Test',
        'course': 'Physics 101',
        'questionCount': 18,
        'duration': 75,
        'status': 'Published',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'averageScore': 65,
        'attempts': 28,
      },
      {
        'id': '6',
        'title': 'Chemistry Assessment',
        'course': 'Chemistry 202',
        'questionCount': 22,
        'duration': 80,
        'status': 'Draft',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'averageScore': null,
        'attempts': 0,
      },
    ];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Published':
        return TestBankColors.success;
      case 'Draft':
        return TestBankColors.warning;
      case 'Archived':
        return TestBankColors.neutral;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Published':
        return Icons.check_circle;
      case 'Draft':
        return Icons.edit;
      case 'Archived':
        return Icons.archive;
      default:
        return Icons.help_outline;
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filter Tests',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),

                  // Status Filter
                  _buildFilterSection(
                      'Status',
                      ['All', 'Published', 'Draft', 'Archived'],
                      _selectedFilter, (value) {
                    setState(() => _selectedFilter = value);
                  }),

                  const SizedBox(height: 16),

                  // Sort Options
                  _buildSortOptions(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'All';
                              _sortBy = 'Recent';
                            });
                            Navigator.pop(context);
                            _filterTests();
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _filterTests();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TestBankColors.primary,
                          ),
                          child: const Text('Apply Filters',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options,
      String selected, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selected;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              backgroundColor:
                  isSelected ? TestBankColors.primary.withOpacity(0.1) : null,
              labelStyle: TextStyle(
                color: isSelected ? TestBankColors.primary : Colors.grey[700],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sortBy,
          items: ['Recent', 'Most Attempts', 'Highest Score', 'Alphabetical']
              .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
              .toList(),
          onChanged: (v) => setState(() => _sortBy = v ?? 'Recent'),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _showCreateTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: TestBankColors.primary),
            SizedBox(width: 8),
            Text('Create New Test'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCreationOption(
                'Create from Scratch',
                'Build a new test from empty template',
                Icons.create_outlined,
                () {
                  Navigator.pop(context);
                  // Navigate to test creation
                },
              ),
              const SizedBox(height: 12),
              _buildCreationOption(
                'Use Template',
                'Start from a pre-made template',
                Icons.content_copy_outlined,
                () {
                  Navigator.pop(context);
                  // Navigate to templates
                },
              ),
              const SizedBox(height: 12),
              _buildCreationOption(
                'Import Questions',
                'Import from question bank',
                Icons.file_upload_outlined,
                () {
                  Navigator.pop(context);
                  // Navigate to import
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreationOption(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: TestBankColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: isWide
          ? null
          : const PreferredSize(
              preferredSize: Size.fromHeight(64),
              child: TopBar(),
            ),
      drawer: isWide ? null : const SideBar(),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) const SideBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    const SizedBox(height: 24),

                    // Analytics Section
                    _buildAnalyticsSection(isWide),
                    const SizedBox(height: 24),

                    // Search and Actions Bar
                    _buildSearchSection(),
                    const SizedBox(height: 24),

                    // Tests Grid
                    _buildTestsSection(isWide),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTestDialog,
        backgroundColor: TestBankColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Row(
      children: [
        Icon(Icons.assignment_outlined,
            size: 32, color: TestBankColors.primary),
        SizedBox(width: 12),
        Text(
          "Test Bank",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(bool isWide) {
    final totalTests = _tests.length;
    final publishedTests =
        _tests.where((test) => test['status'] == 'Published').length;
    final totalAttempts =
        _tests.fold(0, (sum, test) => sum + (test['attempts'] as int));
    final avgScore = _tests
            .where((test) => test['averageScore'] != null)
            .fold(0.0, (sum, test) => sum + (test['averageScore'] as int)) /
        _tests.where((test) => test['averageScore'] != null).length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildAnalyticsCard('Total Tests', '$totalTests', Icons.assignment,
            TestBankColors.primary),
        _buildAnalyticsCard('Published', '$publishedTests', Icons.check_circle,
            TestBankColors.success),
        _buildAnalyticsCard('Total Attempts', '$totalAttempts', Icons.people,
            TestBankColors.accent),
        _buildAnalyticsCard(
            'Avg Score',
            '${avgScore.isNaN ? 0 : avgScore.round()}%',
            Icons.bar_chart,
            TestBankColors.warning),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tests...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _showFilters,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsSection(bool isWide) {
    if (_isLoading) {
      return _buildLoadingSkeleton(isWide);
    }

    if (_filteredTests.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 3 : 1,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredTests.length,
        itemBuilder: (context, index) => _buildTestCard(_filteredTests[index]),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(test['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(test['status']),
                          size: 14, color: _getStatusColor(test['status'])),
                      const SizedBox(width: 4),
                      Text(
                        test['status'],
                        style: TextStyle(
                          color: _getStatusColor(test['status']),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (test['averageScore'] != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bar_chart,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '${test['averageScore']}%',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Test title
            Text(
              test['title'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Course and details
            Text(
              test['course'],
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Test metrics
            Row(
              children: [
                _buildTestMetric(
                    Icons.quiz_outlined, '${test['questionCount']} Qs'),
                const SizedBox(width: 12),
                _buildTestMetric(
                    Icons.timer_outlined, '${test['duration']} min'),
                const SizedBox(width: 12),
                _buildTestMetric(
                    Icons.people_outline, '${test['attempts']} attempts'),
              ],
            ),
            const Spacer(),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Edit functionality
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text('View Details')),
                    const PopupMenuItem(
                        value: 'preview', child: Text('Preview Test')),
                    const PopupMenuItem(
                        value: 'duplicate', child: Text('Duplicate')),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuItem(
                        value: 'archive', child: Text('Archive')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (value) {
                    // Handle menu actions
                    debugPrint("Selected $value for ${test['title']}");
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestMetric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No tests found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or create your first test',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showCreateTestDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TestBankColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isWide) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 3 : 1,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TestBankColors {
  static const primary = Color(0xFF1976D2);
  static const success = Color(0xFF388E3C);
  static const warning = Color(0xFFF57C00);
  static const accent = Color(0xFF7B1FA2);
  static const neutral = Color(0xFF757575);
}
