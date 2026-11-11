
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color navy = Color(0xFF233451);

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Application Under Review',
      'message':
      'Your application HBF20241023001 is currently under review by our team.',
      'date': '24 Oct 2024, 09:10',
      'category': 'Applications',
      'icon': Icons.description,
      'color': maroon,
      'read': false,
    },
    {
      'title': 'Documents Received',
      'message':
      'All required documents for application HBF20241023001 have been received and verified.',
      'date': '23 Oct 2024, 16:20',
      'category': 'Applications',
      'icon': Icons.check_circle,
      'color': green,
      'read': false,
    },
    {
      'title': 'Application Submitted',
      'message':
      'Your application HBF20241023001 has been submitted successfully.',
      'date': '23 Oct 2024, 14:35',
      'category': 'Applications',
      'icon': Icons.send,
      'color': Colors.blue,
      'read': false,
    },
    {
      'title': 'Payment Reminder',
      'message':
      'Your premium payment for Policy No. HBFM20240015 is due on 30 Oct 2024.',
      'date': '20 Oct 2024, 10:00',
      'category': 'Payments',
      'icon': Icons.credit_card,
      'color': Colors.orange,
      'read': true,
    },
    {
      'title': 'Policy Approved',
      'message':
      'Good news! Your application HBF20241010002 has been approved.',
      'date': '15 Oct 2024, 11:25',
      'category': 'Applications',
      'icon': Icons.notifications_active,
      'color': Colors.blueGrey,
      'read': true,
    },
    {
      'title': 'Welcome to HBF Insurance',
      'message':
      'Thank you for choosing HBF Insurance. We are here to help protect what matters most.',
      'date': '10 Oct 2024, 09:00',
      'category': 'General',
      'icon': Icons.info,
      'color': Colors.blue,
      'read': true,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 'All') return notifications;

    return notifications
        .where((n) => n['category'] == selectedFilter)
        .toList();
  }

  int get unreadCount =>
      notifications.where((n) => n['read'] == false).length;

  void openNotification(Map<String, dynamic> notification) {
    setState(() {
      notification['read'] = true;
    });

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(notification['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message'] as String),
            const SizedBox(height: 15),
            Text(
              notification['date'] as String,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
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

  void markAllAsRead() {
    setState(() {
      for (final notification in notifications) {
        notification['read'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        backgroundColor: green,
      ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Stay updated with important '
                      'information about your insurance applications.',
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

  Widget buildFilters() {
    const filters = [
      'All',
      'Applications',
      'Payments',
      'General',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              selectedColor: maroon,
              backgroundColor: const Color(0xFFF5F7FA),
              labelStyle: TextStyle(
                color: selected ? Colors.white : navy,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildNotificationCard(Map<String, dynamic> notification) {
    final color = notification['color'] as Color;
    final isRead = notification['read'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white
            : color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: InkWell(
        onTap: () => openNotification(notification),
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: color,
                    size: 25,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] as String,
                        style: TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: isRead
                              ? FontWeight.w600
                              : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'] as String,
                        style: const TextStyle(
                          color: Color(0xFF657590),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        notification['date'] as String,
                        style: const TextStyle(
                          color: Color(0xFF657590),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                  left: 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isRead)
                      const CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      ),
                    const SizedBox(height: 10),
                    const Icon(
                      Icons.chevron_right,
                      color: navy,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFC5DFFF),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Unread notifications are marked with a red dot.',
              style: TextStyle(
                color: navy,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(
      IconData icon,
      String title,
      String? route,
      ) {
    return Expanded(
      child: InkWell(
        onTap: route == null
            ? null
            : () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: navy, size: 25),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 11,
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
            navItem(
              Icons.home_outlined,
              'Home',
              '/dashboard',
            ),
            navItem(
              Icons.shield_outlined,
              'Products',
              '/products',
            ),
            navItem(
              Icons.description,
              'Applications',
              '/tracking',
            ),
            navItem(
              Icons.person_outline,
              'Profile',
              '/dashboard',
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
        title: const Text('HBF INSURANCE'),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Text(
              '$unreadCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all),
            onPressed: unreadCount == 0
                ? null
                : markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12, 12, 12, 8,
            ),
            child: buildFilters(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              children: [
                ...filteredNotifications.map(
                  buildNotificationCard,
                ),
                const SizedBox(height: 5),
                buildInfoPanel(),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}
