import Flutter
import UIKit
import SwiftUI


@available(iOS 13.0, *)
public class NefectVideoPlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "nefect_video_player", binaryMessenger: registrar.messenger())
//    let instance = NefectVideoPlayerPlugin()
//    registrar.addMethodCallDelegate(instance, channel: channel)
      
      registrar.register(FLNativeViewFactory(messenger: registrar.messenger()), withId: "plugins.orcadev/nefect_video_player")

  }

}



@available(iOS 13.0, *)
class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return PlayerNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@available(iOS 13.0, *)
class PlayerNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        createNativeView(view: _view, arguments: args)
    }
    
    func view() -> UIView {
        return _view
    }
    
    
    func createNativeView(view _view: UIView, arguments args: Any?){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let allWindows = windowScene.windows
            // Use allWindows as needed
            
            let keywindows = allWindows.first(where: { $0.isKeyWindow }) ?? allWindows.first
            let topController = keywindows?.rootViewController
            let vc = UIHostingController(rootView: ContentView())
            let swiftuiView = vc.view!
            swiftuiView.translatesAutoresizingMaskIntoConstraints=false
            topController!.addChild(vc)
            _view.addSubview (swiftuiView)
            
            NSLayoutConstraint.activate([
                swiftuiView.leadingAnchor.constraint(equalTo:_view.leadingAnchor),
                swiftuiView.trailingAnchor.constraint(equalTo:_view.trailingAnchor),
                swiftuiView.topAnchor.constraint(equalTo:_view.topAnchor),
                swiftuiView.bottomAnchor.constraint(equalTo:_view.bottomAnchor),
            ])
            vc.didMove (toParent: topController)
        }
    }
}
