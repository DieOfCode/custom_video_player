import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nefect_video_player_method_channel.dart';

abstract class NeVideoPlayerPlatform extends PlatformInterface {
  /// Constructs a NefectVideoPlayerPlatform.
  NeVideoPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static NeVideoPlayerPlatform _instance = MethodChannelNeVideoPlayer();

  /// The default instance of [NeVideoPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelNeVideoPlayer].
  static NeVideoPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NeVideoPlayerPlatform] when
  /// they register themselves.
  static set instance(NeVideoPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

}
