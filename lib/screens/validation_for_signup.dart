import 'package:cloud_firestore/cloud_firestore.dart';
Future<String?> validateUsername(String? value) async {
  if (value == null || value.isEmpty) {
    return 'Please enter your username';
  }

  // Check if the username already exists by querying the Firestore collection
  final result = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: value)
      .limit(1)
      .get();

  if (result.docs.isNotEmpty) {
    return 'Username already taken';
  }

  return null; 
}




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
  } else if (value.length < 7) {
    return 'Password must be at least 7 characters long';
  } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return 'Password is weak, please include at least one special character';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
  } else if (!RegExp(r'^\d+$').hasMatch(value)) {
    return 'Phone number must be numeric';
  } else if (value.length != 11 || !value.startsWith('03')) {
    return 'Enter a valid Pakistani phone number (e.g., 03XXXXXXXXX)';
  }
  return null;
}
