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

    test('getChatLabels parses users and labels', () async {
      final mockResponse = {
        'reaction': 1,
        'data': {
          'vendorMessagingUsers': [
            {'_id': 1, '_uid': 'u1', 'full_name': 'Agent 1'}
          ],
          'listOfAllLabels': [
            {'_id': 10, '_uid': 'l1', 'title': 'Important', 'text_color': '#FF0000'}
          ]
        }
      };

      data_transport.httpClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      await controller.getChatLabels();

      expect(controller.vendorMessagingUsers.length, 1);
      expect(controller.vendorMessagingUsers[0].name, 'Agent 1');
      expect(controller.labelsDropdownItems.length, 1);
      expect(controller.labelsDropdownItems[0]['value'], 'Important');
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

      // Context is needed for data_transport.post, we'll use a dummy context if possible or mock the data_transport
      // Actually data_transport.post uses context for showing messages, but it can be null if handled.
      // Looking at ContactInfoRepository.updateContactProfile, it passes context.
      
      await controller.updateProfileApi(
        context: null as dynamic, // Use dynamic to bypass type check for null
        firstNameValue: 'Updated Name',
        emailValue: 'new@email.com',
        languageCodeValue: 'en',
      );

      expect(controller.firstName.value, 'Updated Name');
      expect(controller.emailV.value, 'new@email.com');
      expect(controller.languageCode.value, 'en');
    });
  });
}
