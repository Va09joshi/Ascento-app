import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';
import 'package:ascento_abacus/core/widgets/custom_button.dart';
import 'package:ascento_abacus/core/widgets/custom_textfield.dart';
import 'package:ascento_abacus/core/widgets/responsive_builder.dart';
import 'package:ascento_abacus/shared/validators/form_validators.dart';

class EnquiryView extends StatefulWidget {
  const EnquiryView({super.key});

  @override
  State<EnquiryView> createState() => _EnquiryViewState();
}

class _EnquiryViewState extends State<EnquiryView> {
  final _formKey = GlobalKey<FormState>();
  final _parentNameController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedProgram;
  String? _selectedClassLevel;
  String? _selectedTimeSlot;
  bool _isSubmitting = false;

  static const _programs = [
    'Abacus Foundation',
    'Vedic Maths',
    'Mental Arithmetic',
    'Handwriting Improvement',
    'Combo Learning Plan',
  ];

  static const _classLevels = [
    'Nursery to UKG',
    'Class 1 to 3',
    'Class 4 to 6',
    'Class 7 to 9',
    'Class 10 and above',
  ];

  static const _timeSlots = [
    'Morning batch',
    'Afternoon batch',
    'Evening batch',
    'Weekend only',
    'Need counsellor callback',
  ];

  @override
  void dispose() {
    _parentNameController.dispose();
    _studentNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    _formKey.currentState?.reset();
    _parentNameController.clear();
    _studentNameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _messageController.clear();

    setState(() {
      _isSubmitting = false;
      _selectedProgram = null;
      _selectedClassLevel = null;
      _selectedTimeSlot = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enquiry submitted successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _optionalEmailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return FormValidators.validateEmail(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveBuilder.isMobile(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.creamBg,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ResponsiveContent(
          maxWidth: ResponsiveBuilder.formMaxWidth(context),
          padding: EdgeInsets.fromLTRB(
            ResponsiveBuilder.horizontalPadding(context),
            18.h,
            ResponsiveBuilder.horizontalPadding(context),
            28.h,
          ),
          child: AppCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(18.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enquiry Form',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Fill the details below and our team will contact you.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _AdaptiveFieldRow(
                    isMobile: isMobile,
                    children: [
                      CustomTextField(
                        controller: _parentNameController,
                        label: 'Parent / Guardian Name',
                        hint: 'Enter full name',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: FormValidators.validateName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      CustomTextField(
                        controller: _studentNameController,
                        label: 'Student Name',
                        hint: 'Enter student name',
                        prefixIcon: Icons.child_care_rounded,
                        validator: FormValidators.validateName,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _AdaptiveFieldRow(
                    isMobile: isMobile,
                    children: [
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        hint: '98XXXXXXXX',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: FormValidators.validatePhone,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Optional',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: _optionalEmailValidator,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  AppDropdown<String>(
                    value: _selectedProgram,
                    items: _programs,
                    label: 'Program Interested In',
                    hint: 'Select course',
                    prefixIcon: Icons.auto_stories_rounded,
                    itemLabel: (value) => value,
                    onChanged: (value) => setState(() => _selectedProgram = value),
                    validator: (value) =>
                        value == null ? 'Please select a program' : null,
                  ),
                  SizedBox(height: 14.h),
                  _AdaptiveFieldRow(
                    isMobile: isMobile,
                    children: [
                      AppDropdown<String>(
                        value: _selectedClassLevel,
                        items: _classLevels,
                        label: 'Student Class Range',
                        hint: 'Choose class group',
                        prefixIcon: Icons.groups_2_outlined,
                        itemLabel: (value) => value,
                        onChanged: (value) =>
                            setState(() => _selectedClassLevel = value),
                        validator: (value) =>
                            value == null ? 'Please select a class group' : null,
                      ),
                      AppDropdown<String>(
                        value: _selectedTimeSlot,
                        items: _timeSlots,
                        label: 'Preferred Timing',
                        hint: 'Choose slot',
                        prefixIcon: Icons.schedule_rounded,
                        itemLabel: (value) => value,
                        onChanged: (value) =>
                            setState(() => _selectedTimeSlot = value),
                        validator: (value) =>
                            value == null ? 'Please select a time slot' : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  CustomTextField(
                    controller: _messageController,
                    label: 'Message',
                    hint: 'Write your requirement here',
                    prefixIcon: Icons.edit_note_rounded,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 4,
                    maxLines: 5,
                    validator: (value) => FormValidators.validateLength(
                      value,
                      min: 12,
                      max: 240,
                      fieldName: 'Message',
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomButton(
                    text: 'Submit Enquiry',
                    icon: Icons.send_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submitForm,
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

class _AdaptiveFieldRow extends StatelessWidget {
  final bool isMobile;
  final List<Widget> children;

  const _AdaptiveFieldRow({
    required this.isMobile,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) SizedBox(height: 14.h),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index != children.length - 1) SizedBox(width: 14.w),
        ],
      ],
    );
  }
}
