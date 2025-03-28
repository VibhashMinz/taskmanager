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

    switch (type) {
      case TextFieldType.email:
        final emailPattern = RegExp(
          r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
        );
        if (!emailPattern.hasMatch(value)) {
          return 'Please enter a valid email address';
        }

        // Check for common typos in domain names
        final lowerValue = value.toLowerCase();
        final commonTypos = {
          'gmail.comm': 'gmail.com',
          'gmail.con': 'gmail.com',
          'gmail.cm': 'gmail.com',
          'gmail.co': 'gmail.com',
          'yahoo.comm': 'yahoo.com',
          'yahoo.con': 'yahoo.com',
          'yahoo.cm': 'yahoo.com',
          'yahoo.co': 'yahoo.com',
          'hotmail.comm': 'hotmail.com',
          'hotmail.con': 'hotmail.com',
          'hotmail.cm': 'hotmail.com',
          'hotmail.co': 'hotmail.com',
        };

        final parts = lowerValue.split('@');
        if (parts.length == 2) {
          final domain = parts[1];
          if (commonTypos.containsKey(domain)) {
            return 'Did you mean ${commonTypos[domain]}?';
          }
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
        if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return 'Password must contain at least one special character';
        }

        final lowerValue = value.toLowerCase();
        if (lowerValue == 'password123' || lowerValue == '12345678' || lowerValue == 'qwerty123' || lowerValue == 'admin123') {
          return 'This is a common password. Please choose a stronger one';
        }
        break;

      case TextFieldType.name:
        final namePattern = RegExp(r"^[A-Za-z][A-Za-z\s'-]*[A-Za-z]$");
        if (!namePattern.hasMatch(value)) {
          return 'Invalid name format';
        }
        if (value.length < 2) {
          return 'Name is too short';
        }
        if (value.length > 50) {
          return 'Name is too long';
        }
        break;

      case TextFieldType.phone:
        final phonePattern = RegExp(r'^\+?[0-9]{10,}$');
        if (!phonePattern.hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        break;

      case TextFieldType.number:
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        break;

      case TextFieldType.text:
        break;
    }

    if (minLength != null && value.length < minLength!) {
      return '$labelText must be at least $minLength characters';
    }

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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
      default:
        return TextInputType.text;
    }
  }
}
