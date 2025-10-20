import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _term = 'Fall 2025';
  String _selectedFilter = 'All';
  String _sortBy = 'Recent';
  bool _isLoading = true;

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchController.addListener(_filterCourses);
  }

  void _loadCourses() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    setState(() {
      _courses = _getSampleCourses();
      _filteredCourses = _courses;
      _isLoading = false;
    });
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _courses.where((course) {
        final matchesSearch = course['name'].toLowerCase().contains(query) ||
            course['code'].toLowerCase().contains(query);
        final matchesFilter =
            _selectedFilter == 'All' || course['term'] == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getSampleCourses() {
    return [
      {
        'id': '1',
        'name': 'Calculus I',
        'code': 'MATH-101',
        'term': 'Fall 2025',
        'studentCount': 45,
        'description': 'Introduction to differential and integral calculus',
        'color': CoursesColors.primary,
        'progress': 75,
        'assignmentsDue': 3,
        'recentActivity': '2 new submissions',
        'instructor': 'Dr. Sarah Johnson',
      },
      {
        'id': '2',
        'name': 'Physics Fundamentals',
        'code': 'PHYS-201',
        'term': 'Fall 2025',
        'studentCount': 32,
        'description': 'Classical mechanics and thermodynamics',
        'color': CoursesColors.secondary,
        'progress': 60,
        'assignmentsDue': 1,
        'recentActivity': '5 assignments graded',
        'instructor': 'Dr. Sarah Johnson',
      },
      {
        'id': '3',
        'name': 'Organic Chemistry',
        'code': 'CHEM-301',
        'term': 'Spring 2025',
        'studentCount': 28,
        'description': 'Structure and reactions of organic compounds',
        'color': CoursesColors.accent,
        'progress': 90,
        'assignmentsDue': 0,
        'recentActivity': 'All assignments completed',
        'instructor': 'Dr. Sarah Johnson',
      },
      {
        'id': '4',
        'name': 'World History',
        'code': 'HIST-101',
        'term': 'Fall 2025',
        'studentCount': 38,
        'description': 'Survey of world civilizations',
        'color': CoursesColors.warning,
        'progress': 45,
        'assignmentsDue': 2,
        'recentActivity': '1 new discussion post',
        'instructor': 'Dr. Sarah Johnson',
      },
      {
        'id': '5',
        'name': 'English Literature',
        'code': 'ENGL-202',
        'term': 'Spring 2025',
        'studentCount': 25,
        'description': 'British literature from 1800 to present',
        'color': CoursesColors.info,
        'progress': 80,
        'assignmentsDue': 1,
        'recentActivity': '3 essays to grade',
        'instructor': 'Dr. Sarah Johnson',
      },
      {
        'id': '6',
        'name': 'Computer Science I',
        'code': 'CS-101',
        'term': 'Summer 2025',
        'studentCount': 52,
        'description': 'Introduction to programming and algorithms',
        'color': CoursesColors.success,
        'progress': 30,
        'assignmentsDue': 4,
        'recentActivity': 'Lab assignments submitted',
        'instructor': 'Dr. Sarah Johnson',
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _studentsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showNewCourseDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.add_circle_outline, color: CoursesColors.primary),
                SizedBox(width: 8),
                Text('Create New Course'),
              ],
            ),
            content: Form(
              key: _formKey,
              child: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Course Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: requiredField(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _term,
                      decoration: const InputDecoration(
                        labelText: 'Term',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Fall 2025',
                        'Spring 2025',
                        'Summer 2025',
                        'Winter 2025'
                      ]
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _term = v ?? _term),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _studentsController,
                      decoration: const InputDecoration(
                        labelText: 'Student Count',
                        border: OutlineInputBorder(),
                      ),
                      validator: integerValidator,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Course Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop({
                      'name': _nameController.text.trim(),
                      'term': _term,
                      'students': int.tryParse(_studentsController.text.trim()),
                      'description': _descriptionController.text.trim(),
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoursesColors.primary,
                ),
                child: const Text('Create Course',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      final name = result['name'] as String;
      final term = result['term'] as String;
      final students = result['students'] as int?;
      final description = result['description'] as String;

      if (!mounted) return;
      final scaffold = ScaffoldMessenger.of(context);
      scaffold
          .showSnackBar(const SnackBar(content: Text('Creating course...')));

      // FIXED: Removed the 'code' parameter completely
      final ok = await ApiService.instance.createCourse(
        name: name,
        term: term,
        studentCount: students,
        description: description,
        code: '',
      );

      if (!mounted) return;
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(
        content: Text(
            ok ? 'Course created successfully' : 'Failed to create course'),
        backgroundColor: ok ? CoursesColors.success : CoursesColors.error,
      ));

      if (ok) {
        _nameController.clear();
        _studentsController.clear();
        _descriptionController.clear();
        _loadCourses(); // Refresh the course list
      }
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
                  const Text('Filter Courses',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),

                  // Term Filter
                  _buildFilterSection(
                      'Term',
                      [
                        'All',
                        'Fall 2025',
                        'Spring 2025',
                        'Summer 2025',
                        'Winter 2025'
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
                              _selectedFilter = 'All';
                              _sortBy = 'Recent';
                            });
                            Navigator.pop(context);
                            _filterCourses();
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _filterCourses();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CoursesColors.primary,
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
                  isSelected ? CoursesColors.primary.withOpacity(0.1) : null,
              labelStyle: TextStyle(
                color: isSelected ? CoursesColors.primary : Colors.grey[700],
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
          items: ['Recent', 'Most Students', 'Course Name', 'Progress']
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

                    // Analytics Section - FIXED: Added scrollable wrap
                    SizedBox(
                      height: 100, // Fixed height to prevent overflow
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildAnalyticsSection(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search and Actions Bar
                    _buildSearchSection(),
                    const SizedBox(height: 24),

                    // Courses Grid
                    _buildCoursesSection(isWide),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewCourseDialog,
        backgroundColor: CoursesColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Row(
      children: [
        Icon(Icons.school_outlined, size: 32, color: CoursesColors.primary),
        SizedBox(width: 12),
        Text(
          'My Courses',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    final totalCourses = _courses.length;
    final totalStudents = _courses.fold(
        0, (sum, course) => sum + (course['studentCount'] as int));
    final activeCourses =
        _courses.where((course) => course['term'] == 'Fall 2025').length;
    final avgProgress = _courses.isNotEmpty
        ? _courses.fold(0, (sum, course) => sum + (course['progress'] as int)) /
            _courses.length
        : 0;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildAnalyticsCard('Total Courses', '$totalCourses', Icons.school,
            CoursesColors.primary),
        _buildAnalyticsCard('Total Students', '$totalStudents', Icons.people,
            CoursesColors.secondary),
        _buildAnalyticsCard('Active Courses', '$activeCourses',
            Icons.play_lesson, CoursesColors.success),
        _buildAnalyticsCard('Avg Progress', '${avgProgress.round()}%',
            Icons.trending_up, CoursesColors.warning),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 180, // Fixed width for consistent sizing
      child: Card(
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
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
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
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showNewCourseDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Course'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoursesColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesSection(bool isWide) {
    if (_isLoading) {
      return _buildLoadingSkeleton(isWide);
    }

    if (_filteredCourses.isEmpty) {
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
        itemCount: _filteredCourses.length,
        itemBuilder: (context, index) =>
            _buildCourseCard(_filteredCourses[index]),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with course code and term
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: course['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course['code'],
                      style: TextStyle(
                        color: course['color'],
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course['term'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Course name
            Text(
              course['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Course description
            Expanded(
              child: Text(
                course['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),

            // Progress and stats
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${course['studentCount']} students',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.assignment_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${course['assignmentsDue']} due',
                      style: TextStyle(
                        fontSize: 12,
                        color: (course['assignmentsDue'] as int) > 0
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (course['progress'] as int) / 100,
                  backgroundColor: Colors.grey[200],
                  color: course['color'],
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${course['progress']}% complete',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Flexible(
                      child: Text(
                        course['recentActivity'],
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No courses found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Try adjusting your search or create your first course',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showNewCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CoursesColors.primary,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
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
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoursesColors {
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFF9C27B0);
  static const accent = Color(0xFF3F51B5);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF00BCD4);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
}
