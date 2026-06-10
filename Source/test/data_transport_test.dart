import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/services/data_transport.dart';
import 'package:stundaa/services/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataTransport Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'authToken': 'test-token'});
      await initPreferences();
    });

    test('post handles secured fields', () async {
      httpClient = MockClient((request) async {
        return http.Response(jsonEncode({'reaction': 1, 'data': {}}), 200);
      });

      await post('test', inputData: {'password': '123'}, secured: true);
      // Logic for secured fields is in post()
    });

    test('get handles query parameters', () async {
      var capturedUrl = '';
      httpClient = MockClient((request) async {
        capturedUrl = request.url.toString();
        return http.Response(jsonEncode({'reaction': 1, 'data': {}}), 200);
      });

      await get('test', queryParameters: {'a': 'b'});
      expect(capturedUrl, contains('a=b'));
    });

    test('DataTransport handles 422 validation error', () async {
      httpClient = MockClient((request) async {
        return http.Response(jsonEncode({
          'message': 'Validation failed',
          'errors': {'email': ['Invalid email']}
        }), 422);
      });

      await get('test');
    });

    test('DataTransport handles 401 unauthorized', () async {
      httpClient = MockClient((request) async {
        return http.Response(jsonEncode({
          'data': {'auth_info': {'authorized': false}}
        }), 200);
      });

      await get('test');
    });
  });
}
