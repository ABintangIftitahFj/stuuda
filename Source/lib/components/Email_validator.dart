bool isValidEmail(String? value) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return value != null && emailRegex.hasMatch(value);
}