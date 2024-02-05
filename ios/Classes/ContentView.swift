//
//  ContentView.swift
//  nefect_video_player
//
//  Created by Иван Свирский on 24.01.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            PlayerView(videoPath: "http://stream.nefiktivnoe.ru/lections/2229/2230/index.m3u8", size: CGSize(width: size.width, height: 820), safeArea: safeArea)
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark).foregroundColor(.purple)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
