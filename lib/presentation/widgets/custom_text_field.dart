import 'package:flutter/material.dart';

enum TextFieldType {
  text,
  email,
  password,
  name,
  phone,
  number,
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixPressed;
  final int? maxLines;
  final String? hintText;
  final TextFieldType type;
  final bool isRequired;
  final int? minLength;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onSuffixPressed,
    this.maxLines = 1,
    this.hintText,
    this.type = TextFieldType.text,
    this.isRequired = true,
    this.minLength,
    this.maxLength,
  });

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return isRequired ? '$labelText is required' : null;
    }

    // Apply custom validator if provided
    if (validator != null) {
      return validator!(value);
    }

    // Apply built-in validators based on type
    switch (type) {
      case TextFieldType.email:
        // Email validation pattern
        final emailPattern = RegExp(
          r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
        );
        if (!emailPattern.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        // Check for common typos in domain names
        final lowerValue = value.toLowerCase();
        if (lowerValue.contains('gmail.comm') || lowerValue.contains('gmail.con') || lowerValue.contains('gmail.cm') || lowerValue.contains('gmail.co')) {
          return 'Did you mean gmail.com?';
        }
        if (lowerValue.contains('yahoo.comm') || lowerValue.contains('yahoo.con') || lowerValue.contains('yahoo.cm') || lowerValue.contains('yahoo.co')) {
          return 'Did you mean yahoo.com?';
        }
        if (lowerValue.contains('hotmail.comm') || lowerValue.contains('hotmail.con') || lowerValue.contains('hotmail.cm') || lowerValue.contains('hotmail.co')) {
          return 'Did you mean hotmail.com?';
        }
        break;

      case TextFieldType.password:
        if (value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return 'Password must contain at least one uppercase letter';
        }
        if (!RegExp(r'[a-z]').hasMatch(value)) {
          return 'Password must contain at least one lowercase letter';
        }
        if (!RegExp(r'[0-9]').hasMatch(value)) {
          return 'Password must contain at least one number';
        }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return 'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)';
        }
        // Check for common weak passwords
        final lowerValue = value.toLowerCase();
        if (lowerValue == 'password123' || lowerValue == '12345678' || lowerValue == 'qwerty123' || lowerValue == 'admin123') {
          return 'This is a common password. Please choose a stronger one';
        }
        break;

      case TextFieldType.name:
        // Name validation pattern
        final namePattern = RegExp(r"^[A-Za-z][A-Za-z\s'-]*[A-Za-z]$");
        if (!namePattern.hasMatch(value)) {
          return 'Name can only contain letters, spaces, hyphens, and apostrophes. Must start and end with a letter';
        }
        if (RegExp(r'\s{2,}').hasMatch(value)) {
          return 'Name cannot contain consecutive spaces';
        }
        if (RegExp(r'-{2,}').hasMatch(value)) {
          return 'Name cannot contain consecutive hyphens';
        }
        if (RegExp(r"'{2,}").hasMatch(value)) {
          return 'Name cannot contain consecutive apostrophes';
        }
        if (value.length < 2) {
          return 'Name is too short';
        }
        if (value.length > 50) {
          return 'Name is too long';
        }
        break;

      case TextFieldType.phone:
        // Phone validation pattern
        final phonePattern = RegExp(r'^\+?[\d\s-]{10,}$');
        if (!phonePattern.hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        // Remove all non-digit characters and check length
        final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length < 10) {
          return 'Phone number must contain at least 10 digits';
        }
        break;

      case TextFieldType.number:
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        break;

      case TextFieldType.text:
        // No specific validation for text type
        break;
    }

    // Check minimum length if specified
    if (minLength != null && value.length < minLength!) {
      return '$labelText must be at least $minLength characters';
    }

    // Check maximum length if specified
    if (maxLength != null && value.length > maxLength!) {
      return '$labelText must not exceed $maxLength characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType ?? _getKeyboardType(),
      validator: _validateField,
      maxLines: maxLines,
      maxLength: maxLength,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: isRequired ? "$labelText *" : labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixPressed,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.text:
      case TextFieldType.name:
      case TextFieldType.password:
        return TextInputType.text;
    }
  }
}
