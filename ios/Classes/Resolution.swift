//
//  Resolution.swift
//  nefect_video_player
//
//  Created by Иван Свирский on 31.01.24.
//

import Foundation



enum Resolution: Int, Identifiable, Comparable, CaseIterable {
    case p480 = 0
    case p720
    case p1080
    
    var id: Int { rawValue }
    
    //240p = 700000 // 360p = 1500000 // 480p = 2000000 // 720p = 4000000 // 1080p = 6000000 // 2k = 16000000 // 4k = 45000000
    var displayValue: String {
        switch self {
        case .p480: return "480"
        case .p720: return "720"
        case .p1080: return "1080"
        }
    }
    
    var bitrateValue:Double{
        switch self{
        case .p480: return 2000000
        case .p720: return 4000000
        case .p1080: return 6000000
        }
    }
    
    static func ==(lhs: Resolution, rhs: Resolution) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    static func <(lhs: Resolution, rhs: Resolution) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
