String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  } else if (!value.endsWith('@gmail.com')) {
    return 'Email must end with @gmail.com';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  } else if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
  } else if (!RegExp(r'^\d+$').hasMatch(value)) {
    return 'Phone number must be numeric';
  } else if (value.length > 12) {
    return 'Phone number must not exceed 12 digits';
  } else if (value.length < 12) {
    return 'Phone number must have at least 12 digits';
  }
  return null;
}
