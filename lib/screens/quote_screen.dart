
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  static const Color maroon = Color(0xFF900019);
  static const Color green = Color(0xFF005A3C);
  static const Color gold = Color(0xFFD4A017);
  static const Color navy = Color(0xFF233451);

  final _formKey = GlobalKey<FormState>();

  final coverController = TextEditingController();
  final notesController = TextEditingController();

  String? selectedProduct;
  String? selectedPolicy;
  DateTime? startDate;
  DateTime? endDate;

  int currentStep = 0;
  int selectedNav = 1;

  final products = [
    'Motor Insurance',
    'Home Insurance',
    'Life Insurance',
    'Health Insurance',
    'Funeral Insurance',
  ];

  final policies = [
    'Comprehensive',
    'Third Party',
    'Basic Cover',
    'Premium Cover',
    'Family Cover',
  ];

  @override
  void dispose() {
    coverController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> selectDate(bool isStart) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (startDate ?? now)
          : (endDate ?? startDate ?? now),
      firstDate: isStart
          ? now
          : (startDate ?? now),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: maroon,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = picked;

        if (endDate != null &&
            endDate!.isBefore(picked)) {
          endDate = null;
        }
      } else {
        endDate = picked;
      }
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: green,
      ),
    );
  }

  void getQuote() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (startDate == null) {
      showMessage('Please select a start date.');
      return;
    }

    if (endDate != null &&
        endDate!.isBefore(startDate!)) {
      showMessage(
        'End date cannot be before start date.',
      );
      return;
    }

    setState(() {
      currentStep = 3;
    });

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.description,
                color: green,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Quotation Request'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              'Insurance Product: $selectedProduct\n'
                  'Policy Type: $selectedPolicy\n'
                  'Cover Amount: R${coverController.text}\n'
                  'Start Date: ${formatDate(startDate)}\n'
                  'End Date: '
                  '${endDate == null ? "Not specified" : formatDate(endDate)}\n\n'
                  'Your quotation details are ready '
                  'for review.\n\n'
                  'This is a demonstration. '
                  'No quotation has been submitted '
                  'to an insurance provider.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CLOSE'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushNamed(
                  context,
                  '/application',
                );
              },
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );
  }

  Widget buildProgressStep(
      int number,
      String title,
      bool active,
      ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active
                  ? maroon
                  : const Color(0xFFDDE1E9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                color: active
                    ? Colors.white
                    : navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: active ? maroon : navy,
              fontWeight: active
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget fieldIcon(IconData icon) {
    return Container(
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        border: Border.all(
          color: const Color(0xFFF1D9DE),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: maroon,
        size: 27,
      ),
    );
  }

  InputDecoration fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8090AA),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFD1D8E5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: maroon,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget labeledField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          fieldIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuoteForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFD7DFE9),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // INSURANCE PRODUCT
            labeledField(
              label: 'Insurance Product',
              icon: Icons.verified_user,
              child: DropdownButtonFormField<String>(
                value: selectedProduct,
                isExpanded: true,
                decoration: fieldDecoration(
                  'Select Insurance Product',
                ),
                items: products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(
                      product,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProduct = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Select insurance product';
                  }
                  return null;
                },
              ),
            ),

            // POLICY TYPE
            labeledField(
              label: 'Policy Type',
              icon: Icons.description,
              child: DropdownButtonFormField<String>(
                value: selectedPolicy,
                isExpanded: true,
                decoration: fieldDecoration(
                  'Select Policy Type',
                ),
                items: policies.map((policy) {
                  return DropdownMenuItem(
                    value: policy,
                    child: Text(
                      policy,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPolicy = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Select policy type';
                  }
                  return null;
                },
              ),
            ),

            // COVER AMOUNT
            labeledField(
              label: 'Cover Amount',
              icon: Icons.monetization_on,
              child: TextFormField(
                controller: coverController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                decoration: fieldDecoration(
                  'Enter cover amount',
                ).copyWith(
                  prefixText: 'R  ',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter cover amount';
                  }

                  final amount =
                  double.tryParse(value);

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),
            ),

            // START DATE AND END DATE
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: dateField(
                    label: 'Start Date',
                    date: startDate,
                    onTap: () => selectDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: dateField(
                    label: 'End Date (Optional)',
                    date: endDate,
                    onTap: () => selectDate(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ADDITIONAL INFORMATION
            labeledField(
              label: 'Additional Information (Optional)',
              icon: Icons.chat,
              child: TextFormField(
                controller: notesController,
                maxLength: 250,
                maxLines: 3,
                decoration: fieldDecoration(
                  'Tell us more about your needs...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: navy,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD1D8E5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date == null
                        ? 'Select date'
                        : formatDate(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: date == null
                          ? const Color(0xFF8090AA)
                          : navy,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month,
                  color: navy,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void openRoute(String route) {
    if (route == '/quote') return;

    Navigator.pushNamed(context, route);
  }

  Widget navItem({
    required IconData icon,
    required String title,
    required int index,
    required String route,
  }) {
    final active = selectedNav == index;

    return Expanded(
      child: InkWell(
        onTap: () => openRoute(route),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFFFE8EB)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: active ? maroon : navy,
                size: 26,
              ),
              const SizedBox(height: 5),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE1E5EB),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            navItem(
              icon: Icons.home_outlined,
              title: 'Home',
              index: 0,
              route: '/dashboard',
            ),
            navItem(
              icon: Icons.verified_user,
              title: 'Products',
              index: 1,
              route: '/products',
            ),
            navItem(
              icon: Icons.description_outlined,
              title: 'Applications',
              index: 2,
              route: '/application',
            ),
            navItem(
              icon: Icons.person_outline,
              title: 'Profile',
              index: 3,
              route: '/dashboard',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      height: 185,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/insurance_background.png',
          ),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Image.asset(
                'assets/images/insurance_logo.jpg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get a Quote',
                    style: TextStyle(
                      fontSize: 26,
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get an estimated quote\n'
                        'in a few easy steps.',
                    style: TextStyle(
                      fontSize: 13,
                      color: navy,
                    ),
                  ),
                ],
              ),
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
        elevation: 0,
        title: const Text(
          'HBF INSURANCE',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
            ),
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
        child: Column(
          children: [
            buildHeader(),

            const SizedBox(height: 25),

            // PROGRESS INDICATOR
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Row(
                children: [
                  buildProgressStep(
                    1,
                    'Quote Details',
                    currentStep == 0,
                  ),
                  buildProgressStep(
                    2,
                    'Coverage',
                    currentStep == 1,
                  ),
                  buildProgressStep(
                    3,
                    'Your Details',
                    currentStep == 2,
                  ),
                  buildProgressStep(
                    4,
                    'Review',
                    currentStep == 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: buildQuoteForm(),
            ),

            const SizedBox(height: 15),

            // GET QUOTE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: getQuote,
                  icon: const Icon(
                    Icons.search,
                    size: 26,
                  ),
                  label: const Text(
                    'Get Quote',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),

      bottomNavigationBar: buildBottomNavigation(),
    );
  }
}
