//
//  HapticManager.swift
//  CryptoApp
//
//  Created by Hakob Ghlijyan on 12.08.2023.
//

import SwiftUI

class HapticManager {
 
    static private let generator = UINotificationFeedbackGenerator()
    
    static func notification(type:UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
    
}
