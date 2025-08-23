import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingDialog extends StatefulWidget {
  const BookingDialog({super.key});

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();

  // Track the test as a simple String (do NOT own Autocomplete controller)
  String _testText = 'Complete Blood Count (CBC)';

  DateTime? _preferredDate;
  bool _submitting = false;

  // Master list
  static const List<String> _tests = [
    'Complete Blood Count (CBC)',
    'Diabetes & Cholesterol Screening',
    'Liver & Kidney Function Tests',
    'Thyroid Profile',
    'Vitamin & Mineral Deficiency Tests',
    'Urine & Stool Analysis',
    'Customized Health Package',
    'Home Sample Collection',
    // Diabetes / Lipids
    'HbA1c (Glycated Hemoglobin)',
    'Fasting Blood Glucose (FBG)',
    'Random Blood Glucose (RBG)',
    'Oral Glucose Tolerance Test (OGTT)',
    'Lipid Profile (Cholesterol, HDL, LDL, TG)',
    'Total Cholesterol',
    'HDL Cholesterol',
    'LDL Cholesterol',
    'Triglycerides',
    // Liver / Kidney / Electrolytes
    'Liver Function Tests (LFTs)',
    'ALT (SGPT)',
    'AST (SGOT)',
    'ALP (Alkaline Phosphatase)',
    'Bilirubin (Total/Direct/Indirect)',
    'Kidney Function Tests (RFTs)',
    'Serum Creatinine',
    'Blood Urea',
    'Uric Acid',
    'Electrolytes (Na/K/Cl)',
    'Calcium',
    'Magnesium',
    // Thyroid
    'TSH',
    'Free T3 (FT3)',
    'Free T4 (FT4)',
    'Thyroid Antibodies (TPO/TgAb)',
    // Vitamins / Iron
    'Vitamin D (25-OH)',
    'Vitamin B12',
    'Ferritin',
    'Iron Studies (Iron/TIBC/Transferrin)',
    // Hematology / Inflammation / Coag
    'ESR',
    'CRP (C-Reactive Protein)',
    'D-Dimer',
    'Prothrombin Time (PT/INR)',
    'APTT',
    // Infectious
    'HBsAg (Hepatitis B Surface Antigen)',
    'HCV Antibodies',
    'HIV (Screening)',
    'Typhoid (Widal / Typhi IgM)',
    'Dengue NS1',
    'Dengue IgM/IgG',
    'Malaria Parasite (Smear/ICT)',
    'COVID-19 PCR',
    'COVID-19 Rapid Antigen',
    // Urine / Stool
    'Urine Routine Examination (Urine R/E)',
    'Stool Routine Examination (Stool R/E)',
    'Stool Occult Blood',
    // Others
    'Blood Group & Rh Factor',
    'Rheumatoid Factor (RF)',
    'ANA (Antinuclear Antibodies)',
    'PSA (Prostate Specific Antigen)',
    'β-hCG (Pregnancy Test)',
  ];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _notes.dispose();
    // DO NOT dispose any controller coming from Autocomplete
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _openAllTestsSheet() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String query = '';
        List<String> filtered = List.of(_tests);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (c, scrollController) {
            return StatefulBuilder(
              builder: (c, setLocal) {
                void applyFilter(String q) {
                  query = q.toLowerCase();
                  filtered = _tests
                      .where((t) => t.toLowerCase().contains(query))
                      .toList();
                  setLocal(() {});
                }

                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search all tests…',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: applyFilter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final t = filtered[i];
                          return ListTile(
                            title: Text(t),
                            onTap: () => Navigator.pop(ctx, t),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          },
        );
      },
    );
    if (choice != null) {
      setState(() => _testText = choice); // rebuild will sync the field text
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance.collection('test_orders').add({
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'address': _address.text.trim(),
        'test': _testText.trim(), // <- typed OR selected
        'preferredDate': _preferredDate != null
            ? Timestamp.fromDate(_preferredDate!)
            : null,
        'notes': _notes.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'seen': false,
        'source': 'web_landing',
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks! Your test request was submitted.'),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Firebase error: ${e.code}')));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown error — check console')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 720;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services_outlined),
                      const SizedBox(width: 8),
                      const Text(
                        'Book Your Test',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _Grid(
                    isNarrow: isNarrow,
                    children: [
                      _Labeled(
                        'Full Name',
                        TextFormField(
                          controller: _name,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'e.g., Ali Raza',
                          ),
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? 'Enter a valid name'
                              : null,
                        ),
                      ),
                      _Labeled(
                        'Phone',
                        TextFormField(
                          controller: _phone,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'e.g., 03XX-XXXXXXX',
                          ),
                          validator: (v) {
                            final x = (v ?? '').trim();
                            if (x.isEmpty) return 'Required';
                            if (x.length < 7) return 'Too short';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _Grid(
                    isNarrow: isNarrow,
                    children: [
                      _Labeled(
                        'Email (optional)',
                        TextFormField(
                          controller: _email,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'you@example.com',
                          ),
                          validator: (v) {
                            final x = (v ?? '').trim();
                            if (x.isEmpty) return null;
                            final ok = RegExp(
                              r'^[^@]+@[^@]+\.[^@]+$',
                            ).hasMatch(x);
                            return ok ? null : 'Invalid email';
                          },
                        ),
                      ),
                      _Labeled(
                        'Address (optional)',
                        TextFormField(
                          controller: _address,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'House/Street, City',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _Grid(
                    isNarrow: isNarrow,
                    children: [
                      _Labeled(
                        'Select or Type Test',
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue tev) {
                            final q = tev.text.toLowerCase();
                            if (q.isEmpty) return _tests;
                            return _tests.where(
                              (t) => t.toLowerCase().contains(q),
                            );
                          },
                          onSelected: (val) => setState(() => _testText = val),
                          fieldViewBuilder:
                              (
                                context,
                                textController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                // Keep the field in sync with _testText without owning the controller
                                if (textController.text != _testText) {
                                  textController.value = TextEditingValue(
                                    text: _testText,
                                    selection: TextSelection.collapsed(
                                      offset: _testText.length,
                                    ),
                                  );
                                }
                                return TextFormField(
                                  controller: textController,
                                  focusNode: focusNode,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) => _testText = v,
                                  decoration: InputDecoration(
                                    hintText: 'Start typing or pick from list',
                                    suffixIcon: IconButton(
                                      tooltip: 'Browse all tests',
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onPressed: _openAllTestsSheet,
                                    ),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Please specify a test'
                                      : null,
                                );
                              },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 320,
                                    minWidth: 300,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final opt = options.elementAt(index);
                                      return ListTile(
                                        title: Text(opt),
                                        onTap: () => onSelected(opt),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      _Labeled(
                        'Preferred Date (optional)',
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              hintText: 'Choose a date',
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event),
                                const SizedBox(width: 8),
                                Text(
                                  _preferredDate == null
                                      ? 'Not set'
                                      : '${_preferredDate!.year}-${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.day.toString().padLeft(2, '0')}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _Labeled(
                    'Notes (optional)',
                    TextFormField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Any special instructions or symptoms',
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children, required this.isNarrow});
  final List<Widget> children;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 12),
        Expanded(child: children[1]),
      ],
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
