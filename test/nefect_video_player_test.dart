import 'package:flutter_test/flutter_test.dart';
import 'package:nefect_video_player/nefect_video_player_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNefectVideoPlayerPlatform with MockPlatformInterfaceMixin implements NeVideoPlayerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NeVideoPlayerPlatform initialPlatform = NeVideoPlayerPlatform.instance;
}
