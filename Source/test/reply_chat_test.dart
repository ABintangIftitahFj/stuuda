import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stundaa/screens/whatsapp/componets/message_bubble.dart';
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';

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

  test('canReplyToMessage only allows non-system messages with wamid', () {
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
      isFalse,
    );
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
