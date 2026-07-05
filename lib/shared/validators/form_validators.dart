/// Centralised production-grade validation system for Ascento Abacus.
///
/// All form validators return `null` on success or a user-friendly
/// error message on failure. Compatible with [TextFormField.validator].
class FormValidators {
  FormValidators._();

  // ---------------------------------------------------------------------------
  // Required Field
  // ---------------------------------------------------------------------------

  /// Generic required field check with customisable field name.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates school email addresses.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.emailRequired;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return ValidationMessages.emailInvalid;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Password
  // ---------------------------------------------------------------------------

  /// Validates passwords with configurable strength requirements.
  static String? validatePassword(String? value, {int minLength = 6, bool requireSpecial = false}) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.passwordRequired;
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (requireSpecial && !RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return ValidationMessages.passwordSpecialChar;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return ValidationMessages.passwordDigit;
    }
    return null;
  }

  /// Validates that confirm password matches original password.
  static String? validateConfirmPassword(String? value, String original) {
    final requiredCheck = required(value, 'Confirm password');
    if (requiredCheck != null) return requiredCheck;
    if (value!.trim() != original.trim()) {
      return ValidationMessages.passwordMismatch;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Phone Number
  // ---------------------------------------------------------------------------

  static final _phoneRegex = RegExp(r'^[6-9]\d{9}$');

  /// Validates Indian mobile numbers (10 digits starting with 6-9).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.phoneRequired;
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) {
      return ValidationMessages.phoneInvalid;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // OTP
  // ---------------------------------------------------------------------------

  /// Validates numeric OTP codes of configurable length.
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.otpRequired;
    }
    if (value.trim().length != length || !RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Enter a valid $length-digit OTP code';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Student Enrollment ID
  // ---------------------------------------------------------------------------

  static final _enrollmentRegex = RegExp(r'^ASC-\d{4}-\d{4}$');

  /// Validates Ascento student enrollment ID format: ASC-YYYY-NNNN.
  static String? validateEnrollmentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.enrollmentRequired;
    }
    if (!_enrollmentRegex.hasMatch(value.trim())) {
      return ValidationMessages.enrollmentInvalid;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Fees / Amount
  // ---------------------------------------------------------------------------

  /// Validates a monetary amount (positive decimal number).
  static String? validateAmount(String? value, {double? maxAmount}) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.amountRequired;
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return ValidationMessages.amountInvalid;
    }
    if (maxAmount != null && amount > maxAmount) {
      return 'Amount cannot exceed ₹${maxAmount.toStringAsFixed(0)}';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Name
  // ---------------------------------------------------------------------------

  /// Validates person names (letters and spaces only, 2+ chars).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.nameRequired;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s.']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, and periods';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Generic Length
  // ---------------------------------------------------------------------------

  /// Validates minimum and maximum string length.
  static String? validateLength(String? value, {int? min, int? max, String fieldName = 'Input'}) {
    final requiredCheck = required(value, fieldName);
    if (requiredCheck != null) return requiredCheck;
    if (min != null && value!.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    if (max != null && value!.trim().length > max) {
      return '$fieldName cannot exceed $max characters';
    }
    return null;
  }
}

// =============================================================================
// Validation Error Messages — Centralised constants
// =============================================================================

/// Centralised error message constants for consistent UI text across forms.
class ValidationMessages {
  ValidationMessages._();

  // Email
  static const emailRequired = 'Email address is required';
  static const emailInvalid = 'Please enter a valid email address';

  // Password
  static const passwordRequired = 'Password is required';
  static const passwordShort = 'Password must be at least 6 characters';
  static const passwordSpecialChar = 'Password must include a special character';
  static const passwordDigit = 'Password must include at least one number';
  static const passwordMismatch = 'Passwords do not match';

  // Phone
  static const phoneRequired = 'Phone number is required';
  static const phoneInvalid = 'Enter a valid 10-digit mobile number';

  // OTP
  static const otpRequired = 'OTP verification code is required';
  static const otpInvalid = 'Enter a valid 6-digit OTP code';

  // Enrollment
  static const enrollmentRequired = 'Enrollment ID is required';
  static const enrollmentInvalid = 'Use format: ASC-YYYY-NNNN';

  // Fees
  static const amountRequired = 'Amount is required';
  static const amountInvalid = 'Enter a valid positive amount';

  // Name
  static const nameRequired = 'Name is required';

  // Generic
  static const fieldRequired = 'This field is required';
  static const invalidInput = 'Please enter valid input';
}

// =============================================================================
// String Extension — Convenience validator access
// =============================================================================

/// Extension on [String?] for fluent validator chaining in forms.
///
/// Usage:
/// ```dart
/// TextFormField(validator: (v) => v.isValidEmail)
/// ```
extension StringValidators on String? {
  String? get isValidEmail => FormValidators.validateEmail(this);
  String? get isValidPassword => FormValidators.validatePassword(this);
  String? get isValidPhone => FormValidators.validatePhone(this);
  String? get isValidOtp => FormValidators.validateOtp(this);
  String? get isValidEnrollmentId => FormValidators.validateEnrollmentId(this);
  String? get isValidName => FormValidators.validateName(this);
  String? get isRequired => FormValidators.required(this);
}
