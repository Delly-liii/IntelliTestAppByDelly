// lib/src/pages/analytics_page.dart
// Fixed: prevents RenderFlex horizontal overflow and removes null-widget returns.
// Adds horizontal scrolling for the filter row and defensive widget returns.

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';
import 'dart:math';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class TestRecord {
  final String name;
  final String category;
  final int score;
  final DateTime date;
  final String status;

  TestRecord({
    required this.name,
    required this.category,
    required this.score,
    required this.date,
    required this.status,
  });
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeFilter = 0;

  // Filters
  String _categoryFilter = 'All';
  String _performanceFilter = 'All';
  DateTimeRange? _dateRange;
  String _search = '';

  // Dummy dataset
  final List<TestRecord> _allTests = [];

  final List<Color> _performanceColors = [
    Colors.green,
    Colors.lightGreen,
    Colors.orange,
    Colors.red
  ];
  final List<Color> _questionTypeColors = [
    Colors.blue,
    Colors.purple,
    Colors.amber,
    Colors.deepOrange
  ];
  final List<Color> _difficultyColors = [
    Colors.green,
    Colors.orange,
    Colors.red
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateDummyData();
  }

  void _generateDummyData() {
    final rnd = Random(42);
    final categories = ['MCQ', 'Short Answer', 'True/False', 'Essay'];
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final cat = categories[rnd.nextInt(categories.length)];
      final score = 50 + rnd.nextInt(51); // 50..100
      final date = now.subtract(Duration(days: rnd.nextInt(90)));
      final status = score >= 60 ? 'Passed' : 'Failed';
      _allTests.add(TestRecord(
        name: '$cat Test #${i + 1}',
        category: cat,
        score: score,
        date: date,
        status: status,
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---- Filtering logic ----
  List<TestRecord> get _filteredTests {
    return _allTests.where((t) {
      if (_categoryFilter != 'All' && t.category != _categoryFilter) {
        return false;
      }

      switch (_performanceFilter) {
        case 'Excellent':
          if (t.score < 90) return false;
          break;
        case 'Good':
          if (t.score < 75 || t.score >= 90) return false;
          break;
        case 'Average':
          if (t.score < 60 || t.score >= 75) return false;
          break;
        case 'Needs Improvement':
          if (t.score >= 60) return false;
          break;
        default:
          break;
      }

      if (_dateRange != null) {
        if (t.date.isBefore(_dateRange!.start) ||
            t.date.isAfter(_dateRange!.end)) return false;
      }

      if (_search.trim().isNotEmpty &&
          !t.name.toLowerCase().contains(_search.trim().toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }

  // Pie data builders (safe even when filtered list is empty)
  Map<String, double> get _performanceData {
    final buckets = {
      "Excellent (90-100%)": 0.0,
      "Good (75-89%)": 0.0,
      "Average (60-74%)": 0.0,
      "Needs Improvement (<60%)": 0.0,
    };

    final list = _filteredTests;
    if (list.isEmpty) return buckets;

    for (final t in list) {
      if (t.score >= 90)
        buckets["Excellent (90-100%)"] = buckets["Excellent (90-100%)"]! + 1;
      else if (t.score >= 75)
        buckets["Good (75-89%)"] = buckets["Good (75-89%)"]! + 1;
      else if (t.score >= 60)
        buckets["Average (60-74%)"] = buckets["Average (60-74%)"]! + 1;
      else
        buckets["Needs Improvement (<60%)"] =
            buckets["Needs Improvement (<60%)"]! + 1;
    }

    final total = list.length.toDouble();
    return buckets.map((k, v) => MapEntry(k, v / total * 100));
  }

  Map<String, double> get _questionTypeData {
    final buckets = <String, double>{};
    final list = _filteredTests;
    if (list.isEmpty) {
      return {"MCQ": 0, "Short Answer": 0, "True/False": 0, "Essay": 0};
    }
    for (final t in list) {
      buckets[t.category] = (buckets[t.category] ?? 0) + 1;
    }
    final total = list.length.toDouble();
    final result = <String, double>{};
    for (final key in ['MCQ', 'Short Answer', 'True/False', 'Essay']) {
      result[key] = (buckets[key] ?? 0) / total * 100;
    }
    return result;
  }

  Map<String, double> get _difficultyData {
    final mapping = {
      'MCQ': 'Easy',
      'True/False': 'Easy',
      'Short Answer': 'Medium',
      'Essay': 'Hard'
    };
    final buckets = {'Easy': 0.0, 'Medium': 0.0, 'Hard': 0.0};
    final list = _filteredTests;
    if (list.isEmpty) return buckets;
    for (final t in list) {
      final key = mapping[t.category] ?? 'Medium';
      buckets[key] = buckets[key]! + 1;
    }
    final total = list.length.toDouble();
    return buckets.map((k, v) => MapEntry(k, v / total * 100));
  }

  // ---- UI helpers ----
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final last90 = now.subtract(const Duration(days: 90));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange ?? DateTimeRange(start: last90, end: now),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  void _clearDateRange() => setState(() => _dateRange = null);

  void _resetFilters() {
    setState(() {
      _categoryFilter = 'All';
      _performanceFilter = 'All';
      _dateRange = null;
      _search = '';
    });
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exporting analytics report...')));
  }

  // ---- Build ----
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: isWide
          ? null
          : const PreferredSize(
              preferredSize: Size.fromHeight(64), child: TopBar()),
      drawer: isWide ? null : const SideBar(),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) const Expanded(flex: 2, child: SideBar()),
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 16),
                    _buildMetricsSection(),
                    const SizedBox(height: 16),
                    _buildTimeFilterSection(),
                    const SizedBox(height: 12),
                    _buildFiltersCard(), // filters placed above charts
                    const SizedBox(height: 18),
                    _buildAnalyticsTabs(),
                    const SizedBox(height: 18),
                    _buildDataTableCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Row(
      children: [
        Icon(Icons.analytics_outlined,
            size: 32, color: AnalyticsColors.primary),
        SizedBox(width: 12),
        Text('Analytics Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildMetricCard(
            'Average Score', '78%', Icons.bar_chart, AnalyticsColors.primary,
            trend: 5.2),
        _buildMetricCard('Completion Rate', '92%', Icons.check_circle,
            AnalyticsColors.success,
            trend: 2.1),
        _buildMetricCard(
            'Avg Time Spent', '18m', Icons.timer, AnalyticsColors.warning,
            trend: -1.3),
        _buildMetricCard('Total Tests Taken', '156', Icons.assignment,
            AnalyticsColors.accent,
            trend: 12.5),
        _buildMetricCard(
            'Student Engagement', '88%', Icons.people, AnalyticsColors.info,
            trend: 3.7),
        _buildMetricCard('Questions Answered', '2,847', Icons.quiz,
            AnalyticsColors.secondary,
            trend: 8.9),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color,
      {double? trend}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              if (trend != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    Icon(trend > 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12, color: trend > 0 ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text('${trend.abs()}%',
                        style: TextStyle(
                            fontSize: 10,
                            color: trend > 0 ? Colors.green : Colors.red))
                  ]),
                )
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          const Text('Time Period:',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Wrap(spacing: 8, children: [
            _buildTimeFilterChip('Weekly', 0),
            _buildTimeFilterChip('Monthly', 1),
            _buildTimeFilterChip('Quarterly', 2)
          ]),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: _exportAnalytics,
              tooltip: 'Export Report')
        ]),
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, int index) {
    final isSelected = _selectedTimeFilter == index;
    return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedTimeFilter = index),
        selectedColor: AnalyticsColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
            color: isSelected ? AnalyticsColors.primary : Colors.grey[700]));
  }

  // ---- FILTERS CARD (wrapped horizontally to avoid overflow) ----
  Widget _buildFiltersCard() {
    final categories = <String>[
      'All',
      'MCQ',
      'Short Answer',
      'True/False',
      'Essay'
    ];
    final performanceLevels = <String>[
      'All',
      'Excellent',
      'Good',
      'Average',
      'Needs Improvement'
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // Wrap the row in a horizontal SingleChildScrollView to prevent overflow on narrow screens.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _categoryFilter,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _categoryFilter = v ?? 'All'),
                    decoration: const InputDecoration(
                        labelText: 'Category',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  ),
                ),
                const SizedBox(width: 12),

                // Performance
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _performanceFilter,
                    items: performanceLevels
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _performanceFilter = v ?? 'All'),
                    decoration: const InputDecoration(
                        labelText: 'Performance',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  ),
                ),
                const SizedBox(width: 12),

                // Date range (clickable field)
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    readOnly: true,
                    onTap: _pickDateRange,
                    decoration: InputDecoration(
                      labelText: 'Date Range',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      suffixIcon:
                          Row(mainAxisSize: MainAxisSize.min, children: [
                        if (_dateRange != null)
                          IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(Icons.clear),
                              onPressed: _clearDateRange),
                        IconButton(
                            tooltip: 'Pick range',
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _pickDateRange)
                      ]),
                      hintText: _dateRange == null
                          ? 'All dates'
                          : '${_formatDate(_dateRange!.start)} — ${_formatDate(_dateRange!.end)}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Search
                SizedBox(
                  width: 260,
                  child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Search (test name)', isDense: true),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 12),

                ElevatedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12))),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ---- Tabs ----
  Widget _buildAnalyticsTabs() {
    return Column(children: [
      TabBar(
          controller: _tabController,
          labelColor: AnalyticsColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AnalyticsColors.primary,
          tabs: const [
            Tab(text: 'Performance'),
            Tab(text: 'Question Types'),
            Tab(text: 'Difficulty')
          ]),
      const SizedBox(height: 12),
      SizedBox(
        height: 380,
        child: TabBarView(controller: _tabController, children: [
          _buildPerformanceTab(),
          _buildQuestionTypesTab(),
          _buildDifficultyTab()
        ]),
      )
    ]);
  }

  Widget _buildPerformanceTab() {
    final perfMap = _performanceData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(6),
      child: Column(children: [
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Student Performance Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    dataMap: perfMap.map((k, v) => MapEntry(k, v)),
                    colorList: _performanceColors,
                    chartRadius:
                        MediaQuery.of(context).size.width > 1200 ? 200 : 140,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 28,
                    centerText: "SCORES",
                    legendOptions: const LegendOptions(showLegends: false),
                    chartValuesOptions: const ChartValuesOptions(
                        showChartValueBackground: false,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        decimalPlaces: 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    flex: 1, child: _buildLegend(perfMap, _performanceColors)),
              ])
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
                padding: EdgeInsets.all(18),
                child: SizedBox(
                    height: 140,
                    child: Center(
                        child: Text('Trends / Line chart placeholder')))))
      ]),
    );
  }

  Widget _buildQuestionTypesTab() {
    final qtMap = _questionTypeData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(6),
      child: Column(children: [
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Question Type Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    dataMap: qtMap.map((k, v) => MapEntry(k, v)),
                    colorList: _questionTypeColors,
                    chartRadius:
                        MediaQuery.of(context).size.width > 1200 ? 200 : 140,
                    chartType: ChartType.disc,
                    ringStrokeWidth: 28,
                    centerText: "TYPES",
                    legendOptions: const LegendOptions(showLegends: false),
                    chartValuesOptions: const ChartValuesOptions(
                        showChartValueBackground: false,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        decimalPlaces: 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    flex: 1, child: _buildLegend(qtMap, _questionTypeColors)),
              ])
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Performance by Question Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildQuestionTypeTable(),
            ]),
          ),
        )
      ]),
    );
  }

  Widget _buildDifficultyTab() {
    final diffMap = _difficultyData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(6),
      child: Column(children: [
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Difficulty Level Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    dataMap: diffMap.map((k, v) => MapEntry(k, v)),
                    colorList: _difficultyColors,
                    chartRadius:
                        MediaQuery.of(context).size.width > 1200 ? 200 : 140,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 28,
                    centerText: "LEVELS",
                    legendOptions: const LegendOptions(showLegends: false),
                    chartValuesOptions: const ChartValuesOptions(
                        showChartValueBackground: false,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        decimalPlaces: 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    flex: 1, child: _buildLegend(diffMap, _difficultyColors)),
              ])
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
                padding: EdgeInsets.all(18),
                child: SizedBox(
                    height: 140,
                    child: Center(
                        child: Text('Difficulty analysis placeholder')))))
      ]),
    );
  }

  Widget _buildLegend(Map<String, double> data, List<Color> colors) {
    final entries = data.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.asMap().entries.map((emap) {
          final idx = emap.key;
          final entry = emap.value;
          final sum = data.values.fold<double>(0.0, (a, b) => a + b);
          final percentage = sum == 0 ? 0 : (entry.value.round());
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(entry.key,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
              Text('${percentage}%')
            ]),
          );
        }).toList());
  }

  Widget _buildQuestionTypeTable() {
    final Map<String, int> typePerformance = {};
    for (final t in _filteredTests) {
      typePerformance[t.category] =
          (typePerformance[t.category] ?? 0) + t.score;
    }
    final groupedCount = <String, int>{};
    for (final t in _filteredTests)
      groupedCount[t.category] = (groupedCount[t.category] ?? 0) + 1;

    final rows = ['MCQ', 'Short Answer', 'True/False', 'Essay'].map((k) {
      final total = typePerformance[k] ?? 0;
      final count = groupedCount[k] ?? 0;
      final avg = count == 0 ? 0 : (total / count).round();
      final successRate = avg;
      return DataRow(cells: [
        DataCell(Text(k)),
        DataCell(Text('$avg%')),
        DataCell(Row(children: [
          Expanded(
              child: LinearProgressIndicator(
                  value: (successRate / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  color: _getScoreColor(successRate))),
          const SizedBox(width: 8),
          Text('$successRate%')
        ])),
      ]);
    }).toList();

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: const [
          DataColumn(label: Text('Question Type')),
          DataColumn(label: Text('Average Score')),
          DataColumn(label: Text('Success Rate'))
        ], rows: rows));
  }

  Widget _buildDataTableCard() {
    final filtered = _filteredTests;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Test Records',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              columns: const [
                DataColumn(label: Text('Test Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
              ],
              rows: filtered.map((t) {
                return DataRow(cells: [
                  DataCell(Text(t.name)),
                  DataCell(Text(t.category)),
                  DataCell(Text('${t.score}%')),
                  DataCell(Text(_formatDate(t.date))),
                  DataCell(Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: t.status == 'Passed'
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(t.status,
                        style: TextStyle(
                            color: t.status == 'Passed'
                                ? Colors.green[800]
                                : Colors.red[800])),
                  )),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text('Showing ${filtered.length} of ${_allTests.length} records',
              style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}

class AnalyticsColors {
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFF9C27B0);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const accent = Color(0xFF607D8B);
  static const info = Color(0xFF00BCD4);
}
