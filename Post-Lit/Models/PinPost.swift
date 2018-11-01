//
//  PinPost.swift
//  Post-Lit
//
//  Created by Sam on 11/1/18.
//  Copyright © 2018 SamWayne. All rights reserved.
//

import AVFoundation

class PinPost {
    
    var duration: Timer?
    var videoAsString: String
    
    init(duration: Timer?, videoAsString: String) {
        self.duration = duration
        self.videoAsString = videoAsString
    }
}
