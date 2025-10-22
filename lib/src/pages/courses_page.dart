import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';
// import '../services/api_service.dart'; // Uncomment if you will call backend API
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

    // Simulate API call delay. Replace with your real API call if needed.
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _courses = _getSampleCourses();
      _applySortAndFilter();
      _isLoading = false;
    });
  }

  void _applySortAndFilter() {
    // filter
    final query = _searchController.text.toLowerCase();
    final filtered = _courses.where((course) {
      final matchesSearch = course['name'].toLowerCase().contains(query) ||
          course['code'].toLowerCase().contains(query);
      final matchesFilter =
          _selectedFilter == 'All' || course['term'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    // sort
    switch (_sortBy) {
      case 'Most Students':
        filtered.sort((a, b) =>
            (b['studentCount'] as int).compareTo(a['studentCount'] as int));
        break;
      case 'Course Name':
        filtered.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case 'Progress':
        filtered.sort(
            (a, b) => (b['progress'] as int).compareTo(a['progress'] as int));
        break;
      case 'Recent':
      default:
        filtered.sort((a, b) =>
            (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
    }

    _filteredCourses = filtered;
  }

  void _filterCourses() {
    setState(() {
      _applySortAndFilter();
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
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
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
        'createdAt': DateTime.now().subtract(const Duration(days: 8)),
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
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
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
        'createdAt': DateTime.now().subtract(const Duration(days: 12)),
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
        'createdAt': DateTime.now().subtract(const Duration(days: 18)),
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
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
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

  // -------------------------------
  // CREATE COURSE DIALOG
  // -------------------------------
  Future<void> _showNewCourseDialog() async {
    // Clear controllers before showing
    _nameController.clear();
    _studentsController.clear();
    _descriptionController.clear();
    _term = 'Fall 2025';

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
                width: 520,
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _studentsController,
                      decoration: const InputDecoration(
                        labelText: 'Student Count',
                        border: OutlineInputBorder(),
                      ),
                      validator: integerValidator,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
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
                      'students':
                          int.tryParse(_studentsController.text.trim()) ?? 0,
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
      // Optionally call API: await ApiService.instance.createCourse(...)
      setState(() {
        _courses.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': result['name'],
          'term': result['term'],
          'studentCount': result['students'],
          'description': result['description'],
          'code': 'NEW-${_courses.length + 1}',
          'progress': 0,
          'assignmentsDue': 0,
          'recentActivity': 'Course created',
          'color': CoursesColors.primary,
          'instructor': 'You',
          'createdAt': DateTime.now(),
        });
        _applySortAndFilter();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully!')),
      );
    }
  }

  // -------------------------------
  // EDIT COURSE (uses same form UI)
  // -------------------------------
  void _editCourse(Map<String, dynamic> course) async {
    // load values into controllers
    _nameController.text = course['name'] ?? '';
    _studentsController.text = (course['studentCount'] ?? 0).toString();
    _descriptionController.text = course['description'] ?? '';
    _term = course['term'] ?? 'Fall 2025';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Edit Course'),
          content: Form(
            key: _formKey,
            child: SizedBox(
              width: 520,
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
                  const SizedBox(height: 12),
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
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _term = v ?? _term),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _studentsController,
                    decoration: const InputDecoration(
                      labelText: 'Student Count',
                      border: OutlineInputBorder(),
                    ),
                    validator: integerValidator,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
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
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop({
                    'name': _nameController.text.trim(),
                    'term': _term,
                    'studentCount':
                        int.tryParse(_studentsController.text.trim()) ?? 0,
                    'description': _descriptionController.text.trim(),
                  });
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      }),
    );

    if (result != null) {
      // TODO: Call API to update course on backend, e.g.
      // final ok = await ApiService.instance.updateCourse(course['id'], ...);
      // if (ok) { ... }

      setState(() {
        final index = _courses.indexWhere((c) => c['id'] == course['id']);
        if (index != -1) {
          _courses[index] = {
            ..._courses[index],
            'name': result['name'],
            'term': result['term'],
            'studentCount': result['studentCount'],
            'description': result['description'],
          };
          _applySortAndFilter();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully!')),
      );
    }
  }

  // -------------------------------
  // DELETE COURSE
  // -------------------------------
  void _deleteCourse(Map<String, dynamic> course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course['name']}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: call API to delete, e.g. await ApiService.instance.deleteCourse(course['id']);
      setState(() {
        _courses.removeWhere((c) => c['id'] == course['id']);
        _applySortAndFilter();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${course['name']}')),
      );
    }
  }

  // -------------------------------
  // FILTER / SORT UI
  // -------------------------------
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // use local state with StatefulBuilder to allow immediate UI changes
        String tmpFilter = _selectedFilter;
        String tmpSort = _sortBy;
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Filter Courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildFilterSection(
                'Term',
                [
                  'All',
                  'Fall 2025',
                  'Spring 2025',
                  'Summer 2025',
                  'Winter 2025'
                ],
                tmpFilter,
                (v) => setState(() => tmpFilter = v),
              ),
              const SizedBox(height: 12),
              _buildSortOptions(tmpSort, (v) => setState(() => tmpSort = v!)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        tmpFilter = 'All';
                        tmpSort = 'Recent';
                      });
                    },
                    child: const Text('Reset Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedFilter = tmpFilter;
                        _sortBy = tmpSort;
                        _applySortAndFilter();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: CoursesColors.primary),
                    child: const Text('Apply Filters',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ]),
          );
        });
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
                  color: isSelected ? CoursesColors.primary : Colors.grey[700]),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions(String current, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: current,
          items: ['Recent', 'Most Students', 'Course Name', 'Progress']
              .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  // -------------------------------
  // ANALYTICS
  // -------------------------------
  Widget _buildAnalyticsSection() {
    final totalCourses = _courses.length;
    final totalStudents =
        _courses.fold(0, (sum, c) => sum + (c['studentCount'] as int));
    final activeCourses =
        _courses.where((c) => c['term'] == 'Fall 2025').length;
    final avgProgress = _courses.isNotEmpty
        ? _courses.fold(0, (sum, c) => sum + (c['progress'] as int)) /
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
      width: 180,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // UI
  // -------------------------------
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 18),

                      // Analytics (make horizontally scrollable to avoid overflow)
                      SizedBox(
                        height: 110,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildAnalyticsSection(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Search + Actions
                      _buildSearchSection(),
                      const SizedBox(height: 18),

                      // Courses grid/list
                      Expanded(child: _buildCoursesSection(isWide)),
                    ]),
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
        Text('My Courses',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
              onPressed: _showFilters,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filters')),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _showNewCourseDialog,
            icon: const Icon(Icons.add),
            label: const Text('New Course'),
            style: ElevatedButton.styleFrom(
                backgroundColor: CoursesColors.primary),
          ),
        ]),
      ),
    );
  }

  Widget _buildCoursesSection(bool isWide) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredCourses.isEmpty) {
      return _buildEmptyState();
    }

    // grid
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) =>
          _buildCourseCard(_filteredCourses[index]),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // header row: code, term, actions
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: course['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(course['code'],
                      style: TextStyle(
                          color: course['color'],
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(course['term'],
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ),
              ]),
            ),
            Row(children: [
              IconButton(
                  icon: const Icon(Icons.edit,
                      size: 18, color: Colors.blueAccent),
                  onPressed: () => _editCourse(course)),
              IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.redAccent),
                  onPressed: () => _deleteCourse(course)),
            ]),
          ]),
          const SizedBox(height: 10),

          Text(course['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),

          Expanded(
            child: Text(course['description'] ?? '',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 10),

          LinearProgressIndicator(
              value: (course['progress'] as int) / 100,
              backgroundColor: Colors.grey[200],
              color: course['color']),
          const SizedBox(height: 6),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${course['studentCount']} students',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Row(children: [
              const Icon(Icons.assignment_outlined,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text('${course['assignmentsDue']} due',
                  style: TextStyle(
                      fontSize: 11,
                      color: (course['assignmentsDue'] as int) > 0
                          ? Colors.orange
                          : Colors.grey)),
            ])
          ])
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.school_outlined, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 12),
        const Text('No courses found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text('Try adjusting filters or create a new course',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey))),
        const SizedBox(height: 12),
        ElevatedButton.icon(
            onPressed: _showNewCourseDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Course'),
            style: ElevatedButton.styleFrom(
                backgroundColor: CoursesColors.primary)),
      ]),
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
