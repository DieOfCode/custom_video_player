//
//  PlayerView.swift
//  nefect_video_player
//
//  Created by Иван Свирский on 24.01.24.
//

import SwiftUI
import AVKit



struct PlayerView: View {
    var size: CGSize
    var safeArea: EdgeInsets
    
    
    @StateObject private var playerVM :PlayerViewModel = PlayerViewModel()
    
    
    
    @State private var timeoutTask: DispatchWorkItem?
    
    /// Video Seeker Properties
    @GestureState private var isDragging: Bool = false
    @State private var thumbnailFrames: [UIImage] = []
    @State private var draggingImage: UIImage?
    @State private var playerStatusObserver: NSKeyValueObservation?
    @State private var customVideoPlayer: CustomVideoPlayer?
    
    
    init(videoPath:String,size: CGSize,safeArea: EdgeInsets, startTime:Double? = nil) {
        self.size = size
        self.safeArea = safeArea
    }
    
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        
        VStack(spacing: 0) {
            /// Swapping Size When Rotated
            let videoPlayerSize: CGSize = .init(width: playerVM.isRotated ? size.height : size.width, height: playerVM.isRotated ? size.width : (size.height / 3.5))
            
            /// Custom Vide Player
            ZStack {
                if let player = playerVM.player {
                    CustomVideoPlayer(showFullScreen: $playerVM.showFullScreen, fullScreenTapped: $playerVM.fullScreenTapped,playerViewModel:playerVM,player: player)
                        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                            DispatchQueue.main.async {
                                print("change rotation->",UIDevice.current.orientation.rawValue)
                                if UIDevice.current.orientation.isLandscape {
                                    print("landscape")
                                    playerVM.showFullScreen = true
                                } else {
                                    print("portrait")
                                    playerVM.showFullScreen = false
                                }
                            }
                        }
                        .onChange(of: player.timeControlStatus){
                            newValue in
                            if(newValue == .playing){
                                playerVM.isPlaying = true
                            }else{
                                playerVM.isPlaying = false
                            }
                            
                        }
                        .onChange(of: playerVM.fullScreenTapped){ newValue in
                        
                                playerVM.fullScreenTapped = newValue
                            if(newValue){
                                playerVM.fullScreenTapped = false
                            }
                        
                    
                        }
                        .edgesIgnoringSafeArea(playerVM.isRotated ? .all : .bottom)
                        .overlay {
                            Rectangle()
                                .fill(.black.opacity(0.4))
                                .opacity(playerVM.showPlayerControls || isDragging ? 1 : 0)
                            
                                .animation(.easeInOut(duration: 0.35), value: isDragging)
                                .overlay {
                                    PlayBackControls()
                                }
                        }
                        .overlay(content: {
                            HStack(spacing: 60) {
                                DoubleTapSeek {
                                    /// Seeking 15 sec Backward
                                    let seconds = player.currentTime().seconds - 15
                                    player.seek(to: .init(seconds: seconds, preferredTimescale: 600))
                                }
                                
                                DoubleTapSeek(isForward: true) {
                                    /// Seeking 15 sec Forward
                                    let seconds = player.currentTime().seconds + 15
                                    player.seek(to: .init(seconds: seconds, preferredTimescale: 600))
                                }
                            }
                        })
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                playerVM.changeShowPlayerControl()
                                if playerVM.showSelectRate {
                                    playerVM.showSelectRate = !playerVM.showSelectRate
                                }
                            }
                            
                            /// Timing Out Controls, Only If the Video is Playing
                            if playerVM.isPlaying {
                                timeoutControls()
                            }
                        }
                        .overlay(alignment: .bottomLeading, content: {
//                            SeekerThumbnailView(videoPlayerSize)
//                                .offset(y: playerVM.isRotated ? -105 : -60)
                        })
                        .overlay(alignment: .bottom) {
                            ZStack{
                                VideoSeekerView(videoPlayerSize)
                                    .offset(y: playerVM.isRotated ? 0 : 0)
                            }
                            
                        }.overlay(alignment: .bottomTrailing){
                            RateSelectorView(videoPlayerSize,playerVM.selectedRate)
                        }
                }
            }
            .background(content: {
                Rectangle()
                    .fill(.black)
                /// Since View is Rotated the Trailing side is Bottom
                /// Since View is Rotated the Leading side is Top
                    .padding(playerVM.deviceRotation == .landscapeRight ? .leading : .trailing, playerVM.isRotated ? -safeArea.bottom : 0)
                    .padding(playerVM.deviceRotation == .landscapeRight ? .trailing : .leading, playerVM.isRotated ? -safeArea.top : 0)
            })
            .gesture(
                DragGesture()
                    .onEnded({ value in
                        if -value.translation.height > 100 {
                            /// Rotate Player
                            withAnimation(.easeInOut(duration: 0.2)) {
                                playerVM.isRotated = true
                            }
                        } else {
                            /// Go To Normal Position
                            withAnimation(.easeInOut(duration: 0.2)) {
                                playerVM.isRotated = false
                            }
                        }
                    })
            )
            .frame(width: videoPlayerSize.width, height: videoPlayerSize.height)
            /// To Avoid Other View Expansion Set it;s Native View height
            .frame(width: size.width, height: size.height / 3.5, alignment: playerVM.deviceRotation == .landscapeRight ? .bottomTrailing : .bottomLeading)
            .offset(y: playerVM.isRotated ? -((size.height) / 3.5) : 0)
            .rotationEffect(.init(degrees: playerVM.isRotated ? (playerVM.deviceRotation == .landscapeRight ? -90 : 90) : 0), anchor: playerVM.deviceRotation == .landscapeRight ? .topTrailing : .topLeading)
            /// Making it Top View
            .zIndex(10000)
        }
        .padding(.top, safeArea.top)
        .onAppear {
            self.playerVM.setCurrentPlayer("http://stream.nefiktivnoe.ru/lections/2229/2230/index.m3u8",40)
            setAudioSessionCategory(to: .playback)
            guard !playerVM.isObserverAdded else { return }
            /// Adding Observer to update seeker when the video is Playing
            playerVM.player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 600), queue: .main, using: { time in
                /// Calculating Video Progress
                if let currentPlayerItem = playerVM.player?.currentItem {
                    let totalDuration = currentPlayerItem.duration.seconds
                    guard let currentDuration = playerVM.player?.currentTime().seconds else { return }
                    
                    let calculatedProgress = currentDuration / totalDuration
                    
                    if !playerVM.isSeeking {
                        playerVM.progress = calculatedProgress
                        playerVM.lastDraggedProgress = playerVM.progress
                    }
                    
                    if calculatedProgress == 1 {
                        /// Video Finished Playing
                        ///
                        
                        playerVM.isFinishedPlaying = true
                        playerVM.isPlaying = false
                    }
                }
            })
            
            playerVM.isObserverAdded = true
            
            /// Before Generating Thumbnails, Check if the Video is Loaded
            playerStatusObserver = playerVM.player?.observe(\.status, options: .new, changeHandler: { player, _ in
                if player.status == .readyToPlay && thumbnailFrames.isEmpty {
                    generateThumbnailFrames()
                }
            })
        }
        .onDisappear {
            setAudioSessionCategory(to: .playback)
            /// Clearing Observers
            playerStatusObserver?.invalidate()
            /// When You're Closing the View Don't Forgot to set thumbnailFrames to Empty
            thumbnailFrames = []
        }
        .onChange(of: scenePhase, perform: { newValue in
            if newValue == .background && playerVM.isPlaying {
                playerVM.isPlaying = false
            }
        })
        .onChange(of: playerVM.progress) { newValue in
            if newValue != 1 {
                playerVM.isFinishedPlaying = false
            }
        }
        .onRotate { rotation in
            if rotation.isValidInterfaceOrientation {
                playerVM.deviceRotation = rotation
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    playerVM.isRotated = (playerVM.deviceRotation == .landscapeLeft || playerVM.deviceRotation == .landscapeRight)
                }
            }
        }
    }
    
    
    func setAudioSessionCategory(to value: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(value)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    @ViewBuilder
    func RateSelectorView(_ videoSize: CGSize, _ selectedResolution:Resolution) -> some View{
        if(playerVM.showSelectRate){
            
            
            VStack(spacing:4){
                Button{
                    playerVM.selectResolution(resolution: Resolution.p1080)
                } label: {
                    Text("1080").foregroundColor(.white).foregroundColor(.white).font(.system(size: 16))
                }.buttonStyle(.bordered).tint(.white.opacity(selectedResolution == Resolution.p1080 ? 1 : 0))
                Button{
                    playerVM.selectResolution(resolution: Resolution.p720)
                    
                } label: {
                    Text("720").foregroundColor(.white).font(.system(size: 16))
                }.buttonStyle(.bordered).tint(.white.opacity(selectedResolution == Resolution.p720 ? 1 : 0))
                Button{
                    playerVM.selectResolution(resolution: Resolution.p480)
                } label: {
                    Text("480").foregroundColor(.white).foregroundColor(.white).font(.system(size: 16))
                }.buttonStyle(.bordered).tint(.white.opacity(selectedResolution == Resolution.p480 ? 1 : 0))
            }.padding(4).background(Color.init(red: 0.36, green: 0.37, blue: 0.37)).cornerRadius(4).offset(x: -30,y: -40)
        } else{
            EmptyView()
        }
        
    }
    
    
    /// Dragging Thumbnail View
    @ViewBuilder
    func SeekerThumbnailView(_ videoSize: CGSize) -> some View {
        let thumbSize: CGSize = .init(width: 175, height: 100)
        ZStack {
            if let draggingImage{
                Image(uiImage: draggingImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .bottom, content: {
                        if let currentItem = playerVM.player?.currentItem {
                            Text(CMTime(seconds: playerVM.progress * currentItem.duration.seconds, preferredTimescale: 600).toTimeString())
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .offset(y: 25)
                        }
                    })
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    }
            } else {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    }
            }
        }
        .frame(width: thumbSize.width, height: thumbSize.height)
        .opacity(isDragging ? 1 : 0)
        /// Moving Along side with Gesture
        /// Adding Some Padding at Start and End
        .offset(x: playerVM.progress * (videoSize.width - thumbSize.width - 20))
        .offset(x: 10)
    }
    
    /// Video Seeker View
    @ViewBuilder
    func VideoSeekerView(_ videoSize: CGSize) -> some View {
        Rectangle().fill(Color.init(red: 0.36, green: 0.37, blue: 0.37)).frame(height:34).overlay(alignment:.top){
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray).frame(height: 2)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: max(videoSize.width * playerVM.progress, 0),height: 2)
                HStack{
                    VideoDurationAndProgress(progress: playerVM.progress, playerItem: playerVM.player?.currentItem)
                    Spacer()
                    HStack{
                        Button{
                            playerVM.showSelectRate = !playerVM.showSelectRate
                        } label:{
                            HStack{
                                Text("\(playerVM.selectedRate.displayValue)").foregroundColor(.white).font(.system(size: 14))
                                Image(systemName: playerVM.showSelectRate ? "arrowtriangle.down.fill": "arrowtriangle.up.fill")
                                    .resizable()
                                    .frame(width: 8,height: 8)
                                    .font(.title)
                                    .foregroundColor(.white)
                            }.padding(.trailing,10)
                            
                        }
//                        Button{
//                            
//                        } label:{
//                                Image(systemName: false ? "pip.remove": "pip")
//                                    .resizable()
//                                    .frame(width: 16,height: 16)
//                                    .font(.title)
//                                    .foregroundColor(.white)
//        
//                            
//                        }.padding(.trailing,10)
                        Button{
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                let orientation = windowScene.interfaceOrientation
                                if orientation == .landscapeLeft || orientation == .landscapeRight{
                                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                                }else if orientation == .portrait{
                                    playerVM.fullScreenTapped = true
                                    print("2")
                                }
                                
                            }
                        } label:{
                            Image(systemName: "viewfinder").resizable().frame(width: 16,height: 16)
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                    }.offset(x:-8,y:16)
                }
                
            }
            .frame(height: 3)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(.white)
                    .frame(width: 15, height: 15)
                /// Showing Drag Knob Only When Dragging
                /// For More Dragging Space
                    .frame(width: 50, height: 50)
                    .contentShape(Rectangle())
                /// Moving Along Side With Gesture Progress
                    .offset(x: videoSize.width * playerVM.progress)
                    .gesture(
                        DragGesture()
                            .updating($isDragging, body: { _, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                /// Cancelling Existing Timeout Task
                                if let timeoutTask {
                                    timeoutTask.cancel()
                                }
                                
                                /// Calculating Progress
                                let translationX: CGFloat = value.translation.width
                                let calculatedProgress = (translationX / videoSize.width) + playerVM.lastDraggedProgress
                                
                                playerVM.progress = max(min(calculatedProgress, 1), 0)
                                playerVM.isSeeking = true
                                
                                let dragIndex = Int(playerVM.progress / 0.01)
                                /// Checking if FrameThubmnails Contains the Frame
                                if thumbnailFrames.indices.contains(dragIndex) {
                                    draggingImage = thumbnailFrames[dragIndex]
                                }
                            })
                            .onEnded({ value in
                                /// Storing Last Known Progress
                                playerVM.lastDraggedProgress = playerVM.progress
                                /// Seeking Video To Dragged Time
                                if let currentPlayerItem = playerVM.player?.currentItem {
                                    let totalDuration = currentPlayerItem.duration.seconds
                                    
                                    playerVM.player?.seek(to: .init(seconds: totalDuration * playerVM.progress, preferredTimescale: 600))
                                    
                                    /// Re-Scheduling Timeout Task
                                    if playerVM.isPlaying {
                                        timeoutControls()
                                    }
                                    
                                    /// Releasing With Slight Delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        playerVM.isSeeking = false
                                    }
                                }
                            })
                    )
                    .offset(x: playerVM.progress * videoSize.width > 15 ? (playerVM.progress * -15) : 0)
                    .frame(width: 15, height: 15)
            }
            
            
        }.opacity(playerVM.showPlayerControls || isDragging ? 1 : 0)
        
    }
    
    @ViewBuilder
    func VideoDurationAndProgress(progress:CGFloat,playerItem:AVPlayerItem?) -> some View{
        //TODO: solve progress time
        if(playerItem != nil){
            let itemDuration = playerItem!.duration.seconds
            let progressTime = playerVM.player?.currentTime().seconds ?? 0
            let progressParts = getDurationParts(seconds:progressTime)
            let durationParts = getDurationParts(seconds:itemDuration)
       
            
            Text("\(getDurationString(showPlaceholder: progressTime.isNaN,hours:progressParts.hours, minutes: progressParts.minutes, seconds: progressParts.seconds)) / \(getDurationString(showPlaceholder: itemDuration.isNaN,hours:durationParts.hours,minutes: durationParts.minutes, seconds: durationParts.seconds))")
                .font(Font.custom("Poppins", size: 12))
                .kerning(0.5)
                .foregroundColor(.white).offset(x:5,y:16)
        }
    }
    
    
    
    private func getDurationParts(seconds:Double)-> (hours:Double,minutes:Double,seconds:Double){
        let durationInSeconds = seconds.truncatingRemainder(dividingBy: 60)
        let durationMinutes = (seconds.truncatingRemainder(dividingBy:3600)) / 60
        let durationHours = seconds / 3600
        return (durationHours,durationMinutes,durationInSeconds)
    }
    
    private func getDurationString(showPlaceholder:Bool,hours:Double? = nil,minutes:Double,seconds:Double)-> String{
        return  "\(showPlaceholder ? "00:00:00" : "\(hours == nil ? "" : "\(hours! < 10 ?"0":"")\(String(format: "%.0f", hours!)):")\(minutes < 10 ?"0":"")\(String(format: "%.0f", minutes)):\(seconds < 10 ?"0":"")\(String(format: "%.0f", seconds))")"
    }
    
    /// Playback Controls View
    @ViewBuilder
    func PlayBackControls() -> some View {
        HStack(spacing: 25) {
            Button {
                if playerVM.isFinishedPlaying {
                    /// Setting Video to Start and Playing Again
                    playerVM.isFinishedPlaying = false
                    playerVM.player?.seek(to: .zero)
                    playerVM.progress = .zero
                    playerVM.lastDraggedProgress = .zero
                }
                
                /// Changing Video Status to Play/Pause based on user input
                if playerVM.isPlaying {
                    /// Pause Video
                    playerVM.player?.pause()
                    /// Cancelling Timeout Task when the Video is Paused
                    if let timeoutTask {
                        timeoutTask.cancel()
                    }
                } else {
                    /// Play Video
                    playerVM.player?.play()
                    timeoutControls()
                }
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    playerVM.isPlaying.toggle()
                }
            } label: {
                HStack{
                    Image(systemName: playerVM.isFinishedPlaying ? "arrow.clockwise" : (playerVM.isPlaying ? "pause.fill" : "play.fill")).resizable().frame(width: 8,height: 8)
                        .font(.title)
                        .foregroundColor(.black)
                    
                    Text("Начать просмотр").font(
                        Font.custom("Grtsk Exa", size: 12)
                            .weight(.medium)
                    )
                    .kerning(0.16).foregroundColor(Color(red: 0.08, green: 0.1, blue: 0.1))
                    
                    
                }.padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .foregroundColor(.white)
                    .background(Color(red: 0.6, green: 0.79, blue: 0.24))
                    .cornerRadius(4).contentShape(Rectangle()).contentShape(Rectangle())
            }
        }
        /// Hiding Controls When Dragging
        .opacity(playerVM.showPlayerControls && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: playerVM.showPlayerControls && !isDragging)
    }
    
    /// Timing Out Play back controls
    /// After some 2-5 Seconds
    func timeoutControls() {
        /// Cancelling Already Pending Timeout Task
        if let timeoutTask {
            timeoutTask.cancel()
        }
        
        timeoutTask = .init(block: {
            withAnimation(.easeInOut(duration: 0.35)) {
                playerVM.turnOffPlayerControl()
            }
        })
        
        /// Scheduling Task
        if let timeoutTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: timeoutTask)
        }
    }
    
    /// Generating Thumbnail Frames
    func generateThumbnailFrames() {
        Task.detached {
            guard let asset = await playerVM.player?.currentItem?.asset else { return }
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            /// Min Size
            generator.maximumSize = .init(width: 250, height: 250)
            
            do {
                let totalDuration = try await asset.load(.duration).seconds
                var frameTimes: [CMTime] = []
                /// Frame Timings
                /// 1/0.1 = 100 (Frames)
                for progress in stride(from: 0, to: 1, by: 0.01) {
                    let time = CMTime(seconds: progress * totalDuration, preferredTimescale: 600)
                    frameTimes.append(time)
                }
                
                /// Generating Frame Images
                for await result in generator.images(for: frameTimes) {
                    let cgImage = try result.image
                    /// Adding Frame Image
                    await MainActor.run(body: {
                        thumbnailFrames.append(UIImage(cgImage: cgImage))
                    })
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



struct DeviceRotationModifier: ViewModifier {
    let onRotate: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                onRotate(UIDevice.current.orientation)
            }
    }
}

/// Custom View Modifier, Which Detects and tells Device Rotation
extension View {
    func onRotate(onRotate: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationModifier(onRotate: onRotate))
    }
}


extension CMTime {
    func toTimeString() -> String {
        let roundedSeconds = seconds.rounded()
        let hours: Int = Int(roundedSeconds / 3600)
        let min: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let sec: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, min, sec)
        }
        
        return String(format: "%02d:%02d", min, sec)
    }
}
