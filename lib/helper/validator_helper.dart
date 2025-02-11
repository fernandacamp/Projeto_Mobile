class ValidatorHelper {

  static bool validateEmail(String value) {
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    
    return emailPattern.hasMatch(value);
  }
}