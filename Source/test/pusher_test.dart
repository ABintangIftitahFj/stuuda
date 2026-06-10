import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/services/pusher_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PusherService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('PusherService is a singleton', () {
      final instance1 = PusherService();
      final instance2 = PusherService();
      expect(instance1, same(instance2));
    });

    // Note: Actually testing initPusher would require mocking PusherChannelsFlutter
    // which is a bit complex for a quick test since it's a plugin with many native calls.
    // However, we've added logging to verify it during manual testing.
  });
}
