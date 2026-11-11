
import 'package:flutter/material.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color gold = Color(0xFFE5A000);
  static const Color navy = Color(0xFF233451);
  static const Color blue = Color(0xFF1976D2);

  final TextEditingController searchController =
  TextEditingController();

  String selectedFilter = 'All';
  String searchQuery = '';

  // Demonstration data.
  // Replace with records retrieved from SQLite.
  final List<Map<String, dynamic>> applications = [
    {
      'number': 'HBF20241023001',
      'customer': 'Sipho Dlamini',
      'product': 'Motor Insurance',
      'date': '23 Oct 2024',
      'status': 'Under Review',
      'email': 'sipho@example.com',
      'phone': '0712345678',
      'cover': 'R 250,000',
    },
    {
      'number': 'HBF20241021002',
      'customer': 'Nomsa Maseko',
      'product': 'Home Insurance',
      'date': '21 Oct 2024',
      'status': 'Approved',
      'email': 'nomsa@example.com',
      'phone': '0723456789',
      'cover': 'R 500,000',
    },
    {
      'number': 'HBF20241019003',
      'customer': 'Thabo Ndlovu',
      'product': 'Life Insurance',
      'date': '19 Oct 2024',
      'status': 'Under Review',
      'email': 'thabo@example.com',
      'phone': '0734567890',
      'cover': 'R 1,000,000',
    },
    {
      'number': 'HBF20241015004',
      'customer': 'Zanele Khumalo',
      'product': 'Health Insurance',
      'date': '15 Oct 2024',
      'status': 'Declined',
      'email': 'zanele@example.com',
      'phone': '0745678901',
      'cover': 'R 150,000',
    },
    {
      'number': 'HBF20241012005',
      'customer': 'Lerato Molefe',
      'product': 'Funeral Insurance',
      'date': '12 Oct 2024',
      'status': 'Approved',
      'email': 'lerato@example.com',
      'phone': '0756789012',
      'cover': 'R 50,000',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  int countStatus(String status) {
    return applications
        .where((app) => app['status'] == status)
        .length;
  }

  List<Map<String, dynamic>> get filteredApplications {
    return applications.where((app) {
      final matchesFilter = selectedFilter == 'All' ||
          app['status'] == selectedFilter;

      final query = searchQuery.toLowerCase();

      final matchesSearch =
          app['number'].toString().toLowerCase().contains(query) ||
              app['customer'].toString().toLowerCase().contains(query) ||
              app['product'].toString().toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
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

  Color statusBackground(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFFD9F5E8);
      case 'Declined':
        return const Color(0xFFFFE0E4);
      case 'Under Review':
        return const Color(0xFFFFE39B);
      default:
        return const Color(0xFFE0EEFF);
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

  Future<void> updateStatus(
      Map<String, dynamic> application,
      String newStatus,
      ) async {
    if (application['status'] != 'Under Review') {
      showMessage(
        'Only applications under review can be decided.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$newStatus Application'),
        content: Text(
          'Are you sure you want to mark application '
              '${application['number']} as $newStatus?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Approved'
                  ? green
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      application['status'] = newStatus;
    });

    showMessage(
      'Application ${application['number']} '
          'marked as $newStatus.',
    );
  }

  void viewApplication(Map<String, dynamic> application) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description, color: maroon),
            SizedBox(width: 9),
            Expanded(
              child: Text('Application Details'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detailLine(
                'Application Number',
                application['number'],
              ),
              detailLine(
                'Customer Name',
                application['customer'],
              ),
              detailLine(
                'Insurance Product',
                application['product'],
              ),
              detailLine(
                'Date Submitted',
                application['date'],
              ),
              detailLine(
                'Email',
                application['email'],
              ),
              detailLine(
                'Phone',
                application['phone'],
              ),
              detailLine(
                'Cover Amount',
                application['cover'],
              ),
              detailLine(
                'Status',
                application['status'],
              ),
            ],
          ),
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

  Widget detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: navy,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF657590),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      height: 175,
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
          const SizedBox(width: 10),
          const Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Applications',
                  style: TextStyle(
                    color: green,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Review, verify documents and '
                      'approve or decline applications.',
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

  Widget filterChip(String label, int count) {
    final selected = selectedFilter == label;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => selectedFilter = label);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? maroon
                : label == 'Approved'
                ? const Color(0xFFE5F8EF)
                : label == 'Declined'
                ? const Color(0xFFEAF4FF)
                : const Color(0xFFFFF9EB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? maroon
                  : const Color(0xFFE0E5ED),
            ),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : navy,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilters() {
    return Row(
      children: [
        filterChip('All', applications.length),
        filterChip(
          'Under Review',
          countStatus('Under Review'),
        ),
        filterChip(
          'Approved',
          countStatus('Approved'),
        ),
        filterChip(
          'Declined',
          countStatus('Declined'),
        ),
      ],
    );
  }

  Widget buildSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() => searchQuery = value);
            },
            decoration: InputDecoration(
              hintText:
              'Search by application number, name or product...',
              hintStyle: const TextStyle(fontSize: 11),
              prefixIcon: const Icon(
                Icons.search,
                color: navy,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 7),
        PopupMenuButton<String>(
          tooltip: 'Filter applications',
          icon: const Icon(
            Icons.filter_alt,
            color: navy,
          ),
          onSelected: (value) {
            setState(() => selectedFilter = value);
          },
          itemBuilder: (context) {
            return [
              'All',
              'Under Review',
              'Approved',
              'Declined',
            ].map((value) {
              return PopupMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget buildApplicationCard(Map<String, dynamic> application) {
    final status = application['status'] as String;
    final color = statusColor(status);
    final canDecide = status == 'Under Review';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFDDE3ED),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.13),
                child: Icon(
                  Icons.person,
                  color: color,
                  size: 27,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application['customer'],
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      application['number'],
                      style: const TextStyle(
                        color: navy,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Product: ${application['product']}',
                      style: const TextStyle(
                        color: Color(0xFF657590),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Submitted: ${application['date']}',
                      style: const TextStyle(
                        color: Color(0xFF657590),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 128,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 8,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground(status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        actionButton(
                          Icons.visibility,
                          blue,
                              () => viewApplication(application),
                        ),
                        actionButton(
                          Icons.check_circle,
                          green,
                          canDecide
                              ? () => updateStatus(
                            application,
                            'Approved',
                          )
                              : null,
                        ),
                        actionButton(
                          Icons.close,
                          Colors.red,
                          canDecide
                              ? () => updateStatus(
                            application,
                            'Declined',
                          )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButton(
      IconData icon,
      Color color,
      VoidCallback? onPressed,
      ) {
    return Expanded(
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 21,
          color: onPressed == null
              ? Colors.grey.shade400
              : color,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minHeight: 36,
          minWidth: 32,
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
              '/admin-dashboard',
            ),
            bottomItem(
              Icons.description,
              'Applications',
              null,
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

  Widget bottomItem(
      IconData icon,
      String label,
      String? route,
      ) {
    final selected = label == 'Applications';

    return Expanded(
      child: InkWell(
        onTap: route == null
            ? null
            : () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 11,
          ),
          color: selected
              ? const Color(0xFFFFE9EB)
              : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? maroon : navy,
                size: 24,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? maroon : navy,
                ),
              ),
            ],
          ),
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
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(
              context,
              '/notifications',
            ),
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
      body: Column(
        children: [
          buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              10, 12, 10, 6,
            ),
            child: buildFilters(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            child: buildSearch(),
          ),
          Expanded(
            child: filteredApplications.isEmpty
                ? const Center(
              child: Text('No applications found.'),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) {
                return buildApplicationCard(
                  filteredApplications[index],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}
