import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeFilter = 0; // 0: Weekly, 1: Monthly, 2: Quarterly

  // Pie Chart Data
  final Map<String, double> _performanceData = {
    "Excellent (90-100%)": 25,
    "Good (75-89%)": 45,
    "Average (60-74%)": 20,
    "Needs Improvement (<60%)": 10,
  };

  final Map<String, double> _questionTypeData = {
    "MCQ": 60,
    "Short Answer": 20,
    "True/False": 15,
    "Essay": 5,
  };

  final Map<String, double> _difficultyData = {
    "Easy": 40,
    "Medium": 35,
    "Hard": 25,
  };

  final List<Color> _performanceColors = [
    Colors.green,
    Colors.lightGreen,
    Colors.orange,
    Colors.red,
  ];

  final List<Color> _questionTypeColors = [
    Colors.blue,
    Colors.purple,
    Colors.amber,
    Colors.deepOrange,
  ];

  final List<Color> _difficultyColors = [
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

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
            if (isWide) const Expanded(flex: 2, child: SideBar()),
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    const SizedBox(height: 24),

                    // Key Metrics Section
                    _buildMetricsSection(),
                    const SizedBox(height: 24),

                    // Time Filter Tabs
                    _buildTimeFilterSection(),
                    const SizedBox(height: 24),

                    // Analytics Tabs
                    _buildAnalyticsTabs(),
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
        Text(
          'Analytics Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildMetricCard(
          'Average Score',
          '78%',
          Icons.bar_chart,
          AnalyticsColors.primary,
          trend: 5.2,
        ),
        _buildMetricCard(
          'Completion Rate',
          '92%',
          Icons.check_circle,
          AnalyticsColors.success,
          trend: 2.1,
        ),
        _buildMetricCard(
          'Avg Time Spent',
          '18m',
          Icons.timer,
          AnalyticsColors.warning,
          trend: -1.3,
        ),
        _buildMetricCard(
          'Total Tests Taken',
          '156',
          Icons.assignment,
          AnalyticsColors.accent,
          trend: 12.5,
        ),
        _buildMetricCard(
          'Student Engagement',
          '88%',
          Icons.people,
          AnalyticsColors.info,
          trend: 3.7,
        ),
        _buildMetricCard(
          'Questions Answered',
          '2,847',
          Icons.quiz,
          AnalyticsColors.secondary,
          trend: 8.9,
        ),
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
                if (trend != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        trend > 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: trend > 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trend.abs()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: trend > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Time Period:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildTimeFilterChip('Weekly', 0),
                _buildTimeFilterChip('Monthly', 1),
                _buildTimeFilterChip('Quarterly', 2),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: _exportAnalytics,
              tooltip: 'Export Report',
            ),
          ],
        ),
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
        color: isSelected ? AnalyticsColors.primary : Colors.grey[700],
      ),
    );
  }

  Widget _buildAnalyticsTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AnalyticsColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AnalyticsColors.primary,
            tabs: const [
              Tab(text: 'Performance'),
              Tab(text: 'Question Types'),
              Tab(text: 'Difficulty'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPerformanceTab(),
                _buildQuestionTypesTab(),
                _buildDifficultyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Performance Pie Chart
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Performance Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PieChart(
                          dataMap: _performanceData,
                          colorList: _performanceColors,
                          chartRadius: 150,
                          chartType: ChartType.ring,
                          ringStrokeWidth:
                              32, // Fixed: Added required parameter
                          centerText: "SCORES",
                          centerTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AnalyticsColors.primary,
                          ),
                          legendOptions: const LegendOptions(
                            showLegends: false,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: false,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child:
                            _buildLegend(_performanceData, _performanceColors),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Performance Trends
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Trends',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Line chart showing performance trends over time would appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypesTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Question Types Pie Chart
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question Type Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PieChart(
                          dataMap: _questionTypeData,
                          colorList: _questionTypeColors,
                          chartRadius: 150,
                          chartType: ChartType.disc,
                          ringStrokeWidth:
                              32, // Fixed: Added required parameter even for disc type
                          centerText: "TYPES",
                          centerTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AnalyticsColors.primary,
                          ),
                          legendOptions: const LegendOptions(
                            showLegends: false,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: false,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildLegend(
                            _questionTypeData, _questionTypeColors),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Type Performance Table
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance by Question Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionTypeTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Difficulty Distribution Pie Chart
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Difficulty Level Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PieChart(
                          dataMap: _difficultyData,
                          colorList: _difficultyColors,
                          chartRadius: 150,
                          chartType: ChartType.ring,
                          ringStrokeWidth:
                              32, // Fixed: Added required parameter
                          centerText: "LEVELS",
                          centerTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AnalyticsColors.primary,
                          ),
                          legendOptions: const LegendOptions(
                            showLegends: false,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: false,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildLegend(_difficultyData, _difficultyColors),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Difficulty Analysis
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance by Difficulty Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Bar chart showing average scores by difficulty level would appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Map<String, double> data, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final entryData = entry.value;
        final percentage =
            ((entryData.value / data.values.reduce((a, b) => a + b)) * 100)
                .round();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entryData.key,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percentage%',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionTypeTable() {
    final typePerformance = {
      'MCQ': 82,
      'Short Answer': 75,
      'True/False': 88,
      'Essay': 65,
    };

    return DataTable(
      columns: const [
        DataColumn(label: Text('Question Type')),
        DataColumn(label: Text('Average Score')),
        DataColumn(label: Text('Success Rate')),
      ],
      rows: typePerformance.entries.map((entry) {
        return DataRow(cells: [
          DataCell(Text(entry.key)),
          DataCell(Text('${entry.value}%')),
          DataCell(
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor: Colors.grey[200],
                    color: _getScoreColor(entry.value),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${entry.value}%'),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting analytics report...')),
    );
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
