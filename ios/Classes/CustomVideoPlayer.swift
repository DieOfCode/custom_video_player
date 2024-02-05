//
//  CustomVideoPlayer.swift
//  nefect_video_player
//
//  Created by Иван Свирский on 24.01.24.
//

import Foundation
import SwiftUI
import AVKit

/// Custom Video Player
struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var showFullScreen: Bool
    @Binding var fullScreenTapped: Bool
    
    var player: AVPlayer
    

    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.canStartPictureInPictureAutomaticallyFromInline = true
   
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
        chooseScreenType(uiViewController)
    }
    
    
    private func chooseScreenType(_ controller: AVPlayerViewController) {
        print("chooseScreenType", self.showFullScreen)
//        if(self.fullScreenTapped){
//            enterFull(controller)
//        }
//
        self.showFullScreen ? enterFull(controller) : exitFull(controller)
        
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
        Coordinator(self)
    }
    
    class Coordinator {
        var previousShowFullScreen: Bool
        
        init(_ parent: CustomVideoPlayer) {
            self.previousShowFullScreen = parent.showFullScreen
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


