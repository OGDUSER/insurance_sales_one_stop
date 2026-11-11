
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key});

  @override
  State<ApplicationScreen> createState() =>
      _ApplicationScreenState();
}

class _ApplicationScreenState
    extends State<ApplicationScreen> {
  static const maroon = Color(0xFF900019);
  static const green = Color(0xFF005A3C);
  static const navy = Color(0xFF233451);

  final personalKey = GlobalKey<FormState>();
  final policyKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final idNumber = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final income = TextEditingController();
  final employer = TextEditingController();
  final occupation = TextEditingController();
  final coverAmount = TextEditingController();

  DateTime? birthDate;
  String? gender;
  String? employment;
  String? product;
  String? policy;
  int step = 0;

  final employmentOptions = [
    'Employed',
    'Self-employed',
    'Unemployed',
    'Student',
    'Pensioner',
  ];

  final productOptions = [
    'Motor Insurance',
    'Home Insurance',
    'Life Insurance',
    'Health Insurance',
    'Funeral Insurance',
  ];

  final policyOptions = [
    'Basic Cover',
    'Standard Cover',
    'Premium Cover',
    'Comprehensive',
    'Third Party',
  ];

  @override
  void dispose() {
    for (final c in [
      name, idNumber, email, phone, address,
      income, employer, occupation, coverAmount
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration decoration(
      String hint, {
        Widget? prefix,
      }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8491A7),
        fontSize: 13,
      ),
      prefixIcon: prefix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD1D8E5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD1D8E5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: maroon,
          width: 1.5,
        ),
      ),
    );
  }

  String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (!RegExp(r'^0\d{9}$')
        .hasMatch(value ?? '')) {
      return 'Enter a valid 10-digit SA number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(value?.trim() ?? '')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validateId(String? value) {
    final id = value ?? '';
    if (!RegExp(r'^\d{13}$').hasMatch(id)) {
      return 'Enter 13 digits';
    }

    // South African ID checksum (Luhn).
    int sum = 0;
    bool doubleDigit = false;
    for (int i = id.length - 1; i >= 0; i--) {
      int digit = int.parse(id[i]);
      if (doubleDigit) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubleDigit = !doubleDigit;
    }
    if (sum % 10 != 0) {
      return 'Invalid ID checksum';
    }
    return null;
  }

  Widget input({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconBox(icon),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboard,
                  inputFormatters: formatters,
                  validator: validator,
                  decoration: decoration(
                    hint ?? 'Enter $label',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget iconBox(IconData icon) {
    return Container(
      width: 39,
      height: 49,
      margin: const EdgeInsets.only(top: 19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFA),
        border: Border.all(
          color: const Color(0xFFF1D9DE),
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: maroon, size: 23),
    );
  }

  Widget dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconBox(icon),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: value,
                  isExpanded: true,
                  decoration: decoration('Select $label'),
                  items: options.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  validator: (value) =>
                  value == null ? 'Required' : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String dateText(DateTime? d) {
    if (d == null) return 'Select date of birth';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> pickBirthDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 25),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  Widget birthDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          iconBox(Icons.calendar_month),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date of Birth *',
                  style: TextStyle(
                    fontSize: 12,
                    color: navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: pickBirthDate,
                  child: InputDecorator(
                    decoration: decoration(
                      'Select date of birth',
                      prefix: const Icon(
                        Icons.calendar_today,
                        size: 18,
                      ),
                    ),
                    child: Text(
                      dateText(birthDate),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget section(
      String title,
      IconData icon,
      Widget content,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            decoration: const BoxDecoration(
              color: Color(0xFFFFEFF0),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: maroon,
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget twoColumns(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            children: [left, right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 10),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget personalDetails() {
    return Form(
      key: personalKey,
      child: Column(
        children: [
          section(
            'Personal Details',
            Icons.person,
            Column(
              children: [
                twoColumns(
                  input(
                    label: 'Full Name *',
                    icon: Icons.person_outline,
                    controller: name,
                    validator: requiredField,
                    hint: 'Enter full name',
                  ),
                  input(
                    label: 'ID Number *',
                    icon: Icons.badge_outlined,
                    controller: idNumber,
                    validator: validateId,
                    keyboard: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                    hint: 'Enter ID number',
                  ),
                ),
                twoColumns(
                  birthDateField(),
                  dropdown(
                    label: 'Gender *',
                    icon: Icons.people,
                    value: gender,
                    options: [
                      'Female',
                      'Male',
                      'Other',
                      'Prefer not to say',
                    ],
                    onChanged: (v) =>
                        setState(() => gender = v),
                  ),
                ),
                twoColumns(
                  input(
                    label: 'Email Address *',
                    icon: Icons.mail_outline,
                    controller: email,
                    validator: validateEmail,
                    keyboard: TextInputType.emailAddress,
                    hint: 'Enter email address',
                  ),
                  input(
                    label: 'Cell Phone Number *',
                    icon: Icons.phone_android,
                    controller: phone,
                    validator: validatePhone,
                    keyboard: TextInputType.phone,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    hint: 'Enter cell number',
                  ),
                ),
                input(
                  label: 'Residential Address *',
                  icon: Icons.home,
                  controller: address,
                  validator: requiredField,
                  hint: 'Enter your residential address',
                ),
              ],
            ),
          ),
          section(
            'Employment & Income Details',
            Icons.verified_user,
            Column(
              children: [
                twoColumns(
                  dropdown(
                    label: 'Employment Status *',
                    icon: Icons.work,
                    value: employment,
                    options: employmentOptions,
                    onChanged: (v) =>
                        setState(() => employment = v),
                  ),
                  input(
                    label: 'Monthly Income (R) *',
                    icon: Icons.payments,
                    controller: income,
                    keyboard: const TextInputType
                        .numberWithOptions(decimal: true),
                    formatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}$'),
                      ),
                    ],
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n < 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                    hint: 'Monthly income',
                  ),
                ),
                twoColumns(
                  input(
                    label: 'Employer Name',
                    icon: Icons.business,
                    controller: employer,
                    hint: 'Employer name',
                  ),
                  input(
                    label: 'Occupation',
                    icon: Icons.work_outline,
                    controller: occupation,
                    hint: 'Occupation',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget policyDetails() {
    return Form(
      key: policyKey,
      child: section(
        'Policy Details',
        Icons.shield,
        Column(
          children: [
            dropdown(
              label: 'Insurance Product *',
              icon: Icons.verified_user,
              value: product,
              options: productOptions,
              onChanged: (v) =>
                  setState(() => product = v),
            ),
            dropdown(
              label: 'Policy Type *',
              icon: Icons.description,
              value: policy,
              options: policyOptions,
              onChanged: (v) =>
                  setState(() => policy = v),
            ),
            input(
              label: 'Cover Amount (R) *',
              icon: Icons.payments,
              controller: coverAmount,
              keyboard: const TextInputType
                  .numberWithOptions(decimal: true),
              formatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}$'),
                ),
              ],
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) {
                  return 'Enter a positive amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget reviewDetails() {
    return section(
      'Review Your Application',
      Icons.fact_check,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reviewLine('Full Name', name.text),
          reviewLine('ID Number', idNumber.text),
          reviewLine('Date of Birth', dateText(birthDate)),
          reviewLine('Gender', gender ?? ''),
          reviewLine('Email', email.text),
          reviewLine('Phone', phone.text),
          reviewLine('Address', address.text),
          reviewLine('Employment', employment ?? ''),
          reviewLine('Monthly Income', 'R ${income.text}'),
          reviewLine('Insurance Product', product ?? ''),
          reviewLine('Policy Type', policy ?? ''),
          reviewLine('Cover Amount', 'R ${coverAmount.text}'),
          const SizedBox(height: 12),
          const Text(
            'Please verify your information before '
                'submitting it to an insurance provider.',
            style: TextStyle(color: navy),
          ),
        ],
      ),
    );
  }

  Widget reviewLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget progress() {
    final titles = [
      'Personal\nDetails',
      'Policy\nDetails',
      'Upload\nDocuments',
      'Review\n& Submit',
    ];

    return Row(
      children: List.generate(4, (index) {
        final active = step == index;
        final complete = step > index;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: active || complete
                    ? maroon
                    : const Color(0xFFDDE2EB),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: active || complete
                        ? Colors.white
                        : navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                titles[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? maroon : navy,
                  fontWeight: active
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget header() {
    return Container(
      height: 180,
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
        padding: const EdgeInsets.all(14),
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insurance\nApplication',
                    style: TextStyle(
                      fontSize: 22,
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Complete the application to '
                        'apply for your selected insurance.',
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
      ),
    );
  }

  Future<void> next() async {
    if (step == 0) {
      if (!personalKey.currentState!.validate()) return;
      if (birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select date of birth'),
          ),
        );
        return;
      }
      setState(() => step = 1);
    } else if (step == 1) {
      if (!policyKey.currentState!.validate()) return;
      setState(() => step = 2);
    } else if (step == 2) {
      // This opens the existing Upload Documents page.
      // Returning here does not prove upload completion.
      await Navigator.pushNamed(context, '/upload');
      if (!mounted) return;
      setState(() => step = 3);
    } else {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Application Preview'),
          content: const Text(
            'Your application details have been '
                'reviewed in this demonstration.\n\n'
                'The application has NOT yet been saved '
                'or submitted. Connect this screen to '
                'SQLite or your secure backend to enable '
                'actual submission.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget bottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            nav(Icons.home_outlined, 'Home', '/dashboard'),
            nav(Icons.shield_outlined, 'Products', '/products'),
            nav(Icons.description, 'Applications', null),
            nav(Icons.person_outline, 'Profile', '/dashboard'),
          ],
        ),
      ),
    );
  }

  Widget nav(
      IconData icon,
      String title,
      String? route,
      ) {
    final selected = title == 'Applications';
    return Expanded(
      child: InkWell(
        onTap: route == null
            ? null
            : () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          color: selected
              ? const Color(0xFFFFE9EB)
              : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? maroon : navy,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
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
        title: const Text('HBF INSURANCE'),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(
              context,
              '/notifications',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: progress(),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: step == 0
                        ? personalDetails()
                        : step == 1
                        ? policyDetails()
                        : step == 2
                        ? section(
                      'Upload Documents',
                      Icons.upload_file,
                      const Text(
                        'Tap Open Upload Screen to '
                            'attach your supporting documents.',
                      ),
                    )
                        : reviewDetails(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12, 5, 12, 9,
            ),
            child: Row(
              children: [
                if (step > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => step--),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        step == 3
                            ? Icons.check_circle
                            : Icons.arrow_forward,
                      ),
                      label: Text(
                        step == 2
                            ? 'Open Upload Screen'
                            : step == 3
                            ? 'Submit Application'
                            : 'Next',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigation(),
    );
  }
}
