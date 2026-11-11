
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color navy = Color(0xFF233451);
  static const Color gold = Color(0xFFD4A017);

  static const int maxFileSize = 5 * 1024 * 1024;

  final Map<String, PlatformFile> documents = {};

  bool isPicking = false;

  final List<Map<String, dynamic>> documentTypes = [
    {
      'id': 'id_document',
      'title': 'South African ID Document',
      'description': 'Upload a copy of your ID (front and back).',
      'icon': Icons.badge,
      'required': true,
    },
    {
      'id': 'proof_address',
      'title': 'Proof of Address',
      'description':
      'Recent utility bill or municipal statement (not older than 3 months).',
      'icon': Icons.description,
      'required': true,
    },
    {
      'id': 'payslip',
      'title': 'Latest Payslip',
      'description': 'Latest payslip (not older than 3 months).',
      'icon': Icons.payments,
      'required': true,
    },
    {
      'id': 'bank_statement',
      'title': 'Bank Statement',
      'description': 'Recent bank statement (optional).',
      'icon': Icons.account_balance,
      'required': false,
    },
  ];

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? maroon : green,
      ),
    );
  }

  Future<void> pickDocument(String documentId) async {
    if (isPicking) return;

    setState(() => isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
        withData: false,
      );

      if (!mounted || result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      final extension = file.extension?.toLowerCase() ??
          file.name.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
        showMessage(
          'Only JPG, JPEG, PNG and PDF files are allowed.',
          error: true,
        );
        return;
      }

      if (file.size > maxFileSize) {
        showMessage(
          'File exceeds the maximum size of 5 MB.',
          error: true,
        );
        return;
      }

      if (file.size <= 0) {
        showMessage(
          'The selected file is empty.',
          error: true,
        );
        return;
      }

      setState(() {
        documents[documentId] = file;
      });

      showMessage('${file.name} selected successfully.');
    } catch (error) {
      debugPrint('Document picker error: $error');
      showMessage(
        'Unable to select document. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => isPicking = false);
      }
    }
  }

  void removeDocument(String documentId) {
    setState(() {
      documents.remove(documentId);
    });
    showMessage('Document removed.');
  }

  bool validateDocuments() {
    final missing = documentTypes
        .where((type) =>
    type['required'] == true &&
        !documents.containsKey(type['id']))
        .map((type) => type['title'] as String)
        .toList();

    if (missing.isNotEmpty) {
      showMessage(
        'Please upload: ${missing.join(', ')}',
        error: true,
      );
      return false;
    }

    return true;
  }

  void next() {
    if (!validateDocuments()) return;

    // This screen currently keeps file selections in memory.
    // The next step must implement secure persistent storage.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: green),
            SizedBox(width: 8),
            Expanded(
              child: Text('Documents Selected'),
            ),
          ],
        ),
        content: const Text(
          'All required documents have been selected.\n\n'
              'They are not yet uploaded to a server or '
              'saved permanently. Connect this screen to '
              'secure document storage before submitting '
              'a real insurance application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, true);
            },
            child: const Text('CONTINUE'),
          ),
        ],
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
                  'Upload Documents',
                  style: TextStyle(
                    color: green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Upload the required documents '
                      'to support your application.',
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

  Widget buildProgress() {
    const labels = [
      'Personal\nDetails',
      'Policy\nDetails',
      'Upload\nDocuments',
      'Review\n& Submit',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      child: Row(
        children: List.generate(4, (index) {
          final complete = index < 2;
          final active = index == 2;

          return Expanded(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: complete
                          ? green
                          : active
                          ? maroon
                          : const Color(0xFFDDE2EB),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: complete || active
                              ? Colors.white
                              : navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (complete)
                      const Positioned(
                        right: -5,
                        bottom: -4,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: green,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? maroon : navy,
                    fontSize: 11,
                    fontWeight: active
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget buildDocumentCard(Map<String, dynamic> type) {
    final id = type['id'] as String;
    final title = type['title'] as String;
    final description = type['description'] as String;
    final required = type['required'] as bool;
    final icon = type['icon'] as IconData;

    final file = documents[id];
    final uploaded = file != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD6DDE8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F9),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: const Color(0xFFF0D8DC),
              ),
            ),
            child: Icon(icon, color: maroon, size: 25),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      TextSpan(
                        text: required ? ' *' : ' (Optional)',
                        style: const TextStyle(
                          color: maroon,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF65738D),
                    fontSize: 11,
                  ),
                ),
                if (uploaded) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: green,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Selected',
                        style: TextStyle(
                          color: green,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: navy,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 7),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: isPicking
                    ? null
                    : () => pickDocument(id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: maroon,
                  side: const BorderSide(color: maroon),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  uploaded ? 'Replace' : 'Upload',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              if (uploaded)
                TextButton(
                  onPressed: () => removeDocument(id),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: maroon,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFBDE4D4),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user,
            color: green,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Notes:',
                  style: TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  '✓ Accepted formats: JPG, JPEG, PNG, PDF\n'
                      '✓ Maximum file size: 5 MB per document\n'
                      '✓ Ensure documents are clear and readable\n'
                      '✓ Files are not permanently stored yet',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: maroon,
              side: const BorderSide(
                color: maroon,
                width: 1.5,
              ),
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isPicking ? null : next,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
      ],
    );
  }

  Widget navItem(
      IconData icon,
      String title,
      String? route,
      ) {
    final active = title == 'Applications';

    return Expanded(
      child: InkWell(
        onTap: route == null
            ? null
            : () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFFFE9EB)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: active ? maroon : navy,
                size: 25,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: active ? maroon : navy,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
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
              null,
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
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/notifications',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          children: [
            buildHeader(),
            buildProgress(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFFE2E6EC),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFF0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: maroon,
                            child: Icon(
                              Icons.attach_file,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Required Documents',
                            style: TextStyle(
                              color: maroon,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please select clear images or PDF files '
                          '(maximum 5 MB each).',
                      style: TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...documentTypes.map(buildDocumentCard),
                    const SizedBox(height: 8),
                    buildImportantNotes(),
                    const SizedBox(height: 15),
                    buildButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}
