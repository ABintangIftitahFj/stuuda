import 'dart:async';
import 'package:stundaa/services/data_transport.dart' as data_transport;

class CommonRepository {
  Future<dynamic> submitContactForm({
    required String fullName,
    required String email,
    required String subject,
    required String message,
  }) {
    final Completer<dynamic> completer = Completer<dynamic>();

    data_transport.post(
      'contact-process', // This matches the route name/path in web.php
      inputData: {
        'full_name': fullName,
        'email': email,
        'subject': subject,
        'message': message,
        'source': 'mobile_app',
      },
      onSuccess: (responseData) {
        if (!completer.isCompleted) {
          completer.complete(responseData);
        }
      },
      onFailed: (responseData) {
        if (!completer.isCompleted) {
          completer.completeError(responseData ?? 'Failed to submit contact form');
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'Failed to submit contact form');
        }
      },
    );

    return completer.future;
  }
}
