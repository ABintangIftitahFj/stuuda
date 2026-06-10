import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/screens/whatsapp/controller/user_info_controller.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserInfoController Tests', () {
    late Userinfocontroller controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      controller = Userinfocontroller();
      controller.setUserId('user-123');
    });

    test('getUserInfo parses data correctly', () async {
      final mockResponse = {
        'reaction': 1,
        'data': {
          'first_name': 'Bintang',
          'wa_id': '628123',
          'email': 'bintang@stund.id',
          'language_code': 'id',
          '__data': {'contact_notes': 'Some notes'}
        }
      };

      data_transport.httpClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      await controller.getUserInfo();

      expect(controller.firstName.value, 'Bintang');
      expect(controller.emailV.value, 'bintang@stund.id');
      expect(controller.notes.value, 'Some notes');
      expect(controller.notesController.text, 'Some notes');
    });

    test('updateProfileApi sends correct data and updates state', () async {
      final mockResponse = {'reaction': 1, 'message': 'Updated'};

      data_transport.httpClient = MockClient((request) async {
        if (request.url.path.contains('vendor/contacts/update-process')) {
          final body = jsonDecode(request.body);
          expect(body['contactIdOrUid'], 'user-123');
          expect(body['first_name'], 'Updated Name');
          expect(body['email'], 'new@email.com');
          expect(body['language_code'], 'en');
          return http.Response(jsonEncode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      await controller.updateProfileApi(
        context: null as dynamic,
        firstNameValue: 'Updated Name',
        emailValue: 'new@email.com',
        languageCodeValue: 'en',
      );

      expect(controller.firstName.value, 'Updated Name');
      expect(controller.emailV.value, 'new@email.com');
      expect(controller.languageCode.value, 'en');
    });

    test('updateProfileApi sends email as empty string when empty', () async {
      final mockResponse = {'reaction': 1, 'message': 'Updated'};

      data_transport.httpClient = MockClient((request) async {
        if (request.url.path.contains('vendor/contacts/update-process')) {
          final body = jsonDecode(request.body);
          expect(body['contactIdOrUid'], 'user-123');
          expect(body['first_name'], 'Updated Name');
          expect(body['email'], ''); // Should be empty string
          return http.Response(jsonEncode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      await controller.updateProfileApi(
        context: null as dynamic,
        firstNameValue: 'Updated Name',
        emailValue: '',
        languageCodeValue: 'en',
      );

      expect(controller.firstName.value, 'Updated Name');
      expect(controller.emailV.value, '');
    });
  });
}
