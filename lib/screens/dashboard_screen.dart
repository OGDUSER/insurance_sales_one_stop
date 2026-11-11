
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color gold = Color(0xFFE5A000);
  static const Color navy = Color(0xFF233451);
  static const Color blue = Color(0xFF1976D2);

  final searchController = TextEditingController();

  String searchQuery = '';
  String statusFilter = 'All';

  // Demonstration records. Replace with SQLite records later.
  final List<Map<String, dynamic>> applications = [
    {
      'number': 'HBF20241023001',
      'customer': 'Sipho Dlamini',
      'product': 'Motor',
      'date': '23 Oct 2024',
      'status': 'Under Review',
    },
    {
      'number': 'HBF20241021002',
      'customer': 'Nomsa Maseko',
      'product': 'Home',
      'date': '21 Oct 2024',
      'status': 'Approved',
    },
    {
      'number': 'HBF20241019003',
      'customer': 'Thabo Ndlovu',
      'product': 'Life',
      'date': '19 Oct 2024',
      'status': 'Under Review',
    },
    {
      'number': 'HBF20241015004',
      'customer': 'Zanele Khumalo',
      'product': 'Health',
      'date': '15 Oct 2024',
      'status': 'Declined',
    },
    {
      'number': 'HBF20241012005',
      'customer': 'Lerato Molefe',
      'product': 'Funeral',
      'date': '12 Oct 2024',
      'status': 'Approved',
    },
  ];

  final List<Map<String, String>> activities = [
    {
      'message': 'Application HBF20241023001 submitted',
      'date': '23 Oct 2024, 14:35',
      'type': 'submitted',
    },
    {
      'message': 'Documents verified for HBF20241021002',
      'date': '23 Oct 2024, 16:20',
      'type': 'verified',
    },
    {
      'message': 'Application HBF20241015004 declined',
      'date': '22 Oct 2024, 11:10',
      'type': 'declined',
    },
    {
      'message': 'Application HBF20241019003 under review',
      'date': '21 Oct 2024, 09:45',
      'type': 'review',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  int get totalApplications => applications.length;

  int countStatus(String status) {
    return applications
        .where((app) => app['status'] == status)
        .length;
  }

  List<Map<String, dynamic>> get filteredApplications {
    return applications.where((app) {
      final matchesSearch =
          app['number'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
              app['customer'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              app['product'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

      final matchesStatus = statusFilter == 'All' ||
          app['status'] == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Approved':
        return green;
      case 'Declined':
        return Colors.red;
      case 'Under Review':
        return gold;
      default:
        return blue;
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: green,
      ),
    );
  }

  void openRoute(String route) {
    Navigator.pushNamed(context, route);
  }

  void viewApplication(Map<String, dynamic> app) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Application Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Application: ${app['number']}'),
            const SizedBox(height: 8),
            Text('Customer: ${app['customer']}'),
            const SizedBox(height: 8),
            Text('Product: ${app['product']}'),
            const SizedBox(height: 8),
            Text('Date: ${app['date']}'),
            const SizedBox(height: 8),
            Text('Status: ${app['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Future<void> changeStatus(
      Map<String, dynamic> app,
      String newStatus,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$newStatus Application'),
        content: Text(
          'Are you sure you want to ${newStatus.toLowerCase()} '
              'application ${app['number']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Approved'
                  ? green
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      app['status'] = newStatus;

      activities.insert(0, {
        'message':
        'Application ${app['number']} ${newStatus.toLowerCase()}',
        'date': 'Just now',
        'type': newStatus == 'Approved'
            ? 'verified'
            : 'declined',
      });
    });

    showMessage(
      'Application ${app['number']} marked as $newStatus.',
    );
  }

  Widget buildHeader() {
    return Container(
      height: 165,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/insurance_background.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/insurance_logo.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator Dashboard',
                  style: TextStyle(
                    color: green,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Manage insurance applications, '
                      'customers and documents.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: color.withOpacity(0.20),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummary() {
    return Row(
      children: [
        summaryCard(
          title: 'Total Applications',
          count: totalApplications,
          icon: Icons.description,
          color: maroon,
        ),
        const SizedBox(width: 7),
        summaryCard(
          title: 'Under Review',
          count: countStatus('Under Review'),
          icon: Icons.schedule,
          color: gold,
        ),
        const SizedBox(width: 7),
        summaryCard(
          title: 'Approved',
          count: countStatus('Approved'),
          icon: Icons.check,
          color: green,
        ),
        const SizedBox(width: 7),
        summaryCard(
          title: 'Declined',
          count: countStatus('Declined'),
          icon: Icons.close,
          color: blue,
        ),
      ],
    );
  }

  Widget shortcut(
      String title,
      IconData icon,
      String? route,
      ) {
    return Expanded(
      child: InkWell(
        onTap: route == null
            ? null
            : () => openRoute(route),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 3,
          ),
          decoration: BoxDecoration(
            color: title == 'Applications'
                ? const Color(0xFFFFE8EB)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFDDE3ED),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: navy, size: 27),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildShortcuts() {
    return Row(
      children: [
        shortcut(
          'Applications',
          Icons.list_alt,
          '/admin-review',
        ),
        const SizedBox(width: 7),
        shortcut(
          'Customers',
          Icons.people,
          '/admin-customers',
        ),
        const SizedBox(width: 7),
        shortcut(
          'Documents',
          Icons.description,
          '/admin-documents',
        ),
        const SizedBox(width: 7),
        shortcut(
          'Reports',
          Icons.bar_chart,
          '/admin-reports',
        ),
        const SizedBox(width: 7),
        shortcut(
          'Settings',
          Icons.settings,
          '/admin-settings',
        ),
      ],
    );
  }

  Widget statusBadge(String status) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color == gold ? navy : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget actionButton(
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 19),
      constraints: const BoxConstraints(
        minWidth: 31,
        minHeight: 31,
      ),
      padding: const EdgeInsets.all(3),
    );
  }

  Widget buildApplicationList() {
    final filtered = filteredApplications;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE0E5ED),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDEF),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: maroon,
                  child: Icon(
                    Icons.description,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Recent Applications',
                    style: TextStyle(
                      color: maroon,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => openRoute('/application'),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text(
                    'New',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search application or customer...',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                PopupMenuButton<String>(
                  tooltip: 'Filter by status',
                  icon: const Icon(
                    Icons.filter_alt,
                    color: navy,
                  ),
                  onSelected: (value) {
                    setState(() => statusFilter = value);
                  },
                  itemBuilder: (context) => [
                    'All',
                    'Under Review',
                    'Approved',
                    'Declined',
                  ].map((value) {
                    return PopupMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No applications found.'),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                MaterialStateProperty.all(
                  const Color(0xFFF0F3F8),
                ),
                columnSpacing: 14,
                horizontalMargin: 10,
                dataRowMinHeight: 58,
                dataRowMaxHeight: 68,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Application No.')),
                  DataColumn(label: Text('Customer Name')),
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filtered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final app = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(app['number'])),
                      DataCell(Text(app['customer'])),
                      DataCell(Text(app['product'])),
                      DataCell(Text(app['date'])),
                      DataCell(statusBadge(app['status'])),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            actionButton(
                              Icons.visibility,
                              navy,
                                  () => viewApplication(app),
                            ),
                            actionButton(
                              Icons.check_circle,
                              green,
                                  () => changeStatus(
                                app,
                                'Approved',
                              ),
                            ),
                            actionButton(
                              Icons.close,
                              Colors.red,
                                  () => changeStatus(
                                app,
                                'Declined',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => openRoute('/admin-review'),
              child: const Text('View All >'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatistics() {
    final total = totalApplications;
    final review = countStatus('Under Review');
    final approved = countStatus('Approved');
    final declined = countStatus('Declined');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E5ED),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Statistics',
            style: TextStyle(
              color: maroon,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          statisticRow('Under Review', review, total, gold),
          statisticRow('Approved', approved, total, green),
          statisticRow('Declined', declined, total, Colors.red),
        ],
      ),
    );
  }

  Widget statisticRow(
      String label,
      int count,
      int total,
      Color color,
      ) {
    final percentage = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '$count (${(percentage * 100).round()}%)',
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage,
            minHeight: 9,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: const Color(0xFFE5E9F0),
            color: color,
          ),
        ],
      ),
    );
  }

  Widget buildActivities() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E5ED),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              color: maroon,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...activities.take(5).map((activity) {
            Color color;

            switch (activity['type']) {
              case 'verified':
                color = green;
                break;
              case 'declined':
                color = Colors.red;
                break;
              case 'review':
                color = gold;
                break;
              default:
                color = blue;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['message']!,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          activity['date']!,
                          style: const TextStyle(
                            color: Color(0xFF6B7A93),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget bottomItem(
      IconData icon,
      String title,
      String? route,
      ) {
    final selected = title == 'Dashboard';

    return Expanded(
      child: InkWell(
        onTap: route == null
            ? null
            : () => openRoute(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: selected
              ? const Color(0xFFFFE8EB)
              : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? maroon : navy,
                size: 25,
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: selected ? maroon : navy,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            bottomItem(
              Icons.home,
              'Dashboard',
              null,
            ),
            bottomItem(
              Icons.description,
              'Applications',
              '/admin-review',
            ),
            bottomItem(
              Icons.people,
              'Customers',
              '/admin-customers',
            ),
            bottomItem(
              Icons.bar_chart,
              'Reports',
              '/admin-reports',
            ),
            bottomItem(
              Icons.settings,
              'Settings',
              '/admin-settings',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      appBar: AppBar(
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        title: const Text(
          'HBF INSURANCE',
          style: TextStyle(fontSize: 19),
        ),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications),
            ),
            onPressed: () => openRoute('/notifications'),
          ),
          PopupMenuButton<String>(
            tooltip: 'Administrator menu',
            icon: const Icon(Icons.person),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  buildSummary(),
                  const SizedBox(height: 13),
                  buildShortcuts(),
                  const SizedBox(height: 14),
                  buildApplicationList(),
                  const SizedBox(height: 14),
                  buildStatistics(),
                  const SizedBox(height: 14),
                  buildActivities(),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}
