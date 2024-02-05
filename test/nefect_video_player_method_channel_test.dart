import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nefect_video_player/nefect_video_player_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNeVideoPlayer platform = MethodChannelNeVideoPlayer();
  const MethodChannel channel = MethodChannel('nefect_video_player');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });
}
