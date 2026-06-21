import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stundaa/screens/whatsapp/componets/message_bubble.dart';
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (_) async => null,
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      null,
    );
  });

  tearDown(Get.reset);

  setUp(() {
    sharedPreferencesCache = null;
    SharedPreferences.setMockInitialValues({});
  });

  test('findMessageByUid returns the matching parsed message', () {
    final controller = ChatboxController();
    final originalMessage = <String, dynamic>{
      'uid': 'message-uid',
      'content': 'Original message',
    };
    controller.holduser.add(originalMessage);

    expect(controller.findMessageByUid('message-uid'), same(originalMessage));
    expect(controller.findMessageByUid('missing-uid'), isNull);
  });

  test('addQuotedMessageWamid adds the selected reply metadata', () {
    final controller = ChatboxController();
    controller.setReplyMessage({
      'uid': 'message-uid',
      'wamid': 'wamid-123',
      'content': 'Original message',
    });
    final payload = <String, dynamic>{'message_body': 'Reply'};

    controller.addQuotedMessageWamid(payload);

    expect(payload['quoted_message_wamid'], 'wamid-123');
  });

  test('addQuotedMessageWamid skips payload when selected message has no wamid',
      () {
    final controller = ChatboxController();
    controller.setReplyMessage({
      'uid': 'message-uid',
      'content': 'Original message',
    });
    final payload = <String, dynamic>{'message_body': 'Reply'};

    controller.addQuotedMessageWamid(payload);

    expect(payload.containsKey('quoted_message_wamid'), isFalse);
  });

  test('canReplyToMessage allows non-system messages', () {
    final controller = ChatboxController();

    expect(
      controller.canReplyToMessage({
        'isSystem': false,
        'wamid': 'wamid-123',
      }),
      isTrue,
    );
    expect(
      controller.canReplyToMessage({
        'isSystem': true,
        'wamid': 'wamid-123',
      }),
      isFalse,
    );
    expect(
      controller.canReplyToMessage({
        'isSystem': false,
        'wamid': '',
      }),
      isTrue,
    );
  });

  test('active contact helpers track the opened chat only', () {
    final controller = ChatboxController();
    addTearDown(controller.dispose);

    controller.setUserId('contact-123');

    expect(controller.isActiveContact('contact-123'), isTrue);
    expect(controller.isActiveContact('contact-456'), isFalse);

    controller.clearActiveContact('contact-456');
    expect(controller.userId, 'contact-123');
    expect(controller.isActiveContact('contact-123'), isTrue);

    controller.clearActiveContact('contact-123');
    expect(controller.userId, 'contact-123');
    expect(controller.isActiveContact('contact-123'), isFalse);
  });

  testWidgets('sendTextMessage sends quoted wamid for reply payload',
      (tester) async {
    final controller = ChatboxController();
    addTearDown(controller.dispose);
    controller.userId = 'contact-123';
    controller.setReplyMessage({
      'uid': 'message-uid',
      'wamid': 'wamid-123',
      'content': 'Original message',
    });
    Map<String, dynamic>? sentPayload;

    data_transport.httpClient = MockClient((request) async {
      if (request.url.path.endsWith('/api/vendor/whatsapp/contact/chat/send')) {
        sentPayload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'reaction': 1,
            'data': {
              'log_message': {
                '_uid': 'message-uid',
                'wamid': 'wamid-123',
                'message': 'Reply message',
                'is_incoming_message': 0,
                'is_system_message': 0,
                'status': 'accepted',
                'messaged_at': '2026-06-21T14:55:00Z',
              }
            }
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({'reaction': 1, 'client_models': {}}),
        200,
      );
    });

    await tester.pumpWidget(
      Builder(
        builder: (context) => MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () =>
                  controller.sendTextMessage(context, ' Reply message '),
              child: const Text('Send'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Send'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(sentPayload?['contact_uid'], 'contact-123');
    expect(sentPayload?['message_body'], 'Reply message');
    expect(sentPayload?['quoted_message_wamid'], 'wamid-123');
    expect(controller.selectedReplyMessage.value, isNull);
  });

  testWidgets('sendTextMessage keeps local reply but skips local quoted id',
      (tester) async {
    final controller = ChatboxController();
    addTearDown(controller.dispose);
    controller.userId = 'contact-123';
    controller.setReplyMessage({
      'uid': 'local-original',
      'wamid': 'local-original',
      'content': 'Local original message',
    });
    Map<String, dynamic>? sentPayload;
    final sendCompleter = Completer<void>();

    data_transport.httpClient = MockClient((request) async {
      if (request.url.path.endsWith('/api/vendor/whatsapp/contact/chat/send')) {
        sentPayload = jsonDecode(request.body) as Map<String, dynamic>;
        await sendCompleter.future;
        return http.Response(
          jsonEncode({
            'reaction': 1,
            'data': {
              'log_message': {
                '_uid': 'local-original',
                'wamid': '',
                'message': 'Reply local',
                'is_incoming_message': 0,
                'is_system_message': 0,
                'status': 'accepted',
                'messaged_at': '2026-06-21T14:55:00Z',
              }
            }
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({'reaction': 1, 'client_models': {}}),
        200,
      );
    });

    await tester.pumpWidget(
      Builder(
        builder: (context) => MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () =>
                  controller.sendTextMessage(context, 'Reply local'),
              child: const Text('Send'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Send'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(sentPayload?.containsKey('quoted_message_wamid'), isFalse);
    expect(controller.holduser.first['repliedToMessageUid'], 'local-original');
    sendCompleter.complete();
    await tester.pump(const Duration(milliseconds: 100));
  });

  test('buildReplyPreviewText strips html and falls back to media label', () {
    final controller = ChatboxController();

    expect(
      controller.buildReplyPreviewText({
        'content': '<p>Hello <strong>world</strong></p>',
      }),
      'Hello world',
    );
    expect(
      controller.buildReplyPreviewText({
        'content': '   ',
        'media': {'type': 'image'},
      }),
      'Photo',
    );
    expect(
      controller.buildReplyPreviewText(null, fallback: 'Original message'),
      'Original message',
    );
  });

  testWidgets('quoted bubble renders original message preview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            isIncoming: false,
            isSystem: false,
            templateMessage: '',
            data: const {},
            hasQuotedMessage: true,
            quotedSenderName: 'Bintang',
            quotedMessage: const {
              'content': 'Original message',
              'media': <String, dynamic>{},
            },
          ),
        ),
      ),
    );

    expect(find.text('Replying to Bintang'), findsOneWidget);
    expect(find.text('Original message'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('quoted bubble renders fallback when original is not loaded',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            isIncoming: false,
            isSystem: false,
            templateMessage: '',
            data: {},
            hasQuotedMessage: true,
          ),
        ),
      ),
    );

    expect(find.text('Original message is not loaded'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('quoted bubble invokes tap callback', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            isIncoming: false,
            isSystem: false,
            templateMessage: '',
            data: const {},
            hasQuotedMessage: true,
            onQuotedMessageTap: () => wasTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Original message is not loaded'));

    expect(wasTapped, isTrue);
    await tester.pump(const Duration(seconds: 3));
  });
}
