import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';

class GradebookPage extends StatefulWidget {
  const GradebookPage({super.key});

  @override
  State<GradebookPage> createState() => _GradebookPageState();
}

class _GradebookPageState extends State<GradebookPage> {
  String selectedClass = "Math 101";
  String selectedAssignment = "All Assignments";
  String _selectedFilter = "All Students";
  String _sortBy = "Name";
  final TextEditingController _searchController = TextEditingController();

  final List<String> classes = [
    "Math 101",
    "Physics 202",
    "Chemistry 303",
    "Biology 104",
    "English 205"
  ];
  final List<String> assignments = [
    "All Assignments",
    "Midterm Exam",
    "Final Project",
    "Quiz 1",
    "Homework 3"
  ];

  final List<Map<String, dynamic>> students = [
    {
      "id": "1",
      "name": "Alice Johnson",
      "email": "alice@school.edu",
      "score": 92,
      "submitted": "Sep 20",
      "status": "Graded",
      "trend": "up",
      "assignments": [
        {
          "name": "Midterm Exam",
          "score": 92,
          "maxScore": 100,
          "date": "Sep 20"
        },
        {"name": "Quiz 1", "score": 88, "maxScore": 100, "date": "Aug 15"},
        {"name": "Homework 3", "score": 95, "maxScore": 100, "date": "Sep 10"},
      ]
    },
    {
      "id": "2",
      "name": "Bob Smith",
      "email": "bob@school.edu",
      "score": 87,
      "submitted": "Sep 21",
      "status": "Graded",
      "trend": "stable",
      "assignments": [
        {
          "name": "Midterm Exam",
          "score": 87,
          "maxScore": 100,
          "date": "Sep 21"
        },
        {"name": "Quiz 1", "score": 85, "maxScore": 100, "date": "Aug 16"},
        {"name": "Homework 3", "score": 89, "maxScore": 100, "date": "Sep 11"},
      ]
    },
    {
      "id": "3",
      "name": "Charlie Brown",
      "email": "charlie@school.edu",
      "score": 80,
      "submitted": "Sep 22",
      "status": "Needs Review",
      "trend": "down",
      "assignments": [
        {
          "name": "Midterm Exam",
          "score": 80,
          "maxScore": 100,
          "date": "Sep 22"
        },
        {"name": "Quiz 1", "score": 82, "maxScore": 100, "date": "Aug 17"},
        {"name": "Homework 3", "score": 78, "maxScore": 100, "date": "Sep 12"},
      ]
    },
    {
      "id": "4",
      "name": "Diana Prince",
      "email": "diana@school.edu",
      "score": 95,
      "submitted": "Sep 23",
      "status": "Graded",
      "trend": "up",
      "assignments": [
        {
          "name": "Midterm Exam",
          "score": 95,
          "maxScore": 100,
          "date": "Sep 23"
        },
        {"name": "Quiz 1", "score": 92, "maxScore": 100, "date": "Aug 18"},
        {"name": "Homework 3", "score": 98, "maxScore": 100, "date": "Sep 13"},
      ]
    },
    {
      "id": "5",
      "name": "Ethan Hunt",
      "email": "ethan@school.edu",
      "score": 78,
      "submitted": "Sep 24",
      "status": "Not Submitted",
      "trend": "down",
      "assignments": [
        {"name": "Quiz 1", "score": 75, "maxScore": 100, "date": "Aug 19"},
        {"name": "Homework 3", "score": 81, "maxScore": 100, "date": "Sep 14"},
      ]
    },
    {
      "id": "6",
      "name": "Fiona Gallagher",
      "email": "fiona@school.edu",
      "score": 91,
      "submitted": "Sep 25",
      "status": "Graded",
      "trend": "stable",
      "assignments": [
        {
          "name": "Midterm Exam",
          "score": 91,
          "maxScore": 100,
          "date": "Sep 25"
        },
        {"name": "Quiz 1", "score": 89, "maxScore": 100, "date": "Aug 20"},
        {"name": "Homework 3", "score": 93, "maxScore": 100, "date": "Sep 15"},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredStudents {
    var filtered = students
        .where((s) =>
            s["name"]
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            s["email"]
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();

    // Apply status filter
    if (_selectedFilter != "All Students") {
      filtered = filtered.where((s) => s["status"] == _selectedFilter).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case "Name":
          return a["name"].compareTo(b["name"]);
        case "Score":
          return b["score"].compareTo(a["score"]);
        case "Recent":
          return b["submitted"].compareTo(a["submitted"]);
        default:
          return 0;
      }
    });

    return filtered;
  }

  double get classAverage {
    if (students.isEmpty) return 0;
    final gradedStudents = students.where((s) => s["status"] == "Graded");
    if (gradedStudents.isEmpty) return 0;
    return gradedStudents
            .map((s) => s["score"] as int)
            .reduce((a, b) => a + b) /
        gradedStudents.length;
  }

  int get submittedCount {
    return students.where((s) => s["status"] != "Not Submitted").length;
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
                  const Text('Filter & Sort',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),

                  // Status Filter
                  _buildFilterSection(
                      'Status',
                      [
                        'All Students',
                        'Graded',
                        'Needs Review',
                        'Not Submitted'
                      ],
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
                              _selectedFilter = 'All Students';
                              _sortBy = 'Name';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GradebookColors.primary,
                          ),
                          child: const Text('Apply',
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
                  isSelected ? GradebookColors.primary.withOpacity(0.1) : null,
              labelStyle: TextStyle(
                color: isSelected ? GradebookColors.primary : Colors.grey[700],
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
          items: ['Name', 'Score', 'Recent']
              .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
              .toList(),
          onChanged: (v) => setState(() => _sortBy = v ?? 'Name'),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: GradebookColors.primary.withOpacity(0.1),
              child: Text(student["name"][0],
                  style: TextStyle(color: GradebookColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student["name"],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(student["email"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStudentStatCard(student),
              const SizedBox(height: 16),
              const Text('Assignment History',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...student["assignments"]
                  .map<Widget>((assignment) => _buildAssignmentRow(assignment))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to grade assignment
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GradebookColors.primary,
            ),
            child: const Text('Grade Assignment',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStatCard(Map<String, dynamic> student) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                'Current Score', '${student["score"]}%', Icons.grade),
            _buildStatItem(
                'Status', student["status"], _getStatusIcon(student["status"])),
            _buildStatItem('Trend', student["trend"].toString().toUpperCase(),
                _getTrendIcon(student["trend"])),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: GradebookColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAssignmentRow(Map<String, dynamic> assignment) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: GradebookColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.assignment, size: 20, color: GradebookColors.primary),
      ),
      title: Text(assignment["name"],
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text("Submitted: ${assignment["date"]}"),
      trailing: Chip(
        label: Text("${assignment["score"]}/${assignment["maxScore"]}"),
        backgroundColor: _getScoreColor(assignment["score"]).withOpacity(0.1),
        labelStyle: TextStyle(color: _getScoreColor(assignment["score"])),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Graded":
        return Icons.check_circle;
      case "Needs Review":
        return Icons.warning;
      case "Not Submitted":
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case "up":
        return Icons.trending_up;
      case "down":
        return Icons.trending_down;
      case "stable":
        return Icons.trending_flat;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
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

                    // Analytics Section
                    _buildAnalyticsSection(),
                    const SizedBox(height: 24),

                    // Controls Section
                    _buildControlsSection(),
                    const SizedBox(height: 24),

                    // Gradebook Table
                    _buildGradebookTable(),
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
        Icon(Icons.grade_outlined, size: 32, color: GradebookColors.primary),
        SizedBox(width: 12),
        Text(
          'Gradebook',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildAnalyticsCard('Class Average', '${classAverage.round()}%',
            Icons.assessment, GradebookColors.primary),
        _buildAnalyticsCard('Total Students', '${students.length}',
            Icons.people, GradebookColors.secondary),
        _buildAnalyticsCard('Submitted', '$submittedCount/${students.length}',
            Icons.assignment_turned_in, GradebookColors.success),
        _buildAnalyticsCard(
            'Needs Review',
            '${students.where((s) => s["status"] == "Needs Review").length}',
            Icons.warning,
            GradebookColors.warning),
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

  Widget _buildControlsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search students...',
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(),
                    ),
                    items: classes
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedClass = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAssignment,
                    decoration: const InputDecoration(
                      labelText: 'Assignment',
                      border: OutlineInputBorder(),
                    ),
                    items: assignments
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedAssignment = val!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradebookTable() {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Table Header
              const Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('Student',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 1,
                      child: Text('Score',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 1,
                      child: Text('Status',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 1,
                      child: Text('Submitted',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 1,
                      child: Text('Trend',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 1,
                      child: Text('Actions',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Table Content
              Expanded(
                child: ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _buildStudentRow(student);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: GradebookColors.primary.withOpacity(0.1),
                  child: Text(
                    student["name"][0],
                    style:
                        TextStyle(fontSize: 12, color: GradebookColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student["name"],
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(student["email"],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Chip(
              label: Text("${student["score"]}%"),
              backgroundColor:
                  _getScoreColor(student["score"]).withOpacity(0.1),
              labelStyle: TextStyle(
                color: _getScoreColor(student["score"]),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(student["status"]).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                student["status"],
                style: TextStyle(
                  color: _getStatusColor(student["status"]),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(student["submitted"],
                  style: const TextStyle(fontSize: 12))),
          Expanded(
            flex: 1,
            child: Icon(
              _getTrendIcon(student["trend"]),
              color: _getTrendColor(student["trend"]),
              size: 20,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 18),
                  color: GradebookColors.primary,
                  onPressed: () => _showStudentDetails(student),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: Colors.orange,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.email, size: 18),
                  color: Colors.blue,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Graded":
        return Colors.green;
      case "Needs Review":
        return Colors.orange;
      case "Not Submitted":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case "up":
        return Colors.green;
      case "down":
        return Colors.red;
      case "stable":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class GradebookColors {
  static const primary = Color(0xFF9C27B0);
  static const secondary = Color(0xFF673AB7);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
}
