import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NeVideoPlayer extends StatelessWidget {
  final void Function(int id) onPlatformViewCreated;
  const NeVideoPlayer({super.key, required this.onPlatformViewCreated});

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'plugins.orcadev/nefect_video_player',
          onPlatformViewCreated: onPlatformViewCreated,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'plugins.orcadev/nefect_video_player',
          onPlatformViewCreated: onPlatformViewCreated,
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }
}
