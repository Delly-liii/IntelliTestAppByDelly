import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _viewMode = 'Month'; // Month, Week, Day
  String _selectedFilter = 'All Events';

  final List<Map<String, dynamic>> _events = [
    {
      'id': '1',
      'title': 'Algebra Quiz',
      'course': 'Math 101',
      'date': DateTime(2025, 9, 25, 14, 0),
      'duration': 60,
      'type': 'quiz',
      'color': CalendarColors.primary,
      'students': 45,
      'description': 'Chapter 3-4 Polynomials and Equations',
    },
    {
      'id': '2',
      'title': 'Cell Biology Test',
      'course': 'Biology 201',
      'date': DateTime(2025, 9, 28, 10, 0),
      'duration': 90,
      'type': 'test',
      'color': CalendarColors.secondary,
      'students': 32,
      'description': 'Cellular structure and function',
    },
    {
      'id': '3',
      'title': 'Literature Essay Due',
      'course': 'English 301',
      'date': DateTime(2025, 9, 30, 23, 59),
      'duration': 0,
      'type': 'assignment',
      'color': CalendarColors.accent,
      'students': 28,
      'description': 'Analysis of Shakespearean sonnets',
    },
    {
      'id': '4',
      'title': 'Physics Lab Report',
      'course': 'Physics 202',
      'date': DateTime(2025, 10, 2, 16, 0),
      'duration': 0,
      'type': 'assignment',
      'color': CalendarColors.warning,
      'students': 38,
      'description': 'Newtonian mechanics lab analysis',
    },
    {
      'id': '5',
      'title': 'Midterm Exam',
      'course': 'Chemistry 101',
      'date': DateTime(2025, 10, 5, 9, 0),
      'duration': 120,
      'type': 'exam',
      'color': CalendarColors.error,
      'students': 52,
      'description': 'Chapters 1-6 comprehensive exam',
    },
    {
      'id': '6',
      'title': 'Department Meeting',
      'course': 'Faculty',
      'date': DateTime(2025, 9, 26, 15, 0),
      'duration': 60,
      'type': 'meeting',
      'color': CalendarColors.info,
      'students': 0,
      'description': 'Monthly faculty development session',
    },
  ];

  List<Map<String, dynamic>> get _upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) => event['date'].isAfter(now)).toList()
      ..sort((a, b) => a['date'].compareTo(b['date']));
  }

  List<Map<String, dynamic>> get _todaysEvents {
    final today = DateTime.now();
    return _events.where((event) {
      final eventDate = event['date'];
      return eventDate.year == today.year &&
          eventDate.month == today.month &&
          eventDate.day == today.day;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedFilter == 'All Events') return _events;
    return _events
        .where((event) => event['type'] == _selectedFilter.toLowerCase())
        .toList();
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: event['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getEventIcon(event['type']), color: event['color']),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event['title'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventDetailRow(Icons.school, event['course']),
              _buildEventDetailRow(
                  Icons.calendar_today, _formatDateTime(event['date'])),
              if (event['duration'] > 0)
                _buildEventDetailRow(
                    Icons.timer, '${event['duration']} minutes'),
              _buildEventDetailRow(
                  Icons.people, '${event['students']} students'),
              const SizedBox(height: 12),
              Text(
                event['description'],
                style: const TextStyle(color: Colors.grey),
              ),
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
              // Edit event functionality
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: event['color'],
            ),
            child:
                const Text('Edit Event', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz;
      case 'test':
        return Icons.assignment;
      case 'exam':
        return Icons.assignment_turned_in;
      case 'assignment':
        return Icons.description;
      case 'meeting':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${_getWeekday(date.weekday)}, ${_getMonth(date.month)} ${date.day}, ${date.year} at ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
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
                  const Text('Filter Events',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),

                  // Event Type Filter
                  _buildFilterSection(
                      'Event Type',
                      [
                        'All Events',
                        'Quiz',
                        'Test',
                        'Exam',
                        'Assignment',
                        'Meeting'
                      ],
                      _selectedFilter, (value) {
                    setState(() => _selectedFilter = value);
                  }),

                  const SizedBox(height: 20),

                  // View Mode
                  _buildViewModeSection(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'All Events';
                              _viewMode = 'Month';
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
                            backgroundColor: CalendarColors.primary,
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
                  isSelected ? CalendarColors.primary.withOpacity(0.1) : null,
              labelStyle: TextStyle(
                color: isSelected ? CalendarColors.primary : Colors.grey[700],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildViewModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('View Mode', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildViewModeChip('Month'),
            _buildViewModeChip('Week'),
            _buildViewModeChip('Day'),
          ],
        ),
      ],
    );
  }

  Widget _buildViewModeChip(String mode) {
    final isSelected = _viewMode == mode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(mode),
        selected: isSelected,
        onSelected: (_) => setState(() => _viewMode = mode),
        selectedColor: CalendarColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? CalendarColors.primary : Colors.grey[700],
        ),
      ),
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

                    // Controls Section
                    _buildControlsSection(),
                    const SizedBox(height: 24),

                    // Main Content - FIXED: Proper responsive layout
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return constraints.maxWidth > 800
                              ? _buildDesktopLayout()
                              : _buildMobileLayout();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new event functionality
        },
        backgroundColor: CalendarColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar View - FIXED: Made scrollable horizontally
        Expanded(
          flex: 2,
          child: _buildCalendarSection(),
        ),
        const SizedBox(width: 16),

        // Sidebar - FIXED: Proper width constraint
        SizedBox(
          width: 320,
          child: _buildSidebarSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendarSection(),
          const SizedBox(height: 16),
          _buildSidebarSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Row(
      children: [
        Icon(Icons.calendar_month_outlined,
            size: 32, color: CalendarColors.primary),
        SizedBox(width: 12),
        Text(
          'Calendar',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ],
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
            // View Mode Chips
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                children: [
                  _buildViewModeChip('Month'),
                  _buildViewModeChip('Week'),
                  _buildViewModeChip('Day'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) => setState(() {}),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar Header - FIXED: Made horizontally scrollable
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 400,
              maxHeight: 500,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Month/Year Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _selectedDate = DateTime(
                              _selectedDate.year, _selectedDate.month - 1);
                        }),
                      ),
                      Text(
                        '${_getMonth(_selectedDate.month)} ${_selectedDate.year}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _selectedDate = DateTime(
                              _selectedDate.year, _selectedDate.month + 1);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Weekday Headers
                  _buildWeekdayHeaders(),
                  const SizedBox(height: 8),

                  // Calendar Grid - FIXED: Made horizontally scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 700, // Minimum width for calendar
                        ),
                        child: _buildCalendarGrid(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Today's Events
        if (_todaysEvents.isNotEmpty) ...[
          const Text(
            "Today's Events",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView(
              children:
                  _todaysEvents.map((event) => _buildEventCard(event)).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: weekdays
          .map((day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final startingWeekday = firstDay.weekday;
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    return Container(
      width: 700, // Fixed width for calendar grid
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0, // Square cells
        ),
        itemCount: 42, // 6 weeks
        itemBuilder: (context, index) {
          final day = index - startingWeekday + 2;
          final isCurrentMonth = day > 0 && day <= daysInMonth;
          final isToday = isCurrentMonth &&
              day == DateTime.now().day &&
              _selectedDate.month == DateTime.now().month &&
              _selectedDate.year == DateTime.now().year;

          final dayEvents = _events.where((event) {
            if (!isCurrentMonth) return false;
            final eventDate = event['date'];
            return eventDate.year == _selectedDate.year &&
                eventDate.month == _selectedDate.month &&
                eventDate.day == day;
          }).toList();

          return Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isToday
                  ? CalendarColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: isToday
                  ? Border.all(color: CalendarColors.primary, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  isCurrentMonth ? '$day' : '',
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? CalendarColors.primary : Colors.grey[800],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                if (dayEvents.isNotEmpty) ...[
                  ...dayEvents
                      .take(2)
                      .map((event) => Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 1),
                            decoration: BoxDecoration(
                              color: event['color'],
                              shape: BoxShape.circle,
                            ),
                          ))
                      .toList(),
                  if (dayEvents.length > 2)
                    Text('+${dayEvents.length - 2}',
                        style: const TextStyle(
                            fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Upcoming Events List
        SizedBox(
          height: 250,
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: _upcomingEvents.isEmpty
                ? const Center(child: Text('No upcoming events'))
                : ListView.builder(
                    itemCount: _upcomingEvents.length,
                    itemBuilder: (context, index) {
                      final event = _upcomingEvents[index];
                      return _buildUpcomingEventItem(event);
                    },
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Quick Stats
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Week',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Events', '${_upcomingEvents.length}'),
                    _buildStatItem('Quizzes',
                        '${_events.where((e) => e['type'] == 'quiz').length}'),
                    _buildStatItem('Due Soon', '3'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventItem(Map<String, dynamic> event) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: event['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child:
            Icon(_getEventIcon(event['type']), color: event['color'], size: 18),
      ),
      title: Text(
        event['title'],
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['course'],
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _formatTime(event['date']),
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
      trailing: Text(
        '${event['date'].day}/${event['date'].month}',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () => _showEventDetails(event),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: event['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(_getEventIcon(event['type']),
              color: event['color'], size: 18),
        ),
        title: Text(
          event['title'],
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${event['course']} • ${_formatTime(event['date'])}',
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class CalendarColors {
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFF4CAF50);
  static const accent = Color(0xFFFF9800);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF00BCD4);
}
