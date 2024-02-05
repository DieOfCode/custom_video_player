//
//  ContentView.swift
//  Pods
//
//  Created by Иван Свирский on 24.01.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            PlayerView(size: size, safeArea: safeArea)
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }
}

@available(iOS 13.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
