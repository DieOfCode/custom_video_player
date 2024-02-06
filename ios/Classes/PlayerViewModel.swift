//
//  PlayerViewModel.swift
//  nefect_video_player
//
//  Created by Иван Свирский on 30.01.24.
//

import Foundation
import AVFoundation


final class PlayerViewModel:ObservableObject{
    @Published var _player: AVPlayer? = AVPlayer()
    
    var player: AVPlayer? {
          get {
              return _player
          }
          set {
              guard _player != newValue else { return }
              _player = newValue
          }
      }
    @Published var showPIP: Bool = false
    @Published var showPlayerControls: Bool = false
    @Published var isPlaying: Bool = false
    
    @Published var isFinishedPlaying: Bool = false
    /// Video Seeker Properties
    @Published var isDragging: Bool = false
    @Published var isSeeking: Bool = false
    @Published var progress: CGFloat = 0
    @Published var lastDraggedProgress: CGFloat = 0
    @Published var isObserverAdded: Bool = false
    
    /// Rotation Properties
    @Published var isRotated: Bool = false
    @Published var deviceRotation: UIDeviceOrientation = UIDevice.current.orientation
    /// Rate select Properties
    @Published var showSelectRate:Bool = false
    @Published var selectedRate:Resolution = Resolution.p480
    ///Show full screen
    @Published var showFullScreen:Bool = false
    @Published var fullScreenTapped:Bool = false

    
    func setCurrentPlayer(_ url:String,_ startTime:Double? = nil){
        self.player!.replaceCurrentItem(with:AVPlayerItem(url: URL(string: url)!))
        if(startTime != nil){
            self.player?.seek(to: CMTime(seconds: startTime!, preferredTimescale: 1) ,
                              toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
                              toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1))
        }
    }
    
    func changeShowPlayerControl(){
        showPlayerControls = !showPlayerControls
    }
    
    func turnOffPlayerControl(){
        showPlayerControls = false
        
    }
    
    func selectResolution(resolution:Resolution){
        
       selectedRate = resolution
        player?.currentItem?.preferredPeakBitRate = selectedRate.bitrateValue
        showSelectRate = false
        
    }
    
}
