import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nefect_video_player_platform_interface.dart';

/// An implementation of [NeVideoPlayerPlatform] that uses method channels.
class MethodChannelNeVideoPlayer extends NeVideoPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nefect_video_player');
}
