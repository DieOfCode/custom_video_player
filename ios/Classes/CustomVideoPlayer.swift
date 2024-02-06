//
//  CustomVideoPlayer.swift
//  nefect_video_player
//
//  Created by Иван Свирский on 24.01.24.
//

import Foundation
import SwiftUI
import AVKit
import Combine


/// Custom Video Player
struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var showFullScreen: Bool
    @Binding var fullScreenTapped: Bool
    
    var playerViewModel: PlayerViewModel
    var player: AVPlayer
    

    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomVideoPlayer>) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.canStartPictureInPictureAutomaticallyFromInline = true
    
        context.coordinator.playerController = controller
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
        chooseScreenType(uiViewController)
    }
    
    
    private func chooseScreenType(_ controller: AVPlayerViewController) {
        print("chooseScreenType", self.showFullScreen)
        if(self.fullScreenTapped){
            enterFull(controller)
        }
    }
    
    
    func enterFull(_ controller: AVPlayerViewController) {
        controller.showsPlaybackControls = true
        controller.enterFullScreen(animated: true)
    }
    
    private func exitFull(_ controller: AVPlayerViewController) {
        controller.showsPlaybackControls = false
        controller.exitFullScreen(animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {

                
        weak var playerController: AVPlayerViewController? {
            didSet {
                playerController?.delegate = self
            }
        }
        
    

        private var subscriber: AnyCancellable? = nil
        
        override init() {
            super.init()
//            self.previousShowFullScreen = parent.showFullScreen
            subscriber = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                .sink { [weak self] _ in
                    self?.rotated()
                }
        }

        func rotated() {
            if UIDevice.current.orientation.isLandscape {
                self.enterFullScreen(animated: true)
            } else {
                self.exitFullScreen(animated: true)
            }
        }

        func enterFullScreen(animated: Bool) {
            playerController?.showsPlaybackControls = true
            playerController?.perform(NSSelectorFromString("enterFullScreenAnimated:completionHandler:"), with: animated, with: nil)
        }

        func exitFullScreen(animated: Bool) {
            playerController?.showsPlaybackControls = false
            playerController?.perform(NSSelectorFromString("exitFullScreenAnimated:completionHandler:"), with: animated, with: nil)
        }

        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {

            // The system pauses when returning from full screen, we need to 'resume' manually.
            coordinator.animate(alongsideTransition: nil) { transitionContext in
                self.playerController?.player?.play()
            }
        }
    }
    
    
    
    
}


extension AVPlayerViewController {
    func enterFullScreen(animated: Bool) {
        print("Enter full screen")
        perform(NSSelectorFromString("enterFullScreenAnimated:completionHandler:"), with: animated, with: nil)
    }
    
    func exitFullScreen(animated: Bool) {
        print("Exit full screen")
        perform(NSSelectorFromString("exitFullScreenAnimated:completionHandler:"), with: animated, with: nil)
    }
}


